// =====================================================================
//  APP STRINGS — UK / EN
//  Статичний словник перекладів для всього додатку.
//  Мова за замовчуванням: українська.
//  Якщо ключ відсутній в активній мові — fallback на українську.
// =====================================================================

class S {
  S._();

  static const List<String> supported = ['uk', 'en'];
  static const String fallback = 'uk';

  static const Map<String, Map<String, String>> _strings = {

    // ══════════════════════════════════════════════════════════════
    // УКРАЇНСЬКА
    // ══════════════════════════════════════════════════════════════
    'uk': {

      // ── Назва додатку ─────────────────────────────────────────
      'app_title': 'KlimaBox',

      // ── Статус підключення MQTT ───────────────────────────────
      'connected':        'ПІДКЛЮЧЕНО',
      'connecting':       'З\'ЄДНАННЯ…',
      'connection_error': 'ПОМИЛКА З\'ЄДНАННЯ',
      'disconnected':     'ВІДКЛЮЧЕНО',
      'link_error':       'ПОМИЛКА ЗВ\'ЯЗКУ',
      'live':             'НАЖИВО',

      // ── Головний екран ────────────────────────────────────────
      'real_time_telemetry': 'РЕАЛЬНИЙ ЧАС',
      'realtime_subtitle':
          'Дані сенсорів передаються через MQTT і зберігаються локально для аналітики та експорту.',
      'last_update': 'ОСТАННЄ ОНОВЛЕННЯ',

      // ── Картки сенсорів ───────────────────────────────────────
      'temperature':      'ТЕМПЕРАТУРА',
      'humidity':         'ВОЛОГІСТЬ',
      'ok':               'OK',
      'alarm':            'УВАГА',
      'range':            'МЕЖІ',
      'tap_for_analytics':'ТОРКНІТЬСЯ ДЛЯ АНАЛІТИКИ',

      // ── Бокове меню (Drawer) ──────────────────────────────────
      'main_menu':          'ГОЛОВНЕ МЕНЮ',
      'export_section':     'ЕКСПОРТ',
      'limits_settings':    'Налаштування',
      'event_log':          'Журнал',
      'analytics':          'Аналітика',
      'download_csv':       'Завантажити CSV',
      'download_csv_sub':   'ЕКСПОРТ ДАНИХ',

      // ── Профіль користувача ───────────────────────────────────
      'user_name':  'Мунтян Роман',
      'user_group': '41-КІ',
      'online':     'ОНЛАЙН',

      // ── Аркуш налаштувань ─────────────────────────────────────
      'settings_title': 'НАЛАШТУВАННЯ',
      'reset':          'СКИНУТИ',
      'language':       'МОВА',
      'theme':          'ТЕМА',
      'light':          'СВІТЛА',
      'dark':           'ТЕМНА',

      // ── Скидання WiFi через додаток ───────────────────────────
      'reset_wifi_btn':     'СКИНУТИ WIFI',
      'reset_wifi_title':   'Скинути WiFi?',
      'reset_wifi_confirm':
          'ESP32 перезавантажиться і відкриє точку доступу KlimaBox-Setup. Потрібно буде підключитись заново.',
      'confirm': 'СКИНУТИ',
      'cancel':  'СКАСУВАТИ',

      // ── Сповіщення (push-алерти) ──────────────────────────────
      'alert_temp_title': 'Температура',
      'alert_hum_title':  'Вологість',
      'temp_high': 'Температура перевищує заданий ліміт.',
      'temp_low':  'Температура нижче заданого ліміту.',
      'hum_high':  'Вологість перевищує заданий ліміт.',
      'hum_low':   'Вологість нижче заданого ліміту.',

      // ── Аналітика ─────────────────────────────────────────────
      'analytics_title': 'АНАЛІТИКА',
      'last_samples':    'ОСТАННІ 20 ЗАМІРІВ',
      'temp_now':        'ТЕМП. ЗАРАЗ',
      'hum_now':         'ВОЛ. ЗАРАЗ',
      'temp_avg':        'ТЕМП. СЕРЕД.',
      'hum_avg':         'ВОЛ. СЕРЕД.',
      'timeline':        'ТАЙМЛАЙН',
      'temp_short':      'ТЕМП',
      'hum_short':       'ВОЛ',
      'tap_chart_point': 'Торкніться графіка для точного значення',
      'no_data_yet':     'ЩЕ НЕМАЄ ДАНИХ',
      'waiting_telemetry':'Очікування даних з сенсорів…',

      // ── Журнал даних ──────────────────────────────────────────
      'log_title':           'ЖУРНАЛ',
      'event_log_telemetry': 'ТЕЛЕМЕТРІЯ',
      'filter_by_type':      'ФІЛЬТР ЗА ТИПОМ',
      'all':                 'ВСІ',
      'any_date':            'БУДЬ-ЯКА ДАТА',
      'today':               'Сьогодні',
      'no_records':          'НЕМАЄ ЗАПИСІВ',
      'records_appear':      'Записи з\'являться тут після фіксації телеметрії',
      'entries':             'ЗАПИСІВ',
      'delete':              'ВИДАЛИТИ',
      'record_deleted':      'ЗАПИС ВИДАЛЕНО',
      'temperature_label':   'ТЕМПЕРАТУРА',
      'humidity_label':      'ВОЛОГІСТЬ',
      'error':               'ПОМИЛКА',
      'info':                'ІНФО',
      'snack_ok':            'OK',

      // ── Очищення журналу ──────────────────────────────────────
      'clear_all':           'ОЧИСТИТИ',
      'confirm_delete_title':'ВИДАЛИТИ ВСІ ЛОГИ?',
      'confirm_delete_msg':
          'Цю дію неможливо скасувати. Усі записи журналу будуть видалені назавжди.',
      'confirm_delete':   'ВИДАЛИТИ',
      'all_logs_cleared': 'УСІ ЛОГИ ВИДАЛЕНО',

      // ── Експорт ───────────────────────────────────────────────
      'log_empty_msg': 'Журнал порожній. Немає даних для завантаження.',
    },

    // ══════════════════════════════════════════════════════════════
    // АНГЛІЙСЬКА
    // ══════════════════════════════════════════════════════════════
    'en': {

      // ── Назва додатку ─────────────────────────────────────────
      'app_title': 'KlimaBox',

      // ── Статус підключення MQTT ───────────────────────────────
      'connected':        'CONNECTED',
      'connecting':       'CONNECTING…',
      'connection_error': 'CONNECTION ERROR',
      'disconnected':     'DISCONNECTED',
      'link_error':       'LINK ERROR',
      'live':             'LIVE',

      // ── Головний екран ────────────────────────────────────────
      'real_time_telemetry': 'REAL-TIME TELEMETRY',
      'realtime_subtitle':
          'Sensor data is streamed over MQTT and stored locally for analytics & export.',
      'last_update': 'LAST UPDATE',

      // ── Картки сенсорів ───────────────────────────────────────
      'temperature':      'TEMPERATURE',
      'humidity':         'HUMIDITY',
      'ok':               'OK',
      'alarm':            'WARNING',
      'range':            'RANGE',
      'tap_for_analytics':'TAP FOR ANALYTICS',

      // ── Бокове меню (Drawer) ──────────────────────────────────
      'main_menu':          'MAIN MENU',
      'export_section':     'EXPORT',
      'limits_settings':    'Settings',
      'event_log':          'Log',
      'analytics':          'Analytics',
      'download_csv':       'Download CSV',
      'download_csv_sub':   'EXPORT DATA',

      // ── Профіль користувача ───────────────────────────────────
      'user_name':  'Muntian Roman',
      'user_group': '41-КІ',
      'online':     'ONLINE',

      // ── Аркуш налаштувань ─────────────────────────────────────
      'settings_title': 'SETTINGS',
      'reset':          'RESET',
      'language':       'LANGUAGE',
      'theme':          'THEME',
      'light':          'LIGHT',
      'dark':           'DARK',

      // ── Скидання WiFi через додаток ───────────────────────────
      'reset_wifi_btn':     'RESET WIFI',
      'reset_wifi_title':   'Reset WiFi?',
      'reset_wifi_confirm':
          'ESP32 will restart and open KlimaBox-Setup hotspot. You will need to reconnect.',
      'confirm': 'RESET',
      'cancel':  'CANCEL',

      // ── Сповіщення (push-алерти) ──────────────────────────────
      'alert_temp_title': 'Temperature',
      'alert_hum_title':  'Humidity',
      'temp_high': 'Temperature is above the set limit.',
      'temp_low':  'Temperature is below the set limit.',
      'hum_high':  'Humidity is above the set limit.',
      'hum_low':   'Humidity is below the set limit.',

      // ── Аналітика ─────────────────────────────────────────────
      'analytics_title': 'ANALYTICS',
      'last_samples':    'LAST 20 SAMPLES PER METRIC',
      'temp_now':        'TEMP NOW',
      'hum_now':         'HUM NOW',
      'temp_avg':        'TEMP AVG',
      'hum_avg':         'HUM AVG',
      'timeline':        'TIMELINE',
      'temp_short':      'TEMP',
      'hum_short':       'HUM',
      'tap_chart_point': 'Tap any chart point for exact reading',
      'no_data_yet':     'NO DATA YET',
      'waiting_telemetry':'Waiting for sensor telemetry…',

      // ── Журнал даних ──────────────────────────────────────────
      'log_title':           'LOG',
      'event_log_telemetry': 'TELEMETRY',
      'filter_by_type':      'FILTER BY TYPE',
      'all':                 'ALL',
      'any_date':            'ANY DATE',
      'today':               'Today',
      'no_records':          'NO RECORDS',
      'records_appear':      'Records will appear here once telemetry is captured',
      'entries':             'ENTRIES',
      'delete':              'DELETE',
      'record_deleted':      'RECORD DELETED',
      'temperature_label':   'TEMPERATURE',
      'humidity_label':      'HUMIDITY',
      'error':               'ERROR',
      'info':                'INFO',
      'snack_ok':            'OK',

      // ── Очищення журналу ──────────────────────────────────────
      'clear_all':           'CLEAR ALL',
      'confirm_delete_title':'DELETE ALL LOGS?',
      'confirm_delete_msg':
          'This action cannot be undone. All log entries will be permanently deleted.',
      'confirm_delete':   'DELETE',
      'all_logs_cleared': 'ALL LOGS CLEARED',

      // ── Експорт ───────────────────────────────────────────────
      'log_empty_msg': 'Log is empty. No data to download.',
    },
  };

  /// Повертає переклад за ключем і кодом мови.
  /// Якщо ключ відсутній — повертає українську версію.
  /// Якщо і там немає — повертає сам ключ.
  static String tr(String key, String langCode) {
    final code = supported.contains(langCode) ? langCode : fallback;
    return _strings[code]?[key] ?? _strings[fallback]?[key] ?? key;
  }
}