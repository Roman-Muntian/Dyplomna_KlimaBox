#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <PubSubClient.h>
#include <DHT.h>
#include <Preferences.h>
#include <DNSServer.h>

// ── Датчик ──────────────────────────────────────────────────────────
#define DHTPIN 15
#define DHTTYPE DHT21
DHT dht(DHTPIN, DHTTYPE);

// ── HiveMQ Cloud — захищений брокер ─────────────────────────────────
const char* mqtt_server = "5753b29c6fa34437914a4f06883b6437.s1.eu.hivemq.cloud";
const int   mqtt_port   = 8883;
const char* mqtt_user   = "esp32_klimabox";
const char* mqtt_pass   = "Esp32_KlimaBox_2026";

// ── MQTT топіки ──────────────────────────────────────────────────────
#define TOPIC_TEMP   "klimabox/temp"
#define TOPIC_HUM    "klimabox/hum"
#define TOPIC_STATUS "klimabox/status"
#define TOPIC_CMD    "klimabox/cmd"

WiFiClientSecure espClient;
PubSubClient client(espClient);
Preferences prefs;
WiFiServer server(80);
DNSServer dns;

String savedSSID;
String savedPass;
String portalLang     = "uk";
String cachedNetworks = "";

// ── Переклади порталу ────────────────────────────────────────────────
struct Lang {
  const char* title;
  const char* networkLabel;
  const char* passwordLabel;
  const char* passwordPlaceholder;
  const char* saveBtn;
  const char* successMsg;
  const char* errorMsg;
};

const Lang UK = {
  "KlimaBox Налаштування",
  "МЕРЕЖА WiFi",
  "ПАРОЛЬ",
  "Введіть пароль",
  "ЗБЕРЕГТИ І ПІДКЛЮЧИТИ",
  "Збережено! ESP32 перезавантажується...",
  "Не вдалось підключитись. Перевірте пароль і спробуйте ще раз."
};

const Lang EN = {
  "KlimaBox Setup",
  "WiFi NETWORK",
  "PASSWORD",
  "Enter password",
  "SAVE AND CONNECT",
  "Saved! ESP32 is restarting...",
  "Connection failed. Check your password and try again."
};

Lang getLang() {
  return portalLang == "uk" ? UK : EN;
}

// ── URL decode ───────────────────────────────────────────────────────
String urlDecode(String input) {
  String decoded = "";
  for (int i = 0; i < input.length(); i++) {
    if (input[i] == '+') {
      decoded += ' ';
    } else if (input[i] == '%' && i + 2 < input.length()) {
      String hex = input.substring(i + 1, i + 3);
      decoded += (char)strtol(hex.c_str(), nullptr, 16);
      i += 2;
    } else {
      decoded += input[i];
    }
  }
  return decoded;
}

// ── Сканування WiFi мереж (кешується) ───────────────────────────────
void scanNetworks() {
  int n = WiFi.scanNetworks();
  cachedNetworks = "";
  for (int i = 0; i < n; i++) {
    cachedNetworks += "<option value='" + WiFi.SSID(i) + "'>" + WiFi.SSID(i) + "</option>";
  }
}

// ── MQTT callback — отримання команд з додатку ───────────────────────
void mqttCallback(char* topic, byte* payload, unsigned int length) {
  String msg = "";
  for (int i = 0; i < length; i++) msg += (char)payload[i];
  Serial.println("Команда: " + msg);

  // Скидання WiFi налаштувань через додаток
  if (String(topic) == TOPIC_CMD && msg == "reset_wifi") {
    Serial.println("Скидання WiFi...");
    prefs.begin("wifi", false);
    prefs.clear();
    prefs.end();
    delay(500);
    ESP.restart();
  }
}

