// =====================================================================
//  ALARM OVERLAY — банери алармів знизу екрана
//
//  Показує червоний банер для температури і/або вологості
//  коли значення виходить за допустимі межі.
//  Реагує на зміну мови через ListenableBuilder + AppState.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_state.dart';
import '../mqtt_service.dart';
import '../theme/neo_brutalist_theme.dart';

class AlarmOverlay extends StatelessWidget {
  final MqttService mqtt;
  const AlarmOverlay({super.key, required this.mqtt});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AlarmBanner(type: 'temp', stream: mqtt.tempStream, mqtt: mqtt),
            _AlarmBanner(type: 'hum',  stream: mqtt.humStream,  mqtt: mqtt),
          ],
        ),
      ),
    );
  }
}

class _AlarmBanner extends StatelessWidget {
  final String          type;
  final Stream<String>  stream;
  final MqttService     mqtt;

  const _AlarmBanner({
    required this.type,
    required this.stream,
    required this.mqtt,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        return StreamBuilder<String>(
          stream: stream,
          builder: (context, snap) {
            if (!snap.hasData) return const SizedBox.shrink();

            final val      = double.tryParse(snap.data!) ?? 0;
            final alarmKey = mqtt.settings.checkAlarm(val, type);
            if (alarmKey == null) return const SizedBox.shrink();

            return Container(
              margin:     const EdgeInsets.only(bottom: 12, left: 20, right: 20),
              padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: nbBlock(color: NB.hotRed, shadow: NB.hardShadow, radius: 8),
              child: Row(
                children: [
                  const Icon(LucideIcons.triangleAlert, color: Colors.white, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _message(alarmKey),
                      style: NB.body(13, color: Colors.white, weight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _message(String key) {
    switch (key) {
      case 'temp_low':  return t('temp_low');
      case 'temp_high': return t('temp_high');
      case 'hum_low':   return t('hum_low');
      case 'hum_high':  return t('hum_high');
      default:          return key;
    }
  }
}