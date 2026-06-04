// =====================================================================
//  CONNECTION STATUS STRIP — індикатор стану MQTT підключення
//
//  Відображає кольоровий рядок з іконкою і текстом залежно від стану:
//  connected → зелений | connecting → жовтий | error → червоний | disconnected → білий
// =====================================================================

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../mqtt_service.dart';
import '../theme/neo_brutalist_theme.dart';
import '../app_state.dart';

class ConnectionStatusStrip extends StatelessWidget {
  final MqttConnectionState connectionState;
  const ConnectionStatusStrip({super.key, required this.connectionState});

  @override
  Widget build(BuildContext context) {
    final config = _config();

    return Container(
      width:      double.infinity,
      padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: nbBlock(color: config.color, shadow: NB.hardShadowSm, radius: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icon, size: 16, color: config.contentColor),
          const SizedBox(width: 8),
          Text(
            config.text.toUpperCase(),
            style: NB.label(11, weight: FontWeight.w900, color: config.contentColor),
          ),
        ],
      ),
    );
  }

  // Повертає кольори, іконку і текст для поточного стану
  _StatusConfig _config() {
    switch (connectionState) {
      case MqttConnectionState.connected:
        return _StatusConfig(NB.mintGreen,  LucideIcons.checkCircle2,   t('connected'),        Colors.black);
      case MqttConnectionState.connecting:
        return _StatusConfig(NB.neonYellow, LucideIcons.refreshCw,      t('connecting'),       Colors.black);
      case MqttConnectionState.error:
        return _StatusConfig(NB.hotRed,     LucideIcons.triangleAlert,  t('connection_error'), Colors.white);
      case MqttConnectionState.disconnected:
        return _StatusConfig(NB.white,      LucideIcons.xCircle,        t('disconnected'),     Colors.black);
    }
  }
}

// Допоміжний клас для конфігурації стану
class _StatusConfig {
  final Color    color;
  final IconData icon;
  final String   text;
  final Color    contentColor;
  const _StatusConfig(this.color, this.icon, this.text, this.contentColor);
}