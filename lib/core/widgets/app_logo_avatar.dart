import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/providers/database_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/theme/app_theme_data.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

/// Reusable App Logo Avatar Widget dengan Easter Egg / Cheat Activation.
///
/// Menampilkan logo bertema dinamis yang menyesuaikan warna tema aktif.
/// Jika logo ditekan 10 kali dalam waktu 5 detik:
/// - Pengguna mendapatkan +40.000 XP (Langsung naik 40+ Level)
/// - Semua Achievements terbuka secara otomatis
/// - Menampilkan Popup perayaan bergaya Whisker
class AppLogoAvatar extends ConsumerStatefulWidget {
  const AppLogoAvatar({
    super.key,
    this.size = 38.0,
    this.onTap,
  });

  final double size;
  final VoidCallback? onTap;

  /// Memetakan ID tema aktif ke jalur asset PNG yang sesuai
  static String getLogoAssetPath(String themeId) {
    switch (themeId) {
      case AppThemes.whiskerDarkId:
        return 'assets/images/logo_whisker_dark.png';
      case AppThemes.oceanBlueId:
        return 'assets/images/logo_ocean_blue.png';
      case AppThemes.forestGreenId:
        return 'assets/images/logo_forest_green.png';
      case AppThemes.sunsetOrangeId:
        return 'assets/images/logo_sunset_orange.png';
      case AppThemes.defaultId:
      default:
        return 'assets/images/logo_lavender.png';
    }
  }

  @override
  ConsumerState<AppLogoAvatar> createState() => _AppLogoAvatarState();
}

class _AppLogoAvatarState extends ConsumerState<AppLogoAvatar> {
  final List<DateTime> _tapTimestamps = [];

  void _handleTap() {
    // Jalankan callback kustom jika ada
    widget.onTap?.call();

    final now = DateTime.now();
    _tapTimestamps.add(now);

    // Hapus ketukan yang lebih lama dari 5 detik
    _tapTimestamps.removeWhere((t) => now.difference(t) > const Duration(seconds: 5));

    // Jika berhasil 10 ketukan dalam 5 detik -> Trigger Easter Egg Cheat
    if (_tapTimestamps.length >= 10) {
      _tapTimestamps.clear();
      _triggerCheat(context);
    }
  }

  Future<void> _triggerCheat(BuildContext context) async {
    final db = ref.read(appDatabaseProvider);
    final repo = ref.read(progressionRepositoryProvider);

    // 1. Pastikan achievement standar ada di DB
    await repo.seedDefaultAchievementsIfEmpty();

    // 2. Tambahkan Sesi Cheat untuk menginjeksi 40.000 XP & Note Accuracy
    final modeKey = TrainingMode.noteRecognition.storageKey;
    final sessionId = await db.sessionDao.startSession(mode: modeKey);
    await db.sessionDao.finishSession(
      sessionId: sessionId,
      xpEarned: 40000,
      score: 40000,
    );

    // Injeksi tebakan nada 100% benar untuk semua 14 nada kromatik di Note Accuracy chart
    const notes = [
      'B3', 'C4', 'C#4', 'D4', 'D#4', 'E4', 'F4',
      'F#4', 'G4', 'G#4', 'A4', 'A#4', 'B4', 'C5',
    ];
    for (final note in notes) {
      for (int i = 0; i < 5; i++) {
        await db.attemptDao.logAttempt(
          sessionId: sessionId,
          note: note,
          isCorrect: true,
          responseTimeMs: 250,
        );
      }
    }

    // 3. Unlock semua Achievements
    final allAchievements = await db.achievementDao.getAll();
    for (final ach in allAchievements) {
      await db.achievementDao.setProgress(ach.id, ach.progressTarget);
    }

    // 4. TTS Narration (Sense Mode)
    ref.read(ttsServiceProvider).speak(
          'Easter Egg Diaktifkan! Selamat, Anda mendapatkan 40.000 XP dan semua pencapaian terbuka!',
          force: true,
        );

    // 5. Tampilkan Popup Dialog Bergaya Whisker
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              TornPaperCard(
                backgroundColor: AppColors.surfaceWhite,
                shadowColor: AppColors.surfaceTint,
                borderWidth: 3.0,
                tornPosition: TornEdgePosition.both,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header Banner "EASTER EGG UNLOCKED!"
                    const WhiskerBannerHeader(
                      title: '🎉 CHEAT ACTIVATED! 🎉',
                      fontSize: 16,
                      rotateAngle: -0.03,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    ),
                    const SizedBox(height: 18),

                    // Badge Icon Hadiah
                    StickerBadge(
                      backgroundColor: AppColors.surfaceTint,
                      borderColor: AppColors.primaryDark,
                      borderWidth: 2.5,
                      padding: const EdgeInsets.all(12),
                      rotateAngle: 0.04,
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 42,
                        color: AppColors.accent,
                      ),
                    )
                        .animate()
                        .scale(duration: 500.ms, curve: Curves.elasticOut)
                        .shake(delay: 500.ms, duration: 400.ms),

                    const SizedBox(height: 16),

                    Text(
                      'MAESTRO EASTER EGG!',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Text(
                      'Kamu menemukan rahasia tersembunyi Melody Sense!\n\n'
                      '⚡ +40,000 XP (Melompat 400 Level!)\n'
                      '🏆 Semua Achievements Terbuka!\n'
                      '🎁 Mystery Chest Level 40 Terbuka!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: AppColors.primaryDark.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Terima Hadiah
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: AppColors.primaryDark, width: 2.2),
                          ),
                        ),
                        child: Text(
                          'KLAIM HADIAH!',
                          style: GoogleFonts.fredoka(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeId = AppColors.currentTheme.id;
    final logoPath = AppLogoAvatar.getLogoAssetPath(themeId);

    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Image.asset(
          logoPath,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.music_note_rounded,
              size: widget.size * 0.75,
              color: AppColors.primaryDark,
            );
          },
        ),
      ),
    );
  }
}
