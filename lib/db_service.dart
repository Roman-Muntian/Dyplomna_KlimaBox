// =====================================================================
//  DB SERVICE — локальне сховище телеметрії
//
//  Платформи:
//  - Mobile (Android/iOS): SQLite через sqflite
//  - Web: SharedPreferences (JSON, ліміт 500 записів)
//
//  Оптимізації:
//  - Синглтон — одне з'єднання з БД на весь додаток
//  - Очищення старих записів раз на 100 вставок (не при кожній)
//  - getLogs() підтримує фільтрацію і ліміт на рівні SQL
// =====================================================================

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DbService {
  // ── Синглтон ──────────────────────────────────────────────────────
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _db;

  // Web: зберігаємо логи в пам'яті (завантажуємо з SharedPreferences)
  final List<Map<String, dynamic>> _webMemoryDb = [];
  bool _webLogsLoaded = false;

  // Лічильник вставок для рідкісного очищення старих записів
  int _insertCount = 0;

  // ── Ініціалізація БД ─────────────────────────────────────────────
  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await _initDb();
    return _db;
  }

  Future<Database?> _initDb() async {
    if (kIsWeb) {
      await _loadWebLogs();
      return null;
    }
    final path = join(await getDatabasesPath(), 'iot_telemetry.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE logs(
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT,
            type      TEXT,
            value     REAL
          )
        ''');
      },
    );
  }

  // ── Web: завантаження / збереження логів ─────────────────────────
  Future<void> _loadWebLogs() async {
    if (!kIsWeb || _webLogsLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('web_logs');
      if (saved != null) {
        final decoded = jsonDecode(saved) as List<dynamic>;
        _webMemoryDb
          ..clear()
          ..addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
      }
      _webLogsLoaded = true;
    } catch (e) {
      debugPrint("DbService: помилка завантаження Web-логів: $e");
    }
  }

  Future<void> _saveWebLogs() async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('web_logs', jsonEncode(_webMemoryDb.take(500).toList()));
  }

  // ── Вставка запису ───────────────────────────────────────────────
  // Зберігає з точністю до хвилини (без секунд) щоб зменшити кількість
  // дублікатів при частих оновленнях.
  Future<void> insertLog(String type, double value) async {
    final now          = DateTime.now();
    final cleanTime    = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    final timestamp    = cleanTime.toIso8601String().split('.').first;

    if (kIsWeb) {
      await _loadWebLogs();
      _webMemoryDb.insert(0, {
        'id':        DateTime.now().millisecondsSinceEpoch,
        'timestamp': timestamp,
        'type':      type,
        'value':     value,
      });
      if (_webMemoryDb.length > 1000) _webMemoryDb.removeLast();
      await _saveWebLogs();
      return;
    }

    final database = await db;
    await database!.insert('logs', {'timestamp': timestamp, 'type': type, 'value': value});

    // Важкий DELETE виконується лише раз на 100 вставок
    _insertCount++;
    if (_insertCount % 100 == 0) {
      await database.execute('''
        DELETE FROM logs WHERE id NOT IN (
          SELECT id FROM logs ORDER BY id DESC LIMIT 1000
        )
      ''');
    }
  }

  // ── Видалення одного запису ───────────────────────────────────────
  Future<void> deleteLog(int id) async {
    if (kIsWeb) {
      await _loadWebLogs();
      _webMemoryDb.removeWhere((log) => log['id'] == id);
      await _saveWebLogs();
      return;
    }
    final database = await db;
    await database!.delete('logs', where: 'id = ?', whereArgs: [id]);
  }

  // ── Отримання логів з фільтрацією ────────────────────────────────
  // [type]  — 'temp' | 'hum' | null (всі)
  // [date]  — рядок 'yyyy-MM-dd' або порожній (всі дати)
  // [limit] — максимальна кількість записів (за замовчуванням 200)
  Future<List<Map<String, dynamic>>> getLogs({
    String? type,
    String? date,
    int     limit = 200,
  }) async {
    if (kIsWeb) {
      await _loadWebLogs();
      return _webMemoryDb.where((log) {
        final matchType = (type == null || type == 'all') || log['type'] == type;
        final matchDate = (date == null || date.isEmpty)  || log['timestamp'].toString().startsWith(date);
        return matchType && matchDate;
      }).take(limit).toList();
    }

    final database = await db;
    String where         = '1=1';
    final  whereArgs     = <dynamic>[];

    if (type != null && type != 'all') {
      where += ' AND type = ?';
      whereArgs.add(type);
    }
    if (date != null && date.isNotEmpty) {
      where += ' AND timestamp LIKE ?';
      whereArgs.add('$date%');
    }

    final result = await database!.query(
      'logs',
      where:     where,
      whereArgs: whereArgs,
      orderBy:   'timestamp DESC',
      limit:     limit,
    );
    return result.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ── Очищення всього журналу ───────────────────────────────────────
  Future<void> clearLogs() async {
    if (kIsWeb) {
      await _loadWebLogs();
      _webMemoryDb.clear();
      await _saveWebLogs();
      return;
    }
    final database = await db;
    await database!.delete('logs');
    _insertCount = 0; // скидаємо лічильник після повного очищення
  }
}