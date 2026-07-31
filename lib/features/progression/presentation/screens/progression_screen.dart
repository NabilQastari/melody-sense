import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/theme/app_theme_data.dart';
import 'package:melody_sense/core/providers/theme_providers.dart';
import 'package:melody_sense/core/widgets/app_logo_avatar.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/settings_screen.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';
import 'package:melody_sense/features/practice/presentation/screens/practice_screen.dart';
import 'package:melody_sense/features/stats/presentation/providers/stats_providers.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';

/// State notifier untuk menyimpan status klaim Mystery Chest Level 40 secara permanen.
final claimedChestsProvider =
    StateNotifierProvider<ClaimedChestsNotifier, Set<int>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ClaimedChestsNotifier(prefs);
});

class ClaimedChestsNotifier extends StateNotifier<Set<int>> {
  ClaimedChestsNotifier(this._prefs) : super(_loadInitialState(_prefs));

  final SharedPreferences _prefs;

  static Set<int> _loadInitialState(SharedPreferences prefs) {
    final list = prefs.getStringList('claimed_chest_levels') ?? [];
    final claimed = list.map((e) => int.tryParse(e) ?? 40).toSet();

    // Jika tema eksklusif sudah terbuka di prefs, otomatis anggap chest Level 40 sudah terklaim
    final unlockedThemes = prefs.getStringList('unlocked_theme_ids') ?? [];
    if (unlockedThemes.contains(AppThemes.whiskerDarkId)) {
      claimed.add(40);
    }
    return claimed;
  }

  Future<void> claim(int chestLevel) async {
    final updated = {...state, chestLevel};
    await _prefs.setStringList(
      'claimed_chest_levels',
      updated.map((e) => e.toString()).toList(),
    );
    state = updated;
  }

  Future<void> resetAll() async {
    await _prefs.remove('claimed_chest_levels');
    state = {};
  }
}

