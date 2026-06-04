# KlimaBox

Мобільний додаток для моніторингу температури і вологості в реальному часі через MQTT.

## Стек

| Компонент | Технологія |
|-----------|-----------|
| Мобільний додаток | Flutter (Android / iOS) |
| Датчик | ESP32-C6 + AM2301 (DHT21) |
| Брокер | HiveMQ Cloud (TLS 8883) |
| Протокол | MQTT 3.1.1 |
| БД | SQLite (sqflite) |

## Структура проекту

```
lib/
├── main.dart                  # Точка входу, тема, локалізація
├── splash_screen.dart         # Екран завантаження
├── dashboard_screen.dart      # Головний екран
├── analytics_screen.dart      # Аналітика і графіки
├── log_screen.dart            # Журнал телеметрії
├── mqtt_service.dart          # MQTT підключення і обробка даних
├── db_service.dart            # SQLite сховище
├── settings_service.dart      # Порогові значення алармів
├── notification_service.dart  # Push-сповіщення
├── export_service.dart        # Експорт CSV
├── app_state.dart             # Мова і тема (ChangeNotifier)
├── i18n/app_strings.dart      # Переклади UK / EN
├── theme/                     # Neo-Brutalist дизайн-система
└── widgets/                   # UI компоненти

sketch.ino                     # Прошивка ESP32
```

## Запуск

```bash
flutter pub get
flutter run
```

## Налаштування ESP32

При першому запуску ESP32 піднімає точку доступу **KlimaBox-Setup** (пароль: `klimabox123`).
Підключіться до неї — браузер автоматично відкриє портал налаштування WiFi.

## Функціонал

- Відображення температури і вологості в реальному часі
- Аларми при виході за задані межі (push-сповіщення)
- Журнал телеметрії з фільтрацією і експортом CSV
- Графіки аналітики (останні 20 замірів)
- Перемикання мови (UK / EN) і теми (Light / Dark)
- Скидання WiFi налаштувань ESP32 через додаток