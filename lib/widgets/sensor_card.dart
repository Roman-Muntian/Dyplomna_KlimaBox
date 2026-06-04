// =====================================================================
//  SENSOR CARD — картка сенсора (температура або вологість)
//
//  Архітектура для мінімізації перебудов:
//  - _SensorHeader: StreamBuilder для кольору (змінюється при аларм)
//  - _SensorValue:  StreamBuilder лише для числа (оновлюється кожні 5с)
//  - _RangeRow:     статичний, не перебудовується взагалі
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../analytics_screen.dart';
import '../app_state.dart';
import '../theme/neo_brutalist_theme.dart';
import 'neo_primitives.dart';

class SensorCard extends StatelessWidget {
  final String        title;
  final String        unit;
  final Stream<String> stream;
  final Color         accent;
  final IconData      icon;
  final double        min;
  final double        max;

  const SensorCard({
    super.key,
    required this.title,
    required this.unit,
    required this.stream,
    required this.accent,
    required this.icon,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen()));
      },
      child: Container(
        decoration: nbBlock(color: NB.white, shadow: NB.hardShadow),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SensorHeader(title: title, unit: unit, stream: stream, accent: accent, icon: icon, min: min, max: max),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SensorValue(stream: stream, unit: unit, min: min, max: max),
                  const SizedBox(height: 14),
                  _RangeRow(unit: unit, min: min, max: max),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Хедер — колір змінюється при аларм ───────────────────────────────
class _SensorHeader extends StatelessWidget {
  final String        title, unit;
  final Stream<String> stream;
  final Color         accent;
  final IconData      icon;
  final double        min, max;

  const _SensorHeader({
    required this.title,
    required this.unit,
    required this.stream,
    required this.accent,
    required this.icon,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snap) {
        final val   = double.tryParse(snap.data ?? '0') ?? 0;
        final alarm = (val < min || val > max) && snap.hasData;

        final headerColor = alarm ? NB.hotRed : accent;
        final headerText  = (headerColor == NB.electricBlue || headerColor == NB.hotRed)
            ? Colors.white
            : Colors.black;

        return Container(
          decoration: BoxDecoration(
            color:  headerColor,
            border: Border(bottom: BorderSide(color: NB.ink, width: NB.borderThick)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 22, color: headerText),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: NB.display(14, color: headerText), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (alarm)
                NeoTag.error(t('alarm'), icon: LucideIcons.triangleAlert)
              else
                NeoTag(label: t('ok'), color: NB.ink, textColor: NB.paper, icon: LucideIcons.check),
            ],
          ),
        );
      },
    );
  }
}

// ── Числове значення — оновлюється з кожним MQTT повідомленням ────────
class _SensorValue extends StatelessWidget {
  final Stream<String> stream;
  final String         unit;
  final double         min, max;

  const _SensorValue({
    required this.stream,
    required this.unit,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: stream,
      builder: (context, snap) {
        final val   = double.tryParse(snap.data ?? '0') ?? 0;
        final alarm = (val < min || val > max) && snap.hasData;

        return TweenAnimationBuilder<double>(
          tween:    Tween<double>(end: val),
          duration: const Duration(milliseconds: 800),
          curve:    Curves.easeOutCubic,
          builder:  (context, animated, _) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit:       BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      snap.hasData ? animated.toStringAsFixed(1) : "--",
                      style: NB.mono(78, weight: FontWeight.w900, color: alarm ? NB.hotRed : NB.ink),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(unit, style: NB.display(22, color: NB.ink)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Рядок діапазону — статичний, не перебудовується ──────────────────
class _RangeRow extends StatelessWidget {
  final String unit;
  final double min, max;

  const _RangeRow({required this.unit, required this.min, required this.max});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: nbBlock(color: NB.subtleGrey, radius: 4, shadow: NB.hardShadowNone, borderWidth: NB.borderThin),
          child: Text(
            "${t('range')} ${min.round()}–${max.round()}$unit",
            style: NB.label(10, weight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            t('tap_for_analytics'),
            textAlign: TextAlign.right,
            style:     NB.label(10, color: NB.mutedInk, weight: FontWeight.w800),
            maxLines:  1,
            overflow:  TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Icon(LucideIcons.chevronRight, size: 16, color: NB.ink),
      ],
    );
  }
}