# 🌡️ KlimaBox — IoT моніторинг температури та вологості

[🇺🇦 Українська](#-українська) | [🇬🇧 English](#-english)

Кросплатформний мобільний додаток на **Flutter** для дистанційного моніторингу температури та вологості в реальному часі. Дані надходять з апаратного вузла на базі **ESP32-C6** через захищений **MQTT TLS**-канал і хмарний брокер **HiveMQ Cloud**.

---

## 🇺🇦 Українська

### ✨ Особливості

- **📡 Моніторинг у реальному часі** — оновлення показників кожні 5 секунд через MQTT
- **🔒 Захищене з'єднання** — MQTT поверх TLS (порт 8883), роздільна автентифікація для пристрою та додатка
- **🔔 Push-сповіщення** — система алармів з налаштовуваними межами та кулдауном 5 хвилин
- **📶 Captive Portal** — налаштування Wi-Fi на ESP32 без перепрошивки, через вбудований веб-портал
- **💾 Локальний журнал** — історія вимірювань у SQLite з фільтрацією та експортом у CSV
- **📊 Аналітика** — графіки динаміки температури та вологості (fl_chart)
- **🌍 Локалізація** — підтримка української та англійської мов
- **🌙 Темна тема** — перемикання Light/Dark у налаштуваннях
- **🎨 Neo-Brutalist дизайн** — яскравий, контрастний інтерфейс з товстими рамками та жорсткими тінями

### 🏗️ Архітектура

```
📦 KlimaBox
├── 📟 Апаратний вузол (ESP32-C6 + AM2302/DHT22)
│   ├── Captive Portal для налаштування WiFi
│   ├── MQTT TLS клієнт (PubSubClient)
│   └── Публікація даних кожні 5 секунд
│
├── ☁️ MQTT-брокер (HiveMQ Cloud)
│   ├── TLS 8883
│   ├── Окремі облікові записи: ESP32 / Flutter
│   └── Last Will Testament (online/offline)
│
└── 📱 Мобільний додаток (Flutter)
    ├── MqttService — підключення, watchdog, авторетрай
    ├── DbService — локальний журнал (SQLite)
    ├── SettingsService — пороги алармів
    ├── NotificationService — push-сповіщення
    └── Neo-Brutalist UI (UK/EN, Light/Dark)
```

### 🛠 Технологічний стек

| Компонент | Технологія |
|---|---|
| Мобільний додаток | **Flutter / Dart** |
| Прошивка | **C++ (Arduino IDE, ESP32-C6)** |
| Датчик | **AM2302 (DHT22)** |
| Протокол передачі | **MQTT 3.1.1 / TLS** |
| Брокер | **HiveMQ Cloud** |
| Локальна БД | **SQLite (sqflite)** |
| Графіки | **fl_chart** |
| Сповіщення | **flutter_local_notifications** |

### 📡 MQTT-топіки

```
klimabox/temp     ESP32 → App     Значення температури, °C
klimabox/hum      ESP32 → App     Відносна вологість, %
klimabox/status   ESP32 → Broker  online / offline (LWT)
klimabox/cmd      App → ESP32     Команди (reset_wifi)
```

### 🚀 Швидкий старт

#### 1. Прошивка ESP32

1. Встановіть **Arduino IDE 2.x** та плату **ESP32 (esp32 v3.x)**
2. Встановіть бібліотеки: `PubSubClient`, `DHT sensor library`
3. Підключіть датчик AM2302 до **GPIO15** (VCC → 3.3V, GND → GND)
4. Відкрийте `sketch.ino`, вкажіть свої дані HiveMQ Cloud
5. Завантажте прошивку на ESP32-C6

#### 2. Налаштування HiveMQ Cloud

1. Зареєструйтеся на [console.hivemq.cloud](https://console.hivemq.cloud)
2. Створіть безкоштовний кластер (Serverless)
3. Створіть двох користувачів: `esp32_klimabox` та `flutter_klimabox`
4. Скопіюйте URL кластера у прошивку та у `mqtt_service.dart`

#### 3. Перше підключення до WiFi

1. Увімкніть ESP32 — з'явиться точка доступу **KlimaBox-Setup**
2. Підключіться до неї (пароль: `klimabox123`)
3. У браузері відкриється портал — оберіть мережу та введіть пароль
4. ESP32 перезавантажиться та підключиться до HiveMQ Cloud

#### 4. Мобільний додаток

```bash
flutter pub get
flutter run
```

### 📂 Структура проєкту

```
KlimaBox/
├── lib/
│   ├── main.dart                    # Точка входу, MaterialApp, тема, локалізація
│   ├── splash_screen.dart           # Анімований екран завантаження (1.8 сек)
│   ├── dashboard_screen.dart        # Головний екран з картками сенсорів
│   ├── analytics_screen.dart        # Графіки та KPI (fl_chart)
│   ├── log_screen.dart              # Журнал телеметрії (SQLite)
│   ├── mqtt_service.dart            # MQTT-клієнт (HiveMQ Cloud, TLS)
│   ├── db_service.dart              # SQLite сховище (sqflite)
│   ├── settings_service.dart        # Пороги алармів (SharedPreferences)
│   ├── notification_service.dart    # Push-сповіщення
│   ├── export_service.dart          # CSV-генератор та share_plus
│   ├── app_state.dart               # Мова, тема (ChangeNotifier)
│   ├── i18n/
│   │   └── app_strings.dart         # Словник UK/EN перекладів
│   ├── theme/
│   │   └── neo_brutalist_theme.dart # NB.* токени, nbBlock() хелпер
│   └── widgets/
│       ├── alarm_overlay.dart        # Банери тривоги знизу екрана
│       ├── app_bar.dart              # Верхня панель з кнопкою меню
│       ├── confirm_dialog.dart       # Діалог підтвердження небезпечної дії
│       ├── connection_status_strip.dart # Індикатор стану MQTT-підключення
│       ├── dashboard_drawer.dart     # Бокове меню (навігація + експорт)
│       ├── last_update_widget.dart   # Плашка часу останнього оновлення
│       ├── neo_button.dart           # Кнопка з анімацією натискання
│       ├── neo_card.dart             # Картка з рамкою та тінню
│       ├── neo_decorations.dart      # NeoTag, NeoIconBox, NeoSectionHeader
│       ├── neo_primitives.dart       # Barrel-файл (реекспорт компонентів)
│       ├── range_slider.dart         # Повзунок діапазону для порогів
│       ├── sensor_card.dart          # Картка сенсора (температура/вологість)
│       ├── settings_sheet.dart       # Нижній аркуш налаштувань
│       └── toggle.dart               # Перемикач двох станів (UK/EN, Light/Dark)
│
├── android/                  # Нативний Android-проєкт (com.klimabox.app)
├── ios/                       # Нативний iOS-проєкт (LaunchScreen, Runner)
├── assets/
│   ├── fonts/                 # Unbounded, Manrope, JetBrains Mono
│   └── icons/                 # icon.png, icon_splash.png, icon_foreground.png
│
├── sketch.ino                 # Прошивка ESP32-C6 (Captive Portal + MQTT TLS)
├── pubspec.yaml                # Залежності та ресурси Flutter
├── analysis_options.yaml       # Правила лінтера Dart
├── .gitignore
└── README.md
```

### 💰 Вартість апаратної частини

Орієнтовна вартість збірки ESP32-C6 + AM2302 (DHT22): **300–600 грн**.

---

## 🇬🇧 English

A cross-platform **Flutter** mobile app for real-time remote monitoring of temperature and humidity. Data comes from an **ESP32-C6**-based hardware node over a secure **MQTT TLS** connection via **HiveMQ Cloud**.

### ✨ Features

- **📡 Real-time monitoring** — readings update every 5 seconds over MQTT
- **🔒 Secure connection** — MQTT over TLS (port 8883), separate credentials for device and app
- **🔔 Push notifications** — alarm system with configurable thresholds and a 5-minute cooldown
- **📶 Captive Portal** — configure ESP32 WiFi without reflashing, via a built-in web portal
- **💾 Local log** — measurement history in SQLite with filtering and CSV export
- **📊 Analytics** — temperature and humidity trend charts (fl_chart)
- **🌍 Localization** — Ukrainian and English support
- **🌙 Dark theme** — Light/Dark switch in settings
- **🎨 Neo-Brutalist design** — bold, high-contrast UI with thick borders and hard shadows

### 🏗️ Architecture

```
📦 KlimaBox
├── 📟 Hardware node (ESP32-C6 + AM2302/DHT22)
│   ├── Captive Portal for WiFi setup
│   ├── MQTT TLS client (PubSubClient)
│   └── Publishes data every 5 seconds
│
├── ☁️ MQTT broker (HiveMQ Cloud)
│   ├── TLS 8883
│   ├── Separate credentials: ESP32 / Flutter
│   └── Last Will Testament (online/offline)
│
└── 📱 Mobile app (Flutter)
    ├── MqttService — connection, watchdog, auto-retry
    ├── DbService — local log (SQLite)
    ├── SettingsService — alarm thresholds
    ├── NotificationService — push notifications
    └── Neo-Brutalist UI (UK/EN, Light/Dark)
```

### 🛠 Tech stack

| Component | Technology |
|---|---|
| Mobile app | **Flutter / Dart** |
| Firmware | **C++ (Arduino IDE, ESP32-C6)** |
| Sensor | **AM2302 (DHT22)** |
| Transport protocol | **MQTT 3.1.1 / TLS** |
| Broker | **HiveMQ Cloud** |
| Local DB | **SQLite (sqflite)** |
| Charts | **fl_chart** |
| Notifications | **flutter_local_notifications** |

### 📡 MQTT topics

```
klimabox/temp     ESP32 → App     Temperature value, °C
klimabox/hum      ESP32 → App     Relative humidity, %
klimabox/status   ESP32 → Broker  online / offline (LWT)
klimabox/cmd      App → ESP32     Commands (reset_wifi)
```

### 🚀 Quick start

#### 1. ESP32 firmware

1. Install **Arduino IDE 2.x** with the **ESP32 board package (v3.x)**
2. Install libraries: `PubSubClient`, `DHT sensor library`
3. Wire the AM2302 sensor to **GPIO15** (VCC → 3.3V, GND → GND)
4. Open `sketch.ino` and set your HiveMQ Cloud credentials
5. Flash the firmware to the ESP32-C6

#### 2. HiveMQ Cloud setup

1. Sign up at [console.hivemq.cloud](https://console.hivemq.cloud)
2. Create a free Serverless cluster
3. Create two users: `esp32_klimabox` and `flutter_klimabox`
4. Copy the cluster URL into the firmware and `mqtt_service.dart`

#### 3. First WiFi connection

1. Power on the ESP32 — an access point **KlimaBox-Setup** will appear
2. Connect to it (password: `klimabox123`)
3. A setup portal opens in the browser — select a network and enter the password
4. The ESP32 restarts and connects to HiveMQ Cloud

#### 4. Mobile app

```bash
flutter pub get
flutter run
```

### 📂 Project structure

```
KlimaBox/
├── lib/
│   ├── main.dart                    # Entry point, MaterialApp, theme, localization
│   ├── splash_screen.dart           # Animated splash screen (1.8 sec)
│   ├── dashboard_screen.dart        # Main screen with sensor cards
│   ├── analytics_screen.dart        # Charts and KPIs (fl_chart)
│   ├── log_screen.dart              # Telemetry log (SQLite)
│   ├── mqtt_service.dart            # MQTT client (HiveMQ Cloud, TLS)
│   ├── db_service.dart              # SQLite storage (sqflite)
│   ├── settings_service.dart        # Alarm thresholds (SharedPreferences)
│   ├── notification_service.dart    # Push notifications
│   ├── export_service.dart          # CSV generator and share_plus
│   ├── app_state.dart               # Language, theme (ChangeNotifier)
│   ├── i18n/
│   │   └── app_strings.dart         # UK/EN translation dictionary
│   ├── theme/
│   │   └── neo_brutalist_theme.dart # NB.* design tokens, nbBlock() helper
│   └── widgets/
│       ├── alarm_overlay.dart        # Alert banners at the bottom of the screen
│       ├── app_bar.dart              # Top bar with menu button
│       ├── confirm_dialog.dart       # Confirmation dialog for risky actions
│       ├── connection_status_strip.dart # MQTT connection status indicator
│       ├── dashboard_drawer.dart     # Side menu (navigation + export)
│       ├── last_update_widget.dart   # Last-update timestamp strip
│       ├── neo_button.dart           # Button with press animation
│       ├── neo_card.dart             # Card with border and shadow
│       ├── neo_decorations.dart      # NeoTag, NeoIconBox, NeoSectionHeader
│       ├── neo_primitives.dart       # Barrel file (re-exports)
│       ├── range_slider.dart         # Range slider for thresholds
│       ├── sensor_card.dart          # Sensor card (temperature/humidity)
│       ├── settings_sheet.dart       # Bottom settings sheet
│       └── toggle.dart               # Two-state toggle (UK/EN, Light/Dark)
│
├── android/                  # Native Android project (com.klimabox.app)
├── ios/                       # Native iOS project (LaunchScreen, Runner)
├── assets/
│   ├── fonts/                 # Unbounded, Manrope, JetBrains Mono
│   └── icons/                 # icon.png, icon_splash.png, icon_foreground.png
│
├── sketch.ino                 # ESP32-C6 firmware (Captive Portal + MQTT TLS)
├── pubspec.yaml                # Flutter dependencies and assets
├── analysis_options.yaml       # Dart linter rules
├── .gitignore
└── README.md
```

### 💰 Hardware cost

Estimated build cost for ESP32-C6 + AM2302 (DHT22): **300–600 UAH**.
