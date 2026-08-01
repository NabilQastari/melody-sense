import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/app_logo_avatar.dart';
import 'package:melody_sense/core/widgets/home_screen.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

/// Splash Screen — Layar Pembuka Melody Sense dengan Desain Premium & Smooth.
///
/// Menyajikan logo hero tanpa border kaku, efek aksen mengambang, animasi loading
/// bergaris komik ink, serta narasi suara Sense Mode saat pembukaan aplikasi.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initAppAndNavigate();
  }

  void _initAppAndNavigate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Trigger TTS jika Sense Mode aktif saat pembukaan aplikasi
      final mode = ref.read(operatingModeProvider);
      final isSenseMode = mode == AppOperatingMode.sense || ref.read(senseModeProvider);
      if (isSenseMode) {
        ref.read(ttsServiceProvider).speak(
              'Melody Sense. Memuat aplikasi.',
              force: true,
            );
      }
    });

    // Pindah ke HomeScreen setelah 2.4 detik animasi splash
    _navigationTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Pattern Background Accents ──
          Positioned(
            left: -30,
            top: -30,
            width: 180,
            height: 180,
            child: CustomPaint(
              painter: HalftonePatternPainter(
                color: AppColors.surfaceTint,
                opacity: 0.35,
              ),
            ),
          ),
          Positioned(
            right: -40,
            bottom: -40,
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: StripePatternPainter(
                color: AppColors.surfaceTint,
                stripeWidth: 5,
                spacing: 9.0,
              ),
            ),
          ),

          // ── Floating Decorative Music Badges ──
          Positioned(
            left: 36,
            top: 120,
            child: _buildFloatingBadge(
              icon: Icons.music_note_rounded,
              angle: -0.12,
            )
                .animate()
                .scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut)
                .shake(delay: 800.ms, duration: 2.seconds, hz: 1),
          ),
          Positioned(
            right: 36,
            top: 160,
            child: _buildFloatingBadge(
              icon: Icons.headphones_rounded,
              angle: 0.15,
            )
                .animate()
                .scale(delay: 350.ms, duration: 600.ms, curve: Curves.elasticOut)
                .shake(delay: 1.seconds, duration: 2.seconds, hz: 1),
          ),
          Positioned(
            left: 48,
            bottom: 180,
            child: _buildFloatingBadge(
              icon: Icons.graphic_eq_rounded,
              angle: 0.08,
            )
                .animate()
                .scale(delay: 450.ms, duration: 600.ms, curve: Curves.elasticOut),
          ),

          // ── Main Content Container ──
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // 1. Large Hero Logo (tanpa border kaku)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.12),
                          blurRadius: 28,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const AppLogoAvatar(size: 115),
                  )
                      .animate()
                      .scale(
                        duration: 700.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 28),

                  // 2. Header Banner Title "MELODY SENSE"
                  const WhiskerBannerHeader(
                    title: 'MELODY SENSE',
                    fontSize: 24,
                    rotateAngle: -0.02,
                    padding: EdgeInsets.symmetric(horizontal: 22, vertical: 7),
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 500.ms)
                      .slideY(begin: 0.25, end: 0, curve: Curves.easeOutBack),

                  const SizedBox(height: 14),

                  // 3. Subtitle Pill Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryDark, width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.1),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'SMART PIANO & EAR TRAINING',
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1)),

                  const Spacer(flex: 3),

                  // 4. Bottom Loading Bar & Tagline
                  Column(
                    children: [
                      Container(
                        width: 150,
                        height: 10,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primaryDark, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            backgroundColor: AppColors.surfaceTint,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'FEEL THE RHYTHM • SENSE THE MELODY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: AppColors.primaryDark.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 550.ms, duration: 400.ms),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBadge({required IconData icon, required double angle}) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryDark, width: 2.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.12),
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
