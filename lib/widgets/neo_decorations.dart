// =====================================================================
//  NEO DECORATIONS — декоративні UI компоненти дизайн-системи
//
//  NeoTag          — кольоровий тег з іконкою (варіанти: error/info/success/warn/custom)
//  NeoIconBox      — квадратна іконка у Neo-Brutalist рамці
//  NeoSectionHeader — заголовок секції з лінією-підкресленням
//  NeoStripeBackground — діагональний смугастий фон
// =====================================================================

import 'package:flutter/material.dart';
import '../theme/neo_brutalist_theme.dart';

// ── NeoTag ────────────────────────────────────────────────────────────

enum _NeoTagVariant { custom, error, info, success, warn }

class NeoTag extends StatelessWidget {
  final String         label;
  final Color?         color;
  final Color?         textColor;
  final double         fontSize;
  final IconData?      icon;
  final _NeoTagVariant _variant;

  const NeoTag({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.fontSize = 11,
    this.icon,
  }) : _variant = _NeoTagVariant.custom;

  const NeoTag._variant({
    super.key,
    required this.label,
    required _NeoTagVariant variant,
    this.fontSize = 11,
    this.icon,
  })  : color     = null,
        textColor = null,
        _variant  = variant;

  factory NeoTag.error(String label,   {Key? key, IconData? icon, double fontSize = 11}) =>
      NeoTag._variant(key: key, label: label, variant: _NeoTagVariant.error,   icon: icon, fontSize: fontSize);

  factory NeoTag.info(String label,    {Key? key, IconData? icon, double fontSize = 11}) =>
      NeoTag._variant(key: key, label: label, variant: _NeoTagVariant.info,    icon: icon, fontSize: fontSize);

  factory NeoTag.success(String label, {Key? key, IconData? icon, double fontSize = 11}) =>
      NeoTag._variant(key: key, label: label, variant: _NeoTagVariant.success, icon: icon, fontSize: fontSize);

  factory NeoTag.warn(String label,    {Key? key, IconData? icon, double fontSize = 11}) =>
      NeoTag._variant(key: key, label: label, variant: _NeoTagVariant.warn,    icon: icon, fontSize: fontSize);

  // Визначає кольори залежно від варіанту
  (Color, Color) _colors() {
    switch (_variant) {
      case _NeoTagVariant.error:   return (NB.hotRed,      Colors.white);
      case _NeoTagVariant.info:    return (NB.electricBlue, Colors.white);
      case _NeoTagVariant.success: return (NB.mintGreen,    Colors.black);
      case _NeoTagVariant.warn:    return (NB.neonYellow,   Colors.black);
      case _NeoTagVariant.custom:  return (color ?? NB.neonYellow, textColor ?? NB.ink);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors();
    return Container(
      padding:    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: nbBlock(color: bg, radius: 4, shadow: NB.hardShadowSm, borderWidth: NB.borderThin),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: fg),
            const SizedBox(width: 4),
          ],
          Text(label.toUpperCase(), style: NB.label(fontSize, color: fg, weight: FontWeight.w900)),
        ],
      ),
    );
  }
}

// ── NeoIconBox ────────────────────────────────────────────────────────

class NeoIconBox extends StatelessWidget {
  final IconData icon;
  final Color?   background;
  final Color?   iconColor;
  final double   size;
  final double   iconSize;

  const NeoIconBox({
    super.key,
    required this.icon,
    this.background,
    this.iconColor,
    this.size     = 44,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: nbBlock(color: background ?? NB.neonYellow, radius: 6, shadow: NB.hardShadowSm, borderWidth: NB.borderThin),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize, color: iconColor ?? NB.ink),
    );
  }
}

// ── NeoSectionHeader ──────────────────────────────────────────────────

class NeoSectionHeader extends StatelessWidget {
  final String  label;
  final Widget? trailing;

  const NeoSectionHeader({super.key, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label.toUpperCase(), style: NB.display(13)),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 6),
        Container(height: 2.5, color: NB.ink),
      ],
    );
  }
}

// ── NeoStripeBackground ───────────────────────────────────────────────

class NeoStripeBackground extends StatelessWidget {
  final Widget child;
  final Color? stripeA;
  final Color? stripeB;

  const NeoStripeBackground({
    super.key,
    required this.child,
    this.stripeA,
    this.stripeB,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StripePainter(a: stripeA ?? NB.neonYellow, b: stripeB ?? NB.ink),
      child: child,
    );
  }
}

class _StripePainter extends CustomPainter {
  final Color a, b;
  const _StripePainter({required this.a, required this.b});

  @override
  void paint(Canvas canvas, Size size) {
    // Фон
    canvas.drawRect(Offset.zero & size, Paint()..color = a);

    // Діагональні смуги
    final paint       = Paint()..color = b;
    const stripeWidth = 14.0;
    const gap         = 28.0;

    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawPath(
        Path()
          ..moveTo(x, 0)
          ..lineTo(x + stripeWidth, 0)
          ..lineTo(x + stripeWidth + size.height, size.height)
          ..lineTo(x + size.height, size.height)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) => old.a != a || old.b != b;
}