// =====================================================================
//  EXPORT SERVICE — експорт телеметрії у CSV
//
//  Платформи:
//  - Mobile: зберігає файл у тимчасову папку → Share Sheet
//  - Web:    створює файл в пам'яті → браузер завантажує автоматично
//
//  Формат CSV:
//  - Роздільник: крапка з комою (;) — сумісно з Excel
//  - UTF-8 BOM — автоматичне розпізнавання кирилиці в Excel
//  - Назва файлу: KlimaBox_DD-MM-YYYY.csv
// =====================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class ExportService {
  static Future<void> exportLogsToCSV(List<Map<String, dynamic>> logs) async {
    if (logs.isEmpty) return;

    final now      = DateTime.now();
    final dateStr  = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final fileName = 'KlimaBox_$dateStr.csv';

    // ── Формування CSV ────────────────────────────────────────────
    final rows = <List<dynamic>>[
      ['Дата', 'Час', 'Показник', 'Значення'],
    ];

    for (final log in logs) {
      final raw = log['timestamp']?.toString() ?? '';
      String date = '', time = '';
      try {
        final dt = DateTime.parse(raw);
        date = '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
        time = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {
        date = raw;
      }
      rows.add([date, time, log['type'] == 'temp' ? 'Температура, °C' : 'Вологість, %', log['value']]);
    }

    // UTF-8 BOM забезпечує коректне відображення кирилиці в Excel
    const bom        = '\uFEFF';
    final csvContent = bom + const ListToCsvConverter(fieldDelimiter: ';').convert(rows);

    try {
      if (kIsWeb) {
        // Web: передаємо байти напряму — браузер ініціює завантаження
        final bytes = utf8.encode(csvContent);
        await Share.shareXFiles(
          [XFile.fromData(Uint8List.fromList(bytes), mimeType: 'text/csv', name: fileName)],
          text: 'KlimaBox — телеметрія за $dateStr',
        );
      } else {
        // Mobile: зберігаємо у тимчасову папку і передаємо у Share Sheet
        final dir  = await getTemporaryDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(csvContent);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'KlimaBox — телеметрія за $dateStr',
        );
      }
    } catch (e) {
      debugPrint("ExportService: помилка експорту: $e");
    }
  }
}