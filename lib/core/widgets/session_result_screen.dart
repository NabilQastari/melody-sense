import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/theme/app_colors.dart';


/// Shell UI untuk layar hasil sesi (desain "06 - Session Results"),
/// dipakai SEMUA mode latihan (Note Recognition, Interval Training,
/// dst.) lewat parameter — mirip pola ExplorerGameplayScreen /
/// MaestroGameplayScreen: shell ini tidak tahu soal domain logic,
/// cuma menampilkan angka yang disuplai.
///
/// Kasus kalah (hearts habis) BELUM punya desain terpisah — atas
/// keputusan tim, layar yang sama dipakai, cuma judul/subtitle/ikon
/// diganti lewat [isWin] supaya tetap jelas beda dari menang.
class SessionResultScreen extends StatelessWidget {
  const SessionResultScreen({
    super.key,
    required this.isWin,
    required this.accuracy,
    required this.xpEarned,
    this.streakDays = 0,
    this.leveledUp = false,
    this.timeSpentMs,
    this.stars,
    this.perfectCount,
    this.totalNotes,
    this.customSubtitle,
    this.retryScreenBuilder,
  });

  /// Menang = sesi selesai dengan hearts tersisa. Kalah = hearts habis.
  final bool isWin;

  /// 0.0 - 1.0
  final double accuracy;
  final int xpEarned;

  final int streakDays;
  final bool leveledUp;
  final int? timeSpentMs;
  final int? stars;
  final int? perfectCount;
  final int? totalNotes;
  final String? customSubtitle;

  /// Builder untuk layar yang dibuka saat user tap Retry. Null = tombol
  /// Retry tidak muncul. Continue selalu pop() kembali ke layar
  /// sebelumnya (PracticeScreen).
  ///
  /// Navigasi ditangani di sini (bukan lewat VoidCallback dari caller)
  /// supaya pakai BuildContext SessionResultScreen sendiri yang valid —
  /// caller (NoteRecognitionScreen, dst.) sudah di-pushReplacement jadi
  /// context-nya mati.
  final WidgetBuilder? retryScreenBuilder;

  String get _headline {
    if (!isWin) return 'Keep Practicing!';
    return accuracy >= 0.9 ? 'Perfect Pitch!' : 'Nice Job!';
  }

  String get _subtitle {
    if (customSubtitle != null) return customSubtitle!;
    if (!isWin) return 'Out of hearts — every miss is a step closer.';
    return "You're mastering the 9-key piano!";
  }

  String _formatDuration(int ms) {
    final seconds = ms / 1000;
    if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)}s';
    }
    final mins = ms ~/ 60000;
    final remSecs = ((ms % 60000) / 1000).toStringAsFixed(0);
    return '${mins}m ${remSecs}s';
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = isWin ? AppColors.accent : Colors.grey.shade400;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text(
                    'Melody Sense',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.settings_outlined,
                      color: AppColors.primaryDark, size: 20),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (stars != null && stars! > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final isFilled = index < stars!;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                isFilled
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color:
                                    isFilled ? Colors.amber : Colors.grey.shade300,
                                size: 32,
                              ),
                            );
                          }),
                        ).animate().scale(
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            ),
                        const SizedBox(height: 8),
                      ] else ...[
                        Icon(
                          isWin
                              ? Icons.emoji_events_rounded
                              : Icons.favorite_border_rounded,
                          color: accentColor,
                          size: 22,
                        ).animate().scale(
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            ),
                        const SizedBox(height: 8),
                      ],
                      Text(
                        _headline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 6),
                      Text(
                        _subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: 28),
                      _AccuracyRing(accuracy: accuracy, color: accentColor)
                          .animate().scale(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                      if (isWin && leveledUp) ...[
                        const SizedBox(height: 12),
                        _LevelUpPill()
                            .animate().scaleXY(begin: 0.8, end: 1.0, delay: 500.ms, duration: 600.ms, curve: Curves.bounceOut),
                      ],
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.monetization_on,
                              iconColor: Colors.amber,
                              value: '+$xpEarned',
                              label: 'XP Earned',
                            ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),
                          ),
                          if (perfectCount != null) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.stars_rounded,
                                iconColor: Colors.purpleAccent,
                                value: '$perfectCount/${totalNotes ?? 0}',
                                label: 'Perfect',
                              ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                            ),
                          ],
                          if (timeSpentMs != null) ...[
                            const SizedBox(width: 6),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.timer_outlined,
                                iconColor: Colors.blue,
                                value: _formatDuration(timeSpentMs!),
                                label: 'Durasi',
                              ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                            ),
                          ],
                          const SizedBox(width: 6),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: Colors.deepOrange,
                              value: '$streakDays-Day',
                              label: 'Streak',
                            ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _PrimaryButton(
                label: 'Continue',
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 10),
              if (retryScreenBuilder != null)
                _SecondaryButton(
                  label: 'Retry',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: retryScreenBuilder!),
                    );
                  },
                ),
              if (retryScreenBuilder != null) const SizedBox(height: 12),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccuracyRing extends StatelessWidget {
  const _AccuracyRing({required this.accuracy, required this.color});
  final double accuracy;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = (accuracy * 100).round();
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              value: accuracy.clamp(0.0, 1.0),
              strokeWidth: 12,
              backgroundColor: AppColors.surfaceTint,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'ACCURACY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelUpPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Level Up!',
        style: TextStyle(
          color: AppColors.surfaceWhite,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          () {
            if (value.startsWith('+')) {
              final numValue = int.tryParse(value.substring(1)) ?? 0;
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: numValue.toDouble()),
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Text(
                    '+${val.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primaryDark,
                    ),
                  );
                },
              );
            }
            return Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.primaryDark,
              ),
            );
          }(),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.surfaceWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.surfaceTint, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}