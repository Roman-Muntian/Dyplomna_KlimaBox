// =====================================================================
//  LAST UPDATE BLOCK — час останнього оновлення даних від ESP32
// =====================================================================

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../app_state.dart';
import '../theme/neo_brutalist_theme.dart';

class LastUpdateBlock extends StatelessWidget {
  /// Відформатований рядок часу ("HH:mm:ss") або "--:--:--".
  final String time;

  const LastUpdateBlock({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: nbBlock(color: NB.neonYellow, radius: 4, shadow: NB.hardShadowSm, borderWidth: NB.borderThin),
      child: Row(
        children: [
          const Icon(LucideIcons.clock, size: 16, color: Colors.black),
          const SizedBox(width: 8),
          Text(t('last_update'), style: NB.label(11, weight: FontWeight.w900, color: Colors.black)),
          const Spacer(),
          Text(time, style: NB.mono(15, weight: FontWeight.w800, color: Colors.black)),
        ],
      ),
    );
  }
}