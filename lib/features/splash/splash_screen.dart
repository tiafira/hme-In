import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/auth_provider.dart';

/// Konfigurasi durasi animasi splash screen Home-In dalam satu tempat terpusat
/// sehingga sangat mudah diubah kapan saja.
class SplashDurations {
  SplashDurations._();

  /// Durasi animasi membesar dari kecil ke ukuran penuh (5 detik)
  static const Duration scale = Duration(seconds: 5);

  /// Durasi jeda diam di tengah setelah ukuran penuh tercapai (2 detik)
  static const Duration pause = Duration(seconds: 2);

  /// Durasi animasi icon bergeser ke samping dan teks keluar dari balik icon
  static const Duration shift = Duration(milliseconds: 900);

  /// Durasi jeda sesaat setelah animasi selesai sebelum berpindah halaman
  static const Duration settle = Duration(milliseconds: 600);
}

/// Layar Splash Screen beranimasi dengan logo Home-In dan teks Palanquin Dark #D04C4C.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  late final AnimationController _shiftController;
  late final Animation<double> _iconShiftAnimation;
  late final Animation<double> _textShiftAnimation;
  late final Animation<double> _textOpacityAnimation;

  Timer? _sequenceTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    // 1. Controller untuk animasi scale (0.15 -> 1.0) selama 5 detik
    _scaleController = AnimationController(
      vsync: this,
      duration: SplashDurations.scale,
    );

    _scaleAnimation = Tween<double>(begin: 0.15, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // 2. Controller untuk animasi shift & reveal (geser samping + teks keluar)
    _shiftController = AnimationController(
      vsync: this,
      duration: SplashDurations.shift,
    );

    // Icon bergeser ke kiri (0 -> -64 piksel)
    _iconShiftAnimation = Tween<double>(begin: 0.0, end: -64.0).animate(
      CurvedAnimation(
        parent: _shiftController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Teks keluar dari balik icon ke kanan (0 -> 56 piksel)
    _textShiftAnimation = Tween<double>(begin: 0.0, end: 56.0).animate(
      CurvedAnimation(
        parent: _shiftController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Teks muncul secara halus saat geser dimulai (0.0 -> 1.0)
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shiftController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeIn),
      ),
    );

    _startSplashSequence();
  }

  void _startSplashSequence() async {
    // Jalankan pengecekan token/auth di background saat animasi berjalan
    ref.read(authProvider.notifier).checkAuthStatus();

    // a. Mulai animasi scale selama 5 detik
    await _scaleController.forward();
    if (!mounted) return;

    // b. Jeda diam di tengah selama 2 detik
    await Future.delayed(SplashDurations.pause);
    if (!mounted) return;

    // c. Icon bergeser ke samping dan tulisan Home-in keluar dari balik icon
    await _shiftController.forward();
    if (!mounted) return;

    // Jeda sejenak untuk tampilan utuh sebelum navigasi
    await Future.delayed(SplashDurations.settle);
    if (!mounted) return;

    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (_isNavigating || !mounted) return;
    _isNavigating = true;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated && authState.user != null) {
      final user = authState.user!;
      if (user.isAdminOrPemilik) {
        context.go('/admin');
      } else if (user.isActivePenghuni) {
        context.go('/penghuni');
      } else {
        context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _scaleController.dispose();
    _shiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rasio logo SVG asli adalah 302 x 329
    const double iconWidth = 92.0;
    const double iconHeight = 100.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _shiftController]),
          builder: (context, child) {
            final scaleVal = _scaleAnimation.value;
            final iconDx = _iconShiftAnimation.value;
            final textDx = _textShiftAnimation.value;
            final textOpacity = _textOpacityAnimation.value;
            final isShiftStarted = _shiftController.value > 0.0;

            return Transform.scale(
              scale: scaleVal,
              child: SizedBox(
                width: 320,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Layer 1: Teks "Home-in" (berada di belakang icon)
                    // Teks sama sekali tidak terlihat sebelum icon mulai bergeser
                    if (isShiftStarted)
                      Transform.translate(
                        offset: Offset(textDx, 0),
                        child: Opacity(
                          opacity: textOpacity.clamp(0.0, 1.0),
                          child: Text(
                            'Home-in',
                            style: GoogleFonts.palanquinDark(
                              fontSize: 38,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFD04C4C),
                              letterSpacing: -0.5,
                              shadows: const [
                                Shadow(
                                  color: Color(0x29000000),
                                  offset: Offset(0, 1.5),
                                  blurRadius: 3.0,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // Layer 2: Icon aplikasi (berada di depan, bergeser ke kiri)
                    Transform.translate(
                      offset: Offset(iconDx, 0),
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: iconWidth,
                        height: iconHeight,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

