import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

/// Shell UI untuk layar hasil sesi (desain "06 - Session Results")
/// Diperbarui dengan Whisker-Inspired Design System v3.
class SessionResultScreen extends ConsumerStatefulWidget {
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

  final bool isWin;
  final double accuracy;
  final int xpEarned;

  final int streakDays;
  final bool leveledUp;
  final int? timeSpentMs;
  final int? stars;
  final int? perfectCount;
  final int? totalNotes;
  final String? customSubtitle;

  final WidgetBuilder? retryScreenBuilder;

  @override
  ConsumerState<SessionResultScreen> createState() => _SessionResultScreenState();
}

class _SessionResultScreenState extends ConsumerState<SessionResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mode = ref.read(operatingModeProvider);
      final isSenseMode = mode == AppOperatingMode.sense || ref.read(senseModeProvider);
      if (isSenseMode) {
        final accPercent = (widget.accuracy * 100).toInt();
        final statusText = widget.isWin ? 'Sesi berhasil' : 'Sesi selesai';
        final streakText = widget.streakDays > 0 ? '. Streak ${widget.streakDays} hari' : '';
        final levelText = widget.leveledUp ? '. Selamat, kamu naik level!' : '';

        ref.read(ttsServiceProvider).speak(
              '$statusText. Akurasi $accPercent persen. Memperoleh ${widget.xpEarned} XP$streakText$levelText.',
              force: true,
            );
      }
    });
  }

  String get _headline {
    if (!widget.isWin) return 'KEEP PRACTICING!';
    return widget.accuracy >= 0.9 ? 'PERFECT PITCH!' : 'NICE JOB!';
  }

  String get _subtitle {
    if (widget.customSubtitle != null) return widget.customSubtitle!;
    if (!widget.isWin) return 'Out of hearts — every miss is a step closer.';
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
    final accentColor = widget.isWin ? AppColors.accent : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const WhiskerBannerHeader(
                    title: 'MELODY SENSE',
                    fontSize: 14,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryDark, width: 2.2),
                    ),
                    child: Icon(Icons.settings_outlined,
                        color: AppColors.primaryDark, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      TornPaperCard(
                        backgroundColor: AppColors.surfaceWhite,
                        shadowColor: AppColors.surfaceTint,
                        borderWidth: 2.8,
                        tornPosition: TornEdgePosition.both,
                        padding: const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              top: 10,
                              width: 80,
                              height: 80,
                              child: CustomPaint(
                                painter: HalftonePatternPainter(
                                  color: AppColors.surfaceTint,
                                  opacity: 0.3,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                if (widget.stars != null && widget.stars! > 0) ...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(3, (index) {
                                      final isFilled = index < widget.stars!;
                                      return Padding(
                                        padding:
                                            const EdgeInsets.symmetric(horizontal: 4),
                                        child: Icon(
                                          isFilled
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          color: isFilled
                                              ? Colors.amber.shade700
                                              : Colors.grey.shade300,
                                          size: 36,
                                        ),
                                      );
                                    }),
                                  ).animate().scale(
                                        duration: 400.ms,
                                        curve: Curves.elasticOut,
                                      ),
                                  const SizedBox(height: 10),
                                ] else ...[
                                  StickerBadge(
                                    rotateAngle: -0.05,
                                    backgroundColor: accentColor,
                                    borderColor: AppColors.primaryDark,
                                    padding: const EdgeInsets.all(12),
                                    child: Icon(
                                      widget.isWin
                                          ? Icons.emoji_events_rounded
                                          : Icons.favorite_border_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ).animate().scale(
                                        duration: 400.ms,
                                        curve: Curves.elasticOut,
                                      ),
                                  const SizedBox(height: 12),
                                ],

                                WhiskerBannerHeader(
                                  title: _headline,
                                  fontSize: 18,
                                  rotateAngle: -0.03,
                                  backgroundColor: widget.isWin ? AppColors.accent : Colors.grey.shade300,
                                  textColor: widget.isWin ? Colors.white : AppColors.primaryDark,
                                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

                                const SizedBox(height: 10),
                                Text(
                                  _subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.3,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark.withValues(alpha: 0.75),
                                  ),
                                ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.2, end: 0),

                                const SizedBox(height: 24),
                                _AccuracyRing(accuracy: widget.accuracy, color: accentColor)
                                    .animate().scale(delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                                if (widget.isWin && widget.leveledUp) ...[
                                  const SizedBox(height: 14),
                                  StickerBadge(
                                    rotateAngle: 0.05,
                                    backgroundColor: AppColors.accent,
                                    borderColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                    child: Text(
                                      'LEVEL UP!',
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ).animate().scaleXY(begin: 0.8, end: 1.0, delay: 500.ms, duration: 600.ms, curve: Curves.bounceOut),
                                ],

                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.monetization_on_rounded,
                                        iconColor: Colors.amber.shade700,
                                        value: '+${widget.xpEarned}',
                                        label: 'XP Earned',
                                      ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),
                                    ),
                                    if (widget.perfectCount != null) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _StatCard(
                                          icon: Icons.stars_rounded,
                                          iconColor: Colors.purpleAccent,
                                          value: '${widget.perfectCount}/${widget.totalNotes ?? 0}',
                                          label: 'Perfect',
                                        ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                                      ),
                                    ],
                                    if (widget.timeSpentMs != null) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _StatCard(
                                          icon: Icons.timer_outlined,
                                          iconColor: Colors.blue.shade700,
                                          value: _formatDuration(widget.timeSpentMs!),
                                          label: 'Durasi',
                                        ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
                                      ),
                                    ],
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.local_fire_department_rounded,
                                        iconColor: Colors.deepOrange,
                                        value: '${widget.streakDays}-Day',
                                        label: 'Streak',
                                      ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideX(begin: 0.1, end: 0),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _PrimaryButton(
                label: 'CONTINUE',
                onTap: () => Navigator.of(context).pop(),
              ),
              if (widget.retryScreenBuilder != null) ...[
                const SizedBox(height: 10),
                _SecondaryButton(
                  label: 'RETRY',
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: widget.retryScreenBuilder!),
                    );
                  },
                ),
              ],
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
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
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
                style: GoogleFonts.fredoka(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                'ACCURACY',
                style: GoogleFonts.fredoka(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.primaryDark.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryDark, width: 2.2),
      ),
      child: Column(
        children: [
          StickerBadge(
            rotateAngle: -0.04,
            backgroundColor: AppColors.surfaceWhite,
            borderColor: AppColors.primaryDark,
            borderWidth: 1.8,
            padding: const EdgeInsets.all(6),
            child: Icon(icon, color: iconColor, size: 18),
          ),
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
                    style: GoogleFonts.fredoka(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primaryDark,
                    ),
                  );
                },
              );
            }
            return Text(
              value,
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppColors.primaryDark,
              ),
            );
          }(),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 10,
              color: AppColors.primaryDark.withValues(alpha: 0.65),
            ),
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
      height: 48,
      child: GestureDetector(
        onTap: onTap,
        child: StickerBadge(
          rotateAngle: -0.01,
          backgroundColor: AppColors.darkContainer,
          borderColor: AppColors.isDark ? Colors.black : AppColors.primaryDark,
          borderWidth: 2.5,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
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
      height: 44,
      child: GestureDetector(
        onTap: onTap,
        child: StickerBadge(
          rotateAngle: 0.01,
          backgroundColor: AppColors.surfaceWhite,
          borderColor: AppColors.primaryDark,
          borderWidth: 2.2,
          padding: EdgeInsets.zero,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.fredoka(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}