// =====================================================================
//  SETTINGS SERVICE — порогові значення алармів
//
//  Зберігає та завантажує межі температури і вологості через
//  SharedPreferences. Метод checkAlarm() повертає системний ключ
//  аларму (наприклад 'temp_high') або null якщо значення в нормі.
// =====================================================================

import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Значення за замовчуванням
  double tempMin = 10.0, tempMax = 30.0;
  double humMin  = 30.0, humMax  = 70.0;

  // ── Завантаження збережених налаштувань ──────────────────────────
  // Валідує дані при завантаженні — гарантує що min <= max.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final tMin = prefs.getDouble('tempMin') ?? 10.0;
    final tMax = prefs.getDouble('tempMax') ?? 30.0;
    final hMin = prefs.getDouble('humMin')  ?? 30.0;
    final hMax = prefs.getDouble('humMax')  ?? 70.0;

    tempMin = min(tMin, tMax);
    tempMax = max(tMin, tMax);
    humMin  = min(hMin, hMax);
    humMax  = max(hMin, hMax);
  }

  // ── Збереження нових значень ─────────────────────────────────────
  // min/max автоматично сортуються — порядок аргументів не важливий.
  Future<void> update(double tMin, double tMax, double hMin, double hMax) async {
    tempMin = min(tMin, tMax);
    tempMax = max(tMin, tMax);
    humMin  = min(hMin, hMax);
    humMax  = max(hMin, hMax);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tempMin', tempMin);
    await prefs.setDouble('tempMax', tempMax);
    await prefs.setDouble('humMin',  humMin);
    await prefs.setDouble('humMax',  humMax);
  }

  // ── Перевірка аларму ─────────────────────────────────────────────
  // Повертає системний ключ ('temp_low', 'temp_high', 'hum_low', 'hum_high')
  // або null якщо значення в допустимих межах.
  String? checkAlarm(double val, String type) {
    if (type == 'temp') {
      if (val < tempMin) return 'temp_low';
      if (val > tempMax) return 'temp_high';
    } else if (type == 'hum') {
      if (val < humMin) return 'hum_low';
      if (val > humMax) return 'hum_high';
    }
    return null;
  }
}