// ── HTML портал налаштування WiFi ────────────────────────────────────
String getHTML(String message = "", String msgType = "") {
  Lang l = getLang();
  String otherLang      = portalLang == "uk" ? "en" : "uk";
  String otherLangLabel = portalLang == "uk" ? "EN" : "UK";

  String msgHTML = "";
  if (message != "") {
    String bgColor   = msgType == "error" ? "#FF3B3B" : "#00FF90";
    String textColor = msgType == "error" ? "#fff" : "#000";
    msgHTML = "<div class='msg' style='background:" + bgColor + ";color:" + textColor + "'>" + message + "</div>";
  }

  String html = "<!DOCTYPE html><html><head>";
  html += "<meta charset='utf-8'>";
  html += "<meta name='viewport' content='width=device-width, initial-scale=1'>";
  html += "<title>" + String(l.title) + "</title>";
  html += "<style>";
  html += "body{font-family:sans-serif;background:#f4f4f4;display:flex;justify-content:center;padding:40px 20px;}";
  html += ".card{background:#fff;border:2.5px solid #000;box-shadow:5px 5px 0 #000;padding:30px;width:100%;max-width:400px;}";
  html += "h1{font-size:22px;margin:0 0 20px;}";
  html += "label{font-size:12px;font-weight:bold;letter-spacing:1px;display:block;margin-bottom:6px;}";
  html += "select,input{width:100%;padding:10px;border:2px solid #000;font-size:16px;margin-bottom:16px;box-sizing:border-box;}";
  html += "button{width:100%;padding:12px;background:#0055FF;color:#fff;border:2.5px solid #000;font-size:16px;font-weight:bold;cursor:pointer;box-shadow:3px 3px 0 #000;}";
  html += ".msg{border:2px solid #000;padding:10px;margin-bottom:16px;font-weight:bold;}";
  html += ".lang{display:flex;justify-content:flex-end;margin-bottom:16px;}";
  html += ".lang a{text-decoration:none;background:#000;color:#fff;padding:4px 10px;font-size:12px;font-weight:bold;letter-spacing:1px;}";
  html += "</style></head><body><div class='card'>";
  html += "<div class='lang'><a href='/lang?l=" + otherLang + "'>" + otherLangLabel + "</a></div>";
  html += "<h1>" + String(l.title) + "</h1>";
  html += msgHTML;
  html += "<form method='POST' action='/save'>";
  html += "<label>" + String(l.networkLabel) + "</label>";
  html += "<select name='ssid'>" + cachedNetworks + "</select>";
  html += "<label>" + String(l.passwordLabel) + "</label>";
  html += "<input type='password' name='pass' placeholder='" + String(l.passwordPlaceholder) + "'>";
  html += "<button type='submit'>" + String(l.saveBtn) + "</button>";
  html += "</form></div></body></html>";
  return html;
}

// ── Відправити HTML відповідь ────────────────────────────────────────
void sendHTML(WiFiClient& wc, String html) {
  wc.println("HTTP/1.1 200 OK");
  wc.println("Content-Type: text/html; charset=utf-8");
  wc.println();
  wc.println(html);
  wc.stop();
}

void sendRedirect(WiFiClient& wc, String url) {
  wc.println("HTTP/1.1 302 Found");
  wc.println("Location: " + url);
  wc.println();
  wc.stop();
}

