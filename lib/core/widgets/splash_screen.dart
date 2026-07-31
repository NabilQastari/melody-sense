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
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

/// Splash Screen — Layar Pembuka Melody Sense dengan Whisker Design System.
///
/// Menyajikan animasi branding, logo dinamis bertema, audio engine loading indicator,
/// serta dukungan narasi suara Sense Mode saat aplikasi dibuka.
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
              'Melody Sense. Selamat datang. Memuat aplikasi.',
              force: true,
            );
      }
    });

    // Pindah ke HomeScreen setelah 2.5 detik animasi splash
    _navigationTimer = Timer(const Duration(milliseconds: 2500), () {
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
          transitionDuration: const Duration(milliseconds: 500),
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
          // ── Pattern Background Accent ──
          Positioned(
            left: -40,
            top: -40,
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: HalftonePatternPainter(
                color: AppColors.surfaceTint,
                opacity: 0.35,
              ),
            ),
          ),
          Positioned(
            right: -50,
            bottom: -50,
            width: 240,
            height: 240,
            child: CustomPaint(
              painter: StripePatternPainter(
                color: AppColors.surfaceTint,
                stripeWidth: 6,
                spacing: 8.0,
              ),
            ),
          ),

          // ── Center Content ──
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // 1. Logo Badge Card dengan Torn Paper & Shadow
                    TornPaperCard(
                      backgroundColor: AppColors.surfaceWhite,
                      shadowColor: AppColors.surfaceTint,
                      borderWidth: 3.2,
                      tornPosition: TornEdgePosition.both,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          StickerBadge(
                            rotateAngle: -0.04,
                            backgroundColor: AppColors.surfaceTint,
                            borderColor: AppColors.primaryDark,
                            borderWidth: 2.8,
                            padding: const EdgeInsets.all(16),
                            child: const AppLogoAvatar(size: 80),
                          )
                              .animate()
                              .scale(
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              )
                              .shake(
                                delay: 600.ms,
                                duration: 400.ms,
                                hz: 2,
                              ),
                          const SizedBox(height: 20),

                          // Header Banner "MELODY SENSE"
                          const WhiskerBannerHeader(
                            title: 'MELODY SENSE',
                            fontSize: 22,
                            rotateAngle: -0.02,
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 6,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms)
                              .slideY(begin: 0.2, end: 0),

                          const SizedBox(height: 12),

                          // Subtitle playful
                          Text(
                            'SMART PIANO & EAR TRAINING',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.fredoka(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.primaryDark.withValues(alpha: 0.8),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 350.ms, duration: 400.ms),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),

                    const Spacer(),

                    // 2. Bottom Loading Indicator & Status Text
                    Column(
                      children: [
                        SizedBox(
                          width: 140,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              minHeight: 6,
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
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.primaryDark.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
