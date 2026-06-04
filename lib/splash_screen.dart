// =====================================================================
//  SPLASH SCREEN — екран завантаження KlimaBox
//
//  Послідовність:
//  1. Логотип з'являється через scale (0.82→1.0) + fade-in (600ms)
//  2. Утримується _hold (1400ms) — прогрес-бар заповнюється
//  3. Dashboard рендериться «під» splash (невидимо)
//  4. Splash зникає через fade-out (400ms)
//  5. Navigator.pushReplacement → Dashboard з fade-in (350ms)
// =====================================================================

import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'theme/neo_brutalist_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  // ── Тривалості переходів ─────────────────────────────────────────
  static const _hold    = Duration(milliseconds: 1400);
  static const _fadeOut = Duration(milliseconds: 400);
  static const _fadeIn  = Duration(milliseconds: 350);

  late final AnimationController _ctrl;
  late final Animation<double>   _logoScale;
  late final Animation<double>   _logoOpacity;

  bool   _showApp       = false;
  double _splashOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    // Вхідна анімація логотипа (scale + fade)
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _logoScale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack)
        .drive(Tween(begin: 0.82, end: 1.0));

    _logoOpacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));

    _ctrl.forward();
    Future.delayed(_hold, _startTransition);
  }

  // ── Перехід до Dashboard ─────────────────────────────────────────
  Future<void> _startTransition() async {
    if (!mounted) return;

    // Починаємо рендерити Dashboard під splash
    setState(() => _showApp = true);
    await Future.delayed(const Duration(milliseconds: 16)); // 1 кадр

    if (!mounted) return;
    setState(() => _splashOpacity = 0.0);
    await Future.delayed(_fadeOut);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:        (_, __, ___) => const Dashboard(),
        transitionDuration: _fadeIn,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size     = MediaQuery.sizeOf(context);
    final isSmall  = size.shortestSide < 360;
    final logoSize = (size.shortestSide * 0.38).clamp(100.0, 200.0);

    return Stack(
      children: [
        if (_showApp) const Dashboard(),
        AnimatedOpacity(
          opacity:  _splashOpacity,
          duration: _fadeOut,
          curve:    Curves.easeInOut,
          child: _SplashContent(
            logoSize:    logoSize,
            isSmall:     isSmall,
            logoScale:   _logoScale,
            logoOpacity: _logoOpacity,
          ),
        ),
      ],
    );
  }
}

// ── Вміст splash ─────────────────────────────────────────────────────
class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.logoSize,
    required this.isSmall,
    required this.logoScale,
    required this.logoOpacity,
  });

  final double logoSize;
  final bool   isSmall;
  final Animation<double> logoScale;
  final Animation<double> logoOpacity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NB.paper,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: logoOpacity,
            builder: (context, _) => Opacity(
              opacity: logoOpacity.value,
              child: Transform.scale(
                scale: logoScale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Іконка у Neo-Brutalist рамці
                    Container(
                      width:  logoSize,
                      height: logoSize,
                      decoration: BoxDecoration(
                        color:     NB.white,
                        border:    NB.outline(width: NB.borderThick),
                        boxShadow: NB.hardShadowLg,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(logoSize * 0.05),
                        child: Image.asset('assets/icons/icon_splash.png', fit: BoxFit.contain),
                      ),
                    ),

                    SizedBox(height: isSmall ? 20 : 28),

                    // Назва додатка
                    Text('KlimaBox', style: NB.display(isSmall ? 18 : 22)),

                    const SizedBox(height: 6),

                    // Підзаголовок
                    Text(
                      'REALTIME TELEMETRY',
                      style: NB.label(isSmall ? 9 : 10).copyWith(
                        color:         NB.mutedInk,
                        letterSpacing: 2.5,
                      ),
                    ),

                    SizedBox(height: isSmall ? 32 : 48),

                    // Прогрес-бар
                    const _NeonPulseBar(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Анімований прогрес-бар ───────────────────────────────────────────
class _NeonPulseBar extends StatefulWidget {
  const _NeonPulseBar();

  @override
  State<_NeonPulseBar> createState() => _NeonPulseBarState();
}

class _NeonPulseBarState extends State<_NeonPulseBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bar;
  late final Animation<double>   _width;

  @override
  void initState() {
    super.initState();
    _bar = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..forward();
    _width = CurvedAnimation(parent: _bar, curve: Curves.easeInOut)
        .drive(Tween(begin: 0.0, end: 1.0));
  }

  @override
  void dispose() {
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, height: 4,
      child: AnimatedBuilder(
        animation: _width,
        builder: (_, __) => Stack(
          children: [
            // Фон
            Container(
              width: double.infinity, height: 4,
              decoration: BoxDecoration(
                color:  NB.subtleGrey,
                border: Border.all(color: NB.ink, width: 1),
              ),
            ),
            // Заповнення
            FractionallySizedBox(
              widthFactor: _width.value,
              child: Container(height: 4, color: NB.electricBlue),
            ),
          ],
        ),
      ),
    );
  }
}