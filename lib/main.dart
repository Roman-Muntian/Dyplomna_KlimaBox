// =====================================================================
//  ТОЧКА ВХОДУ — KlimaBox
//
//  Послідовність запуску:
//  1. ShaderWarmUp  — прогрів GPU шейдерів (усуває лаги першого кадру)
//  2. AppState.load — завантаження збережених налаштувань (мова, тема)
//  3. MyApp         — запуск Flutter додатку
// =====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_state.dart';
import 'splash_screen.dart';
import 'theme/neo_brutalist_theme.dart';

// ── Прогрів GPU шейдерів ─────────────────────────────────────────────
// Малює типові фігури додатку до першого кадру щоб GPU
// скомпілював шейдери заздалегідь і прибрав лаг при відкритті меню.
class _AppShaderWarmUp extends ShaderWarmUp {
  const _AppShaderWarmUp();

  @override
  Future<void> warmUpOnCanvas(Canvas canvas) async {
    final fill = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    // Картка (rounded rect)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 300, 80),
        const Radius.circular(8),
      ),
      fill,
    );

    // Тінь картки (hard shadow)
    canvas.drawRect(
      const Rect.fromLTWH(4, 4, 300, 80),
      Paint()..color = const Color(0xFF000000),
    );

    // Кнопка (синій rounded rect)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 100, 200, 44),
        const Radius.circular(4),
      ),
      fill..color = const Color(0xFF0055FF),
    );

    // Рамка (border line)
    canvas.drawLine(
      const Offset(0, 200),
      const Offset(300, 200),
      Paint()
        ..color = const Color(0xFF000000)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );
  }
}

// ── Запуск додатку ───────────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Прогріваємо шейдери до першого кадру
  await const _AppShaderWarmUp().execute();

  // Завантажуємо збережені налаштування (мова, тема)
  await AppState.instance.load();

  runApp(const MyApp());
}

// ── Кореневий віджет ─────────────────────────────────────────────────
// AnimatedBuilder слухає AppState — при зміні мови або теми
// перебудовує MaterialApp з новими параметрами.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState.instance,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // ── Локалізація ────────────────────────────────────────
          // Підтримка uk/en для системних віджетів Flutter
          // (DatePicker, AlertDialog тощо)
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('uk'),
            Locale('en'),
          ],
          // Активна мова синхронізована з налаштуваннями користувача
          locale: Locale(AppState.instance.langCode),

          // ── Тема ──────────────────────────────────────────────
          // Neo-Brutalist дизайн-система. Перемикання light/dark
          // відбувається через AppState.instance.isDark.
          theme: ThemeData(
            useMaterial3: true,
            brightness: NB.isDark ? Brightness.dark : Brightness.light,
            scaffoldBackgroundColor: NB.paper,

            // Базова типографіка
            textTheme: TextTheme(
              bodyMedium: NB.body(14),
              bodyLarge:  NB.body(16),
              titleLarge: NB.display(20),
            ),

            // AppBar без тіні та surfaceTint
            appBarTheme: AppBarTheme(
              backgroundColor:    NB.paper,
              surfaceTintColor:   Colors.transparent,
              elevation:          0,
              iconTheme:          IconThemeData(color: NB.ink),
            ),

            // Кольорова схема — primary: синій, secondary: м'ятний
            colorScheme: NB.isDark
                ? ColorScheme.dark(
                    primary:   NB.electricBlue,
                    secondary: NB.mintGreen,
                    surface:   NB.white,
                  )
                : ColorScheme.light(
                    primary:   NB.electricBlue,
                    secondary: NB.mintGreen,
                    surface:   NB.white,
                  ),

            // Прибираємо стандартний ripple-ефект
            splashFactory:  NoSplash.splashFactory,
            highlightColor: Colors.transparent,

            // Ширина бокового меню
            drawerTheme: const DrawerThemeData(width: 304),
          ),

          // ── Перший екран ───────────────────────────────────────
          // SplashScreen → Dashboard (після анімації завантаження)
          home: const SplashScreen(),
        );
      },
    );
  }
}