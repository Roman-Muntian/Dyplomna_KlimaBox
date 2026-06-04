// =====================================================================
//  MQTT SERVICE — підключення до HiveMQ Cloud і обробка телеметрії
//
//  Відповідає за:
//  - Підключення до захищеного брокера (TLS 8883 / WSS 8884)
//  - Отримання даних температури і вологості від ESP32
//  - Watchdog: якщо за 15с немає даних — ESP32 вважається офлайн
//  - Авторетрай з експоненційною затримкою (2..60 секунд)
//  - Запис у БД (раз на хвилину на тип)
//  - Push-сповіщення при виході за межі (кулдаун 5 хвилин)
//  - Публікація команд на ESP32 (топік klimabox/cmd)
// =====================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'settings_service.dart';
import 'notification_service.dart';
import 'db_service.dart';
import 'i18n/app_strings.dart';

enum MqttConnectionState { connected, disconnected, connecting, error }

class MqttService {
  MqttServerClient? client;

  final settings       = SettingsService();
  final _notifications = NotificationService();
  final _dbService     = DbService();

  // ── Потоки даних ─────────────────────────────────────────────────
  final _tempStream  = StreamController<String>.broadcast();
  final _humStream   = StreamController<String>.broadcast();
  final _stateStream = StreamController<MqttConnectionState>.broadcast();

  Stream<String>              get tempStream  => _tempStream.stream;
  Stream<String>              get humStream   => _humStream.stream;
  Stream<MqttConnectionState> get stateStream => _stateStream.stream;

  // ── Внутрішній стан ──────────────────────────────────────────────
  MqttConnectionState currentState  = MqttConnectionState.disconnected;
  int    _retryCount   = 0;
  bool   _isConnecting = false;
  Timer? _reconnectTimer;
  Timer? _watchdogTimer;

  // Запис у БД — раз на хвилину на кожен тип
  DateTime? _lastTempDbSave, _lastHumDbSave;

  // Push-сповіщення — кулдаун 5 хвилин на кожен тип аларму
  DateTime? _lastTempHighAlert, _lastTempLowAlert;
  DateTime? _lastHumHighAlert,  _lastHumLowAlert;

  static const int _watchdogSeconds = 15;