/// Progression Screen - Sesi 8 (Peta Level / Progression Path)
/// Diperbarui dengan Design System v3 & Mystery Chest Spesial Level 40.
class ProgressionScreen extends ConsumerWidget {
  const ProgressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelInfoAsync = ref.watch(levelInfoProvider);
    final streakAsync = ref.watch(streakProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Shared App Bar Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const AppLogoAvatar(),
                  const SizedBox(width: 10),
                  const WhiskerBannerHeader(
                    title: 'PROGRESSION',
                    fontSize: 15,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryDark, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Body ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    // ── Top Stats (Streak & XP Cards) ──
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            value: streakAsync.maybeWhen(
                              data: (days) => days.toString(),
                              orElse: () => '0',
                            ),
                            label: 'DAY STREAK',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            value: levelInfoAsync.maybeWhen(
                              data: (info) {
                                if (info.totalXp >= 1000) {
                                  return '${(info.totalXp / 1000).toStringAsFixed(1)}k';
                                }
                                return info.totalXp.toString();
                              },
                              orElse: () => '0',
                            ),
                            label: 'TOTAL XP',
                            icon: Icons.stars_rounded,
                            iconColor: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    const WhiskerBannerHeader(
                      title: 'LEVEL ROADMAP',
                      fontSize: 16,
                      rotateAngle: -0.04,
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    ),
                    const SizedBox(height: 16),

                    // ── Winding Path Map ──
                    levelInfoAsync.when(
                      loading: () => Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.0),
                          child: CircularProgressIndicator(color: AppColors.accent),
                        ),
                      ),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (levelInfo) => _LevelPathMap(currentLevel: levelInfo.level),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return TornPaperCard(
      backgroundColor: AppColors.surfaceWhite,
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.6,
      tornPosition: TornEdgePosition.bottom,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          StickerBadge(
            rotateAngle: -0.04,
            backgroundColor: AppColors.surfaceTint,
            borderColor: AppColors.primaryDark,
            borderWidth: 2.0,
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.fredoka(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark.withValues(alpha: 0.65),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PathNodeType { level, chest }

class _PathItemData {
  final _PathNodeType type;
  final int minLevel;
  final int maxLevel;
  final String title;
  final String description;
  final IconData icon;

  const _PathItemData({
    required this.type,
    required this.minLevel,
    required this.maxLevel,
    required this.title,
    required this.description,
    required this.icon,
  });
}

class _LevelPathMap extends ConsumerWidget {
  const _LevelPathMap({required this.currentLevel});

  final int currentLevel;

  static const List<_PathItemData> items = [
    _PathItemData(
      type: _PathNodeType.level,
      minLevel: 1,
      maxLevel: 9,
      title: 'Beginner',
      description: 'Latihan dasar pengenalan nada tunggal dan pendengaran awal (Level 1–9).',
      icon: Icons.star_rounded,
    ),
    _PathItemData(
      type: _PathNodeType.level,
      minLevel: 10,
      maxLevel: 19,
      title: 'Scale Master',
      description: 'Menguasai susunan tangga nada kromatik 14 nada B3–C5 (Level 10–19).',
      icon: Icons.keyboard_rounded,
    ),
    _PathItemData(
      type: _PathNodeType.level,
      minLevel: 20,
      maxLevel: 29,
      title: 'Interval Hero',
      description: 'Mengenali jarak interval nada Semitones, Major & Minor (Level 20–29).',
      icon: Icons.headphones_rounded,
    ),
    _PathItemData(
      type: _PathNodeType.level,
      minLevel: 30,
      maxLevel: 39,
      title: 'Melody Maestro',
      description: 'Tingkat tertinggi keahlian pendengaran melodi & ritme lagu (Level 30–39).',
      icon: Icons.music_note_rounded,
    ),
    _PathItemData(
      type: _PathNodeType.chest,
      minLevel: 40,
      maxLevel: 40,
      title: 'Mystery Chest 🎁',
      description: 'Peti Rahasia Spesial! Capai Level 40 untuk membuka Mystery Chest ini.',
      icon: Icons.card_giftcard_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double mapHeight = 580.0;
    final claimedSet = ref.watch(claimedChestsProvider);

    return TornPaperCard(
      backgroundColor: AppColors.surfaceWhite,
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.8,
      tornPosition: TornEdgePosition.both,
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final mapWidth = constraints.maxWidth;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: HalftonePatternPainter(
                    color: AppColors.surfaceTint,
                    opacity: 0.2,
                  ),
                ),
              ),
              SizedBox(
                height: mapHeight,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _WindingPathPainter(
                          nodesCount: items.length,
                          currentLevel: currentLevel,
                        ),
                      ),
                    ),
                    ...List.generate(items.length, (index) {
                      final item = items[index];
                      final isUnlocked = currentLevel >= item.minLevel;
                      final isCurrent = currentLevel >= item.minLevel && currentLevel <= item.maxLevel;
                      final isClaimed = claimedSet.contains(item.minLevel);

                      final point = _calculateNodePosition(index, items.length, mapHeight, mapWidth);

                      return Positioned(
                        left: point.dx - 48,
                        top: point.dy - 48,
                        child: GestureDetector(
                          onTap: () => _onNodeTapped(context, ref, item, isUnlocked, isCurrent, isClaimed),
                          child: _MapNodeWidget(
                            item: item,
                            isUnlocked: isUnlocked,
                            isCurrent: isCurrent,
                            isClaimed: isClaimed,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onNodeTapped(
    BuildContext context,
    WidgetRef ref,
    _PathItemData item,
    bool isUnlocked,
    bool isCurrent,
    bool isClaimed,
  ) {
    if (item.type == _PathNodeType.chest) {
      if (isClaimed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎁 Mystery Chest Level 40 sudah kamu buka! Cek pilihan tema di Pengaturan.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
      showDialog(
        context: context,
        builder: (_) => _ChestDialog(
          item: item,
          isUnlocked: isUnlocked,
          isClaimed: isClaimed,
          onClaim: () {
            ref.read(claimedChestsProvider.notifier).claim(item.minLevel);
            ref.read(unlockedThemesProvider.notifier).unlockThemes(AppThemes.chestUnlockIds);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🎉 Selamat! 4 Tema Warna Eksklusif berhasil di-unlock! Pilih tema di Pengaturan.'),
                backgroundColor: AppColors.darkContainer,
                duration: Duration(seconds: 4),
              ),
            );
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => _LevelDetailsDialog(
          item: item,
          isUnlocked: isUnlocked,
          isCurrent: isCurrent,
          currentLevel: currentLevel,
        ),
      );
    }
  }

  static Offset _calculateNodePosition(int index, int totalNodes, double height, double width) {
    final double segmentHeight = (height - 90) / (totalNodes - 1);
    final double y = (height - 45) - (index * segmentHeight);

    const double amplitude = 65.0;
    final double centerX = width / 2;
    final double x = centerX + (index % 2 == 0 ? -amplitude : amplitude);

    return Offset(x, y);
  }
}

class _WindingPathPainter extends CustomPainter {
  _WindingPathPainter({required this.nodesCount, required this.currentLevel});

  final int nodesCount;
  final int currentLevel;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final unlockedPath = Path();

    final points = <Offset>[];
    for (int i = 0; i < nodesCount; i++) {
      points.add(_LevelPathMap._calculateNodePosition(i, nodesCount, size.height, size.width));
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      unlockedPath.moveTo(points[0].dx, points[0].dy);

      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        final controlPoint1 = Offset(p1.dx, (p1.dy + p2.dy) / 2);
        final controlPoint2 = Offset(p2.dx, (p1.dy + p2.dy) / 2);

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          p2.dx,
          p2.dy,
        );

        if (currentLevel >= _LevelPathMap.items[i + 1].minLevel) {
          unlockedPath.cubicTo(
            controlPoint1.dx,
            controlPoint1.dy,
            controlPoint2.dx,
            controlPoint2.dy,
            p2.dx,
            p2.dy,
          );
        }
      }
    }

    final dashPaint = Paint()
      ..color = AppColors.surfaceTint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, dashPaint);

    final outlinePaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(unlockedPath, outlinePaint);
  }

  @override
  bool shouldRepaint(covariant _WindingPathPainter oldDelegate) =>
      oldDelegate.currentLevel != currentLevel;
}

class _MapNodeWidget extends StatelessWidget {
  const _MapNodeWidget({
    required this.item,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isClaimed,
  });

  final _PathItemData item;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isClaimed;

  @override
  Widget build(BuildContext context) {
    if (item.type == _PathNodeType.chest) {
      final chestBg = isUnlocked
          ? (isClaimed ? Colors.grey.shade400 : Colors.amber.shade600)
          : AppColors.surfaceTint;

      final chestWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StickerBadge(
            rotateAngle: isUnlocked && !isClaimed ? -0.06 : 0.04,
            backgroundColor: chestBg,
            borderColor: AppColors.primaryDark,
            borderWidth: 2.6,
            padding: const EdgeInsets.all(12),
            child: Icon(
              isClaimed ? Icons.check_circle_rounded : item.icon,
              color: isUnlocked ? Colors.white : AppColors.primaryDark.withValues(alpha: 0.4),
              size: 26,
            ),
          ),
          const SizedBox(height: 4),
          StickerBadge(
            rotateAngle: 0.03,
            backgroundColor: isClaimed ? Colors.grey.shade400 : Colors.amber.shade600,
            borderColor: AppColors.primaryDark,
            borderWidth: 1.8,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            child: Text(
              isClaimed ? 'CLAIMED' : 'MYSTERY CHEST (LVL 40)',
              style: GoogleFonts.fredoka(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );

      return _PulsingWrapper(
        shouldPulse: isUnlocked && !isClaimed,
        child: chestWidget,
      );
    }

    final bgColor = isUnlocked
        ? (isCurrent ? AppColors.accent : AppColors.darkContainer)
        : AppColors.surfaceTint;

    final iconColor = isUnlocked ? Colors.white : AppColors.primaryDark.withValues(alpha: 0.4);

    final nodeWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        StickerBadge(
          rotateAngle: isCurrent ? -0.06 : 0.04,
          backgroundColor: bgColor,
          borderColor: AppColors.primaryDark,
          borderWidth: 2.6,
          padding: const EdgeInsets.all(12),
          child: Icon(
            isUnlocked ? item.icon : Icons.lock_outline_rounded,
            color: iconColor,
            size: 26,
          ),
        ),
        const SizedBox(height: 4),
        StickerBadge(
          rotateAngle: 0.03,
          backgroundColor: AppColors.isDark ? AppColors.paperWhite : AppColors.surfaceWhite,
          borderColor: AppColors.isDark ? Colors.black : AppColors.primaryDark,
          borderWidth: 1.8,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            item.title.toUpperCase(),
            style: GoogleFonts.fredoka(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.isDark ? AppColors.paperText : AppColors.primaryDark,
            ),
          ),
        ),
      ],
    );

    return _PulsingWrapper(
      shouldPulse: isCurrent,
      child: nodeWidget,
    );
  }
}

/// A simple pulsing animation wrapper using built-in Flutter animation.
class _PulsingWrapper extends StatefulWidget {
  const _PulsingWrapper({
    required this.shouldPulse,
    required this.child,
  });

  final bool shouldPulse;
  final Widget child;

  @override
  State<_PulsingWrapper> createState() => _PulsingWrapperState();
}

class _PulsingWrapperState extends State<_PulsingWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.shouldPulse) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PulsingWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldPulse && !oldWidget.shouldPulse) {
      _controller.repeat(reverse: true);
    } else if (!widget.shouldPulse && oldWidget.shouldPulse) {
      _controller.stop();
      _controller.value = 0.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

class _ChestDialog extends StatelessWidget {
  const _ChestDialog({
    required this.item,
    required this.isUnlocked,
    required this.isClaimed,
    required this.onClaim,
  });

  final _PathItemData item;
  final bool isUnlocked;
  final bool isClaimed;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: TornPaperCard(
        backgroundColor: AppColors.surfaceWhite,
        shadowColor: AppColors.surfaceTint,
        borderWidth: 3.0,
        tornPosition: TornEdgePosition.both,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StickerBadge(
              rotateAngle: -0.05,
              backgroundColor: isUnlocked
                  ? (isClaimed ? Colors.grey : Colors.amber.shade700)
                  : AppColors.surfaceTint,
              borderColor: AppColors.primaryDark,
              borderWidth: 2.5,
              padding: const EdgeInsets.all(16),
              child: Icon(
                isClaimed ? Icons.check_circle_rounded : item.icon,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            WhiskerBannerHeader(
              title: item.title.toUpperCase(),
              fontSize: 16,
              rotateAngle: -0.03,
              backgroundColor: isUnlocked ? Colors.amber.shade700 : Colors.grey.shade400,
              textColor: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              isUnlocked
                  ? 'Selamat! Kamu telah mencapai Level 40 dan berhasil membuka Mystery Chest ini! Kamu meng-unlock 4 Tema Warna Eksklusif:'
                  : item.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 14),
            if (isUnlocked) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildThemeBadge(AppThemes.whiskerDark),
                  _buildThemeBadge(AppThemes.oceanBlue),
                  _buildThemeBadge(AppThemes.forestGreen),
                  _buildThemeBadge(AppThemes.sunsetOrange),
                ],
              ),
              const SizedBox(height: 16),
            ],
            if (isUnlocked && !isClaimed)
              GestureDetector(
                onTap: onClaim,
                child: StickerBadge(
                  rotateAngle: -0.02,
                  backgroundColor: AppColors.accent,
                  borderColor: AppColors.primaryDark,
                  borderWidth: 2.2,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Text(
                    'KLAIM & UNLOCK TEMA 🎁',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  isClaimed ? 'SUDAH DIBUKA (CEK PENGATURAN)' : 'TERKUNCI (REACH LEVEL 40)',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeBadge(AppThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.primaryDark, width: 1.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: theme.background,
              shape: BoxShape.circle,
              border: Border.all(color: theme.primaryDark, width: 0.8),
            ),
          ),
          const SizedBox(width: 3),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: theme.accent,
              shape: BoxShape.circle,
              border: Border.all(color: theme.primaryDark, width: 0.8),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            theme.name,
            style: GoogleFonts.fredoka(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: theme.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelDetailsDialog extends StatelessWidget {
  const _LevelDetailsDialog({
    required this.item,
    required this.isUnlocked,
    required this.isCurrent,
    required this.currentLevel,
  });

  final _PathItemData item;
  final bool isUnlocked;
  final bool isCurrent;
  final int currentLevel;

  @override
  Widget build(BuildContext context) {
    final statusText = isCurrent
        ? 'CURRENT TARGET'
        : (isUnlocked ? 'COMPLETED' : 'LOCKED (LEVEL ${item.minLevel})');

    final statusBg = isCurrent
        ? AppColors.accent
        : (isUnlocked ? Colors.green.shade600 : Colors.grey.shade400);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: TornPaperCard(
        backgroundColor: AppColors.surfaceWhite,
        shadowColor: AppColors.surfaceTint,
        borderWidth: 3.0,
        tornPosition: TornEdgePosition.both,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StickerBadge(
              rotateAngle: -0.05,
              backgroundColor: isUnlocked ? AppColors.primaryDark : AppColors.surfaceTint,
              borderColor: AppColors.primaryDark,
              borderWidth: 2.5,
              padding: const EdgeInsets.all(16),
              child: Icon(
                isUnlocked ? item.icon : Icons.lock_outline_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            WhiskerBannerHeader(
              title: item.title.toUpperCase(),
              fontSize: 16,
              rotateAngle: -0.03,
            ),
            const SizedBox(height: 8),
            StickerBadge(
              rotateAngle: 0.03,
              backgroundColor: statusBg,
              borderColor: AppColors.primaryDark,
              borderWidth: 1.8,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                statusText,
                style: GoogleFonts.fredoka(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              item.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PracticeScreen()),
                );
              },
              child: StickerBadge(
                rotateAngle: -0.02,
                backgroundColor: AppColors.accent,
                borderColor: AppColors.isDark ? Colors.black : AppColors.primaryDark,
                borderWidth: 2.2,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Text(
                  'START PRACTICE NOW 🎮',
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