// ── Портал налаштування WiFi ─────────────────────────────────────────
void startConfigPortal(bool wrongPassword = false) {
  Serial.println("Запуск порталу налаштування...");

  WiFi.mode(WIFI_AP);
  WiFi.softAP("KlimaBox-Setup", "klimabox123");
  Serial.println("AP: KlimaBox-Setup / klimabox123");

  dns.start(53, "*", WiFi.softAPIP());
  server.begin();
  scanNetworks();

  String initMsg  = wrongPassword ? getLang().errorMsg : "";
  String initType = wrongPassword ? "error" : "";

  while (true) {
    dns.processNextRequest();

    WiFiClient webClient = server.accept();
    if (!webClient) continue;

    String request = "";
    while (webClient.connected()) {
      if (webClient.available()) {
        char c = webClient.read();
        request += c;
        if (request.endsWith("\r\n\r\n")) break;
      }
    }

    delay(10);
    String body = "";
    while (webClient.available()) {
      body += (char)webClient.read();
    }

    // Зміна мови порталу
    if (request.indexOf("GET /lang") != -1) {
      int lPos = request.indexOf("?l=");
      if (lPos != -1) {
        String newLang = request.substring(lPos + 3, lPos + 5);
        newLang.trim();
        if (newLang == "uk" || newLang == "en") portalLang = newLang;
      }
      sendRedirect(webClient, "http://192.168.4.1/");
      continue;
    }

    // Збереження мережі з перевіркою пароля
    if (request.startsWith("POST /save")) {
      String ssid = "", pass = "";

      int s = body.indexOf("ssid=");
      int p = body.indexOf("&pass=");

      if (s != -1) {
        int end = body.indexOf("&", s);
        ssid = body.substring(s + 5, end == -1 ? body.length() : end);
      }
      if (p != -1) {
        pass = body.substring(p + 6);
      }

      ssid = urlDecode(ssid);
      pass = urlDecode(pass);

      Serial.println("Спроба підключення до: " + ssid);

      // AP залишається активним, додаємо STA для перевірки
      WiFi.mode(WIFI_AP_STA);
      WiFi.begin(ssid.c_str(), pass.c_str());

      int tries = 0;
      while (WiFi.status() != WL_CONNECTED && tries < 20) {
        delay(500);
        Serial.print(".");
        tries++;
      }

      if (WiFi.status() == WL_CONNECTED) {
        Serial.println("\nПідключено! Зберігаємо...");
        prefs.begin("wifi", false);
        prefs.putString("ssid", ssid);
        prefs.putString("pass", pass);
        prefs.end();
        sendHTML(webClient, getHTML(getLang().successMsg, "success"));
        delay(2000);
        ESP.restart();
      } else {
        Serial.println("\nПомилка підключення!");
        WiFi.disconnect();
        WiFi.mode(WIFI_AP);
        WiFi.softAP("KlimaBox-Setup", "klimabox123");
        sendHTML(webClient, getHTML(getLang().errorMsg, "error"));
      }
      continue;
    }

    // Captive portal — перенаправлення на головну
    if (!request.startsWith("GET / ") && request.indexOf("GET /lang") == -1) {
      sendRedirect(webClient, "http://192.168.4.1/");
      continue;
    }

    // Головна сторінка порталу
    sendHTML(webClient, getHTML(initMsg, initType));
    initMsg  = "";
    initType = "";
  }
}

// ── MQTT підключення і підписка на команди ───────────────────────────
void reconnect() {
  while (!client.connected()) {
    String clientId = "ESP32_KlimaBox_" + WiFi.macAddress();
    Serial.print("Підключення до MQTT...");
    if (client.connect(clientId.c_str(), mqtt_user, mqtt_pass,
                       TOPIC_STATUS, 1, true, "offline")) {
      client.publish(TOPIC_STATUS, "online", true);
      client.subscribe(TOPIC_CMD);
      Serial.println(" Підключено!");
    } else {
      Serial.print(" помилка rc=");
      Serial.println(client.state());
      delay(5000);
    }
  }
}

void setup() {
  Serial.begin(115200);
  dht.begin();

  // Читаємо збережені WiFi налаштування
  prefs.begin("wifi", true);
  savedSSID = prefs.getString("ssid", "");
  savedPass = prefs.getString("pass", "");
  prefs.end();

  Serial.println("Збережений SSID: " + savedSSID);

  // Якщо немає збережених — запускаємо портал
  if (savedSSID == "") {
    startConfigPortal();
    return;
  }

  // Підключення до збереженої мережі
  Serial.println("Підключення до: " + savedSSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(savedSSID.c_str(), savedPass.c_str());

  int tries = 0;
  while (WiFi.status() != WL_CONNECTED && tries < 20) {
    delay(500);
    Serial.print(".");
    tries++;
  }

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("\nНе вдалось підключитись — запуск порталу");
    startConfigPortal(true);
    return;
  }

  Serial.println("\nWiFi підключено: " + WiFi.localIP().toString());

  // HiveMQ Cloud використовує TLS — setInsecure() для спрощеного з'єднання
  espClient.setInsecure();
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(mqttCallback);
}

void loop() {
  if (!client.connected()) reconnect();
  client.loop();

  // Публікація даних кожні 5 секунд
  static unsigned long lastMsg = 0;
  if (millis() - lastMsg > 5000) {
    lastMsg = millis();

    float h = dht.readHumidity();
    float t = dht.readTemperature();

    if (!isnan(h) && !isnan(t)) {
      client.publish(TOPIC_TEMP, String(t, 1).c_str());
      client.publish(TOPIC_HUM,  String(h, 1).c_str());
      Serial.printf("T:%.1f H:%.1f\n", t, h);
    } else {
      Serial.println("Помилка DHT!");
    }
  }
}