  // ── Підключення до брокера ───────────────────────────────────────
  Future<void> connect() async {
    if (_isConnecting) return;
    _isConnecting = true;
    _reconnectTimer?.cancel();

    _stateStream.add(currentState = MqttConnectionState.connecting);

    await settings.load();
    await _notifications.init();

    const server   = "5753b29c6fa34437914a4f06883b6437.s1.eu.hivemq.cloud";
    const mqttUser = "flutter_klimabox";
    const mqttPass = "Flutter_KlimaBox_2026";
    final  clientId = 'klimabox_flutter_${DateTime.now().millisecondsSinceEpoch}';

    // Web використовує WSS (8884), мобільні — TLS (8883)
    if (kIsWeb) {
      client = MqttServerClient.withPort(server, clientId, 8884)
        ..useWebSocket = true;
    } else {
      client = MqttServerClient.withPort(server, clientId, 8883)
        ..useWebSocket = false;
    }

    client!
      ..secure = true
      ..logging(on: true)
      ..keepAlivePeriod = 20
      ..autoReconnect = false
      ..setProtocolV311();

    // У debug-режимі ігноруємо помилки сертифіката
    if (kDebugMode) {
      client!.onBadCertificate = (Object certificate) => true;
    }

    try {
      debugPrint("MQTT: підключення до $server...");
      final result = await client!.connect(mqttUser, mqttPass);

      if (result?.returnCode != MqttConnectReturnCode.connectionAccepted) {
        throw Exception('Broker відхилив: ${result?.returnCode}');
      }

      _retryCount  = 0;
      _isConnecting = false;

      // Брокер підключений, але чекаємо перших даних від ESP32
      _stateStream.add(currentState = MqttConnectionState.connecting);
      _resetWatchdog();

      client!.subscribe('klimabox/temp', MqttQos.atMostOnce);
      client!.subscribe('klimabox/hum',  MqttQos.atMostOnce);

      // При розриві — запускаємо перепідключення з затримкою
      client!.onDisconnected = () {
        _isConnecting = false;
        _watchdogTimer?.cancel();
        _stateStream.add(currentState = MqttConnectionState.disconnected);

        final delay = (2 << _retryCount).clamp(2, 60);
        _retryCount++;
        debugPrint("MQTT: розрив, повтор через ${delay}s");
        _reconnectTimer = Timer(Duration(seconds: delay), connect);
      };

      // Обробка вхідних повідомлень
      client!.updates!.listen((messages) {
        final msg = messages[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
        _processData(messages[0].topic, payload);
      });

    } catch (e) {
      _isConnecting = false;
      _handleConnectionError(e);
    }
  }

  // ── Watchdog ─────────────────────────────────────────────────────
  // Скидається при кожному повідомленні від ESP32.
  // Якщо за _watchdogSeconds секунд даних немає — ESP32 офлайн.
  void _resetWatchdog() {
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer(const Duration(seconds: _watchdogSeconds), () {
      if (currentState != MqttConnectionState.error) {
        _stateStream.add(currentState = MqttConnectionState.disconnected);
      }
    });
  }

  // ── Обробка помилок підключення ───────────────────────────────────
  void _handleConnectionError(dynamic error) {
    debugPrint("MQTT помилка: $error");
    _watchdogTimer?.cancel();
    _stateStream.add(currentState = MqttConnectionState.error);

    final delay = (2 << _retryCount).clamp(2, 60);
    _retryCount++;
    _reconnectTimer = Timer(Duration(seconds: delay), connect);
  }

  // ── Обробка вхідних даних ─────────────────────────────────────────
  void _processData(String topic, String payload) {
    final val = double.tryParse(payload);
    if (val == null) return;

    // ESP32 живий — скидаємо watchdog і встановлюємо стан connected
    _resetWatchdog();
    if (currentState != MqttConnectionState.connected) {
      _stateStream.add(currentState = MqttConnectionState.connected);
    }

    final type = topic.contains('temp') ? 'temp' : 'hum';
    final now  = DateTime.now();

    // Публікуємо в стрім і зберігаємо в БД раз на хвилину
    if (type == 'temp') {
      _tempStream.add(payload);
      if (_lastTempDbSave == null || _lastTempDbSave!.minute != now.minute) {
        _dbService.insertLog(type, val);
        _lastTempDbSave = now;
      }
    } else {
      _humStream.add(payload);
      if (_lastHumDbSave == null || _lastHumDbSave!.minute != now.minute) {
        _dbService.insertLog(type, val);
        _lastHumDbSave = now;
      }
    }

    // Push-сповіщення з кулдауном 5 хвилин на кожен тип аларму
    final alarmKey = settings.checkAlarm(val, type);
    if (alarmKey != null && _shouldNotify(alarmKey, now)) {
      _updateAlertTime(alarmKey, now);
      final titleKey = type == 'temp' ? 'alert_temp_title' : 'alert_hum_title';
      _notifications.show(S.tr(titleKey, 'uk'), S.tr(alarmKey, 'uk'));
    }
  }

  // Перевіряє чи минув кулдаун для даного типу аларму
  bool _shouldNotify(String key, DateTime now) {
    DateTime? last;
    switch (key) {
      case 'temp_high': last = _lastTempHighAlert; break;
      case 'temp_low':  last = _lastTempLowAlert;  break;
      case 'hum_high':  last = _lastHumHighAlert;  break;
      case 'hum_low':   last = _lastHumLowAlert;   break;
    }
    return last == null || now.difference(last).inMinutes >= 5;
  }

  // Оновлює час останнього сповіщення для даного типу аларму
  void _updateAlertTime(String key, DateTime now) {
    switch (key) {
      case 'temp_high': _lastTempHighAlert = now; break;
      case 'temp_low':  _lastTempLowAlert  = now; break;
      case 'hum_high':  _lastHumHighAlert  = now; break;
      case 'hum_low':   _lastHumLowAlert   = now; break;
    }
  }

  // ── Публікація команди на ESP32 ──────────────────────────────────
  void publishCommand(String command) {
    if (client == null || currentState != MqttConnectionState.connected) return;
    final builder = MqttClientPayloadBuilder()..addString(command);
    client!.publishMessage('klimabox/cmd', MqttQos.atLeastOnce, builder.payload!);
  }

  // ── Очищення ресурсів ────────────────────────────────────────────
  void dispose() {
    _reconnectTimer?.cancel();
    _watchdogTimer?.cancel();
    _tempStream.close();
    _humStream.close();
    _stateStream.close();
    client?.disconnect();
  }
}