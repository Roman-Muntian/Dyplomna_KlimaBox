// =====================================================================
//  NEO-BRUTALIST THEME — єдине джерело стилів KlimaBox
//
//  Кольори — статичні геттери що перемикаються між light/dark
//  залежно від прапорця NB._dark.
//
//  Шрифти:   Unbounded (display) · Manrope (body/label) · JetBrainsMono (mono)
//  Тіні:     без розмиття (hard shadow) — ключова риса Neo-Brutalism
//  Рамки:    2–2.5px суцільні лінії
// =====================================================================

import 'package:flutter/material.dart';

class NB {
  NB._();

  // ── Перемикач light / dark ────────────────────────────────────────
  static bool _dark = false;
  static void setDark(bool dark) => _dark = dark;
  static bool get isDark => _dark;

  // ── Палітра — Light ───────────────────────────────────────────────
  static const Color _paperLight       = Color(0xFFF4F4F4);
  static const Color _inkLight         = Color(0xFF000000);
  static const Color _whiteLight       = Color(0xFFFFFFFF);
  static const Color _softWhiteLight   = Color(0xFFFAFAFA);
  static const Color _subtleGreyLight  = Color(0xFFE5E5E5);
  static const Color _charcoalLight    = Color(0xFF1A1A1A);
  static const Color _neonYellowLight  = Color(0xFFFFF000);
  static const Color _electricBlueLight = Color(0xFF0055FF);
  static const Color _mintGreenLight   = Color(0xFF00FF90);
  static const Color _hotRedLight      = Color(0xFFFF3D2E);
  static const Color _neonPinkLight    = Color(0xFFFF4FD8);
  static const Color _mutedInkLight    = Color(0xFF6E6E6E);

  // ── Палітра — Dark ────────────────────────────────────────────────
  // Акценти залишаються яскравими — суть Neo-Brutalism у темній темі.
  static const Color _paperDark        = Color(0xFF0A0A0A);
  static const Color _inkDark          = Color(0xFFFFFFFF);
  static const Color _whiteDark        = Color(0xFF1C1C1C);
  static const Color _softWhiteDark    = Color(0xFF141414);
  static const Color _subtleGreyDark   = Color(0xFF2A2A2A);
  static const Color _charcoalDark     = Color(0xFF111111);
  static const Color _neonYellowDark   = Color(0xFFFFF000);
  static const Color _electricBlueDark = Color(0xFF0055FF);
  static const Color _mintGreenDark    = Color(0xFF00FF90);
  static const Color _hotRedDark       = Color(0xFFFF3D2E);
  static const Color _neonPinkDark     = Color(0xFFFF4FD8);
  static const Color _mutedInkDark     = Color(0xFF888888);

  // ── Публічні геттери ─────────────────────────────────────────────
  static Color get paper        => _dark ? _paperDark        : _paperLight;
  static Color get ink          => _dark ? _inkDark          : _inkLight;
  static Color get white        => _dark ? _whiteDark        : _whiteLight;
  static Color get softWhite    => _dark ? _softWhiteDark    : _softWhiteLight;
  static Color get subtleGrey   => _dark ? _subtleGreyDark   : _subtleGreyLight;
  static Color get charcoal     => _dark ? _charcoalDark     : _charcoalLight;
  static Color get neonYellow   => _dark ? _neonYellowDark   : _neonYellowLight;
  static Color get electricBlue => _dark ? _electricBlueDark : _electricBlueLight;
  static Color get mintGreen    => _dark ? _mintGreenDark    : _mintGreenLight;
  static Color get hotRed       => _dark ? _hotRedDark       : _hotRedLight;
  static Color get neonPink     => _dark ? _neonPinkDark     : _neonPinkLight;
  static Color get mutedInk     => _dark ? _mutedInkDark     : _mutedInkLight;

  // ── Рамки ────────────────────────────────────────────────────────
  static const double borderThick = 2.5;
  static const double borderThin  = 2.0;

  static Border outline({Color? color, double width = borderThick}) =>
      Border.all(color: color ?? ink, width: width);

  // ── Hard shadows (без розмиття) ───────────────────────────────────
  static List<BoxShadow> get hardShadow   => [BoxShadow(color: ink, offset: const Offset(5, 5), blurRadius: 0)];
  static List<BoxShadow> get hardShadowSm => [BoxShadow(color: ink, offset: const Offset(3, 3), blurRadius: 0)];
  static List<BoxShadow> get hardShadowLg => [BoxShadow(color: ink, offset: const Offset(7, 7), blurRadius: 0)];
  static const List<BoxShadow> hardShadowNone = [];

  // ── Радіуси ───────────────────────────────────────────────────────
  static const double radiusSharp  = 0;
  static const double radiusChunky = 12;

  // ── Типографіка ───────────────────────────────────────────────────

  /// Заголовки і великі написи (Unbounded Bold)
  static TextStyle display(double size, {Color? color}) => TextStyle(
    fontFamily:    'Unbounded',
    fontSize:      size,
    fontWeight:    FontWeight.w900,
    color:         color ?? ink,
    height:        1.0,
    letterSpacing: 0.5,
  );

  /// Моноширинний текст для числових значень (JetBrains Mono)
  static TextStyle mono(double size, {FontWeight weight = FontWeight.w800, Color? color}) => TextStyle(
    fontFamily:    'JetBrainsMono',
    fontSize:      size,
    fontWeight:    weight,
    color:         color ?? ink,
    height:        1.0,
    letterSpacing: -0.5,
  );

  /// Підписи, мітки, кнопки (Manrope, розріджені літери)
  static TextStyle label(double size, {FontWeight weight = FontWeight.w800, Color? color}) => TextStyle(
    fontFamily:    'Manrope',
    fontSize:      size,
    fontWeight:    weight,
    color:         color ?? ink,
    height:        1.2,
    letterSpacing: 1.5,
  );

  /// Основний текст (Manrope, нормальний інтервал)
  static TextStyle body(double size, {FontWeight weight = FontWeight.w600, Color? color}) => TextStyle(
    fontFamily:    'Manrope',
    fontSize:      size,
    fontWeight:    weight,
    color:         color ?? ink,
    height:        1.4,
    letterSpacing: 0.2,
  );
}

// ── Хелпер декорації блока ───────────────────────────────────────────
// Використовується скрізь у додатку для єдиного стилю картки/контейнера.
BoxDecoration nbBlock({
  Color?           color,
  Color?           borderColor,
  double           radius      = NB.radiusChunky,
  List<BoxShadow>? shadow,
  double           borderWidth = NB.borderThick,
}) {
  return BoxDecoration(
    color:        color ?? NB.white,
    borderRadius: BorderRadius.circular(radius),
    border:       Border.all(color: borderColor ?? NB.ink, width: borderWidth),
    boxShadow:    shadow ?? NB.hardShadow,
  );
}