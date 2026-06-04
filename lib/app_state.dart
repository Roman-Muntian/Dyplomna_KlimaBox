// =====================================================================
//  APP STATE — керування мовою та темою
//
//  Зберігає налаштування через shared_preferences.
//  Дефолт: українська мова, світла тема.
//
//  Використання: обгорніть кореневий MaterialApp в AnimatedBuilder
//  прив'язаний до AppState.instance — дерево перебудується
//  автоматично при перемиканні мови або теми.
// =====================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i18n/app_strings.dart';
import 'theme/neo_brutalist_theme.dart';

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  // ── Ключі збереження у SharedPreferences ─────────────────────────
  static const String _kLang  = 'app_lang';
  static const String _kTheme = 'app_theme_dark';

  String _langCode = 'uk';
  bool   _isDark   = false;

  String get langCode => _langCode;
  bool   get isDark   => _isDark;

  // ── Завантаження збережених налаштувань ───────────────────────────
  // Викликається один раз перед runApp() у main().
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _langCode = prefs.getString(_kLang)  ?? 'uk';
    _isDark   = prefs.getBool(_kTheme)   ?? false;
    NB.setDark(_isDark);
    notifyListeners();
  }

  // ── Зміна мови ────────────────────────────────────────────────────
  Future<void> setLang(String code) async {
    if (_langCode == code) return;
    _langCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLang, code);
  }

  // ── Зміна теми ────────────────────────────────────────────────────
  Future<void> setDark(bool dark) async {
    if (_isDark == dark) return;
    _isDark = dark;
    NB.setDark(dark);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTheme, dark);
  }

  Future<void> toggleDark() => setDark(!_isDark);
  Future<void> toggleLang()  => setLang(_langCode == 'uk' ? 'en' : 'uk');
}

// ── Глобальний хелпер перекладу ───────────────────────────────────────
// Використовується по всьому додатку як t('key').
// Автоматично повертає переклад активної мови з AppState.
String t(String key) => S.tr(key, AppState.instance.langCode);