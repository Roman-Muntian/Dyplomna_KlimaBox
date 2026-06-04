// =====================================================================
//  NEO BUTTON — кнопка у Neo-Brutalist стилі
//
//  При натисканні зміщується на 5px вниз-вправо і прибирає тінь —
//  імітація фізичного натискання. Підтримує disabled стан.
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/neo_brutalist_theme.dart';

class NeoButton extends StatefulWidget {
  final Widget        child;
  final VoidCallback? onPressed;
  final Color?        color;
  final Color?        textColor;
  final EdgeInsets    padding;
  final double        radius;
  final bool          fullWidth;

  const NeoButton({
    super.key,
    required this.child,
    this.onPressed,
    this.color,
    this.textColor,
    this.padding   = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.radius    = NB.radiusChunky,
    this.fullWidth = false,
  });

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final bgColor  = disabled ? NB.subtleGrey : (widget.color    ?? NB.neonYellow);
    final txtColor = disabled ? NB.mutedInk   : (widget.textColor ?? NB.ink);

    final btn = AnimatedContainer(
      duration:  const Duration(milliseconds: 80),
      curve:     Curves.easeOut,
      // Зміщення при натисканні імітує фізичне натискання кнопки
      transform: _pressed ? Matrix4.translationValues(5, 5, 0) : Matrix4.identity(),
      padding:   widget.padding,
      decoration: nbBlock(
        color:  bgColor,
        radius: widget.radius,
        shadow: _pressed ? NB.hardShadowNone : NB.hardShadow,
      ),
      child: DefaultTextStyle.merge(
        style: NB.label(14, color: txtColor),
        child: IconTheme(
          data:  IconThemeData(color: txtColor, size: 20),
          child: widget.child,
        ),
      ),
    );

    final wrapped = widget.fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
    if (disabled) return wrapped;

    return GestureDetector(
      onTapDown:   (_) { setState(() => _pressed = true);  HapticFeedback.selectionClick(); },
      onTapCancel: ()  { setState(() => _pressed = false); },
      onTapUp:     (_) { setState(() => _pressed = false); widget.onPressed?.call(); },
      child: wrapped,
    );
  }
}