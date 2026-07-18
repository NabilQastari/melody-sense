import 'package:flutter/material.dart';
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
    this.onContinue,
    this.onRetry,
  });

  /// Menang = sesi selesai dengan hearts tersisa. Kalah = hearts habis.
  final bool isWin;

  /// 0.0 - 1.0
  final double accuracy;
  final int xpEarned;

  /// TODO(progression): masih placeholder — sistem streak harian
  /// belum dibangun (rencana Sesi 6-9). Isi 0 sampai tersedia.
  final int streakDays;

  /// TODO(progression): masih placeholder — sistem level/XP-threshold
  /// belum dibangun. False sampai tersedia.
  final bool leveledUp;

  final VoidCallback? onContinue;
  final VoidCallback? onRetry;

  String get _headline {
    if (!isWin) return 'Keep Practicing!';
    return accuracy >= 0.9 ? 'Perfect Pitch!' : 'Nice Job!';
  }

  String get _subtitle {
    if (!isWin) return 'Out of hearts — every miss is a step closer.';
    return "You're mastering the 9-key piano!";
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
                      Icon(
                        isWin
                            ? Icons.emoji_events_rounded
                            : Icons.favorite_border_rounded,
                        color: accentColor,
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _headline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _AccuracyRing(accuracy: accuracy, color: accentColor),
                      if (isWin && leveledUp) ...[
                        const SizedBox(height: 12),
                        _LevelUpPill(),
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
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department_rounded,
                              iconColor: Colors.deepOrange,
                              value: '$streakDays-Day',
                              label: 'Streak',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              _PrimaryButton(label: 'Continue', onTap: onContinue),
              const SizedBox(height: 10),
              _SecondaryButton(label: 'Retry', onTap: onRetry),
              const SizedBox(height: 12),
              const _StaticBottomNav(),
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
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.primaryDark,
            ),
          ),
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

/// Bottom nav dekoratif, meniru desain 06/07. BELUM fungsional —
/// navigasi antar tab utama app (Dashboard/Practice/Progression/Stats)
/// belum dibangun karena go_router belum dipasang penuh. Tab
/// "Practice" ditandai aktif karena layar ini muncul setelah sesi
/// latihan.
class _StaticBottomNav extends StatelessWidget {
  const _StaticBottomNav();

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String label, {bool active = false}) {
      final color = active ? AppColors.primaryDark : Colors.grey.shade400;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        item(Icons.grid_view_rounded, 'Dashboard'),
        item(Icons.music_note_rounded, 'Practice', active: true),
        item(Icons.trending_up_rounded, 'Progression'),
        item(Icons.bar_chart_rounded, 'Stats'),
      ],
    );
  }
}