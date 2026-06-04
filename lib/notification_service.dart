// =====================================================================
//  NOTIFICATION SERVICE — локальні push-сповіщення
//
//  Використовується MqttService для алертів при виході
//  температури або вологості за допустимі межі.
//
//  Android: вимагає іконку @mipmap/ic_launcher
//  iOS:     запитує дозволи при першому виклику init()
// =====================================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart' show Color;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Лічильник для генерації унікальних ID сповіщень
  int _notificationId = 0;

  // ── Ініціалізація ────────────────────────────────────────────────
  // Викликати один раз при старті MqttService.
  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  // ── Показ сповіщення ─────────────────────────────────────────────
  Future<void> show(String title, String body) async {
    const details = NotificationDetails(
  android: AndroidNotificationDetails(
  'iot_alerts',
  'IoT Monitoring',
  importance: Importance.max,
  priority:   Priority.high,
  icon:       'ic_notification',
  color:    Color(0xFF0055FF),
),
  iOS: DarwinNotificationDetails(),
);

    // ID = (час у секундах + лічильник) % MAX_INT32
    // Гарантує унікальність і не виходить за межі Android int32
    final id = (DateTime.now().millisecondsSinceEpoch ~/ 1000 + _notificationId++)
        .remainder(2147483647);

    await _plugin.show(id, title, body, details);
  }
}