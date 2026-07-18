import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/features/stats/presentation/providers/stats_providers.dart';

/// Progression Screen - Sesi 8 (Peta Level / Progression Path)
///
/// Menampilkan peta petualangan nada (Roadmap/Path) berdasarkan level user.
/// Menampilkan Day Streak dan Total XP aktual dari database di bagian atas.
class ProgressionScreen extends ConsumerWidget {
  const ProgressionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelInfoAsync = ref.watch(levelInfoProvider);
    final streakAsync = ref.watch(streakProvider);

    return Column(
      children: [
        // ── Shared App Bar Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceTint,
                child: Icon(Icons.person, size: 18, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 10),
              const Text(
                'Melody Sense',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              const Spacer(),
              Icon(Icons.settings_outlined, color: AppColors.primaryDark.withValues(alpha: 0.6)),
            ],
          ),
        ),

        // ── Main Body ──
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
                        iconColor: Colors.orange.shade700,
                        cardBgColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
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
                        iconColor: AppColors.primaryDark,
                        cardBgColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Winding Path map ──
                levelInfoAsync.when(
                  loading: () => const Center(
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
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.cardBgColor,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color cardBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Node data class for Level Map
class _PathNodeData {
  final int minLevel;
  final int maxLevel;
  final String title;
  final IconData icon;

  const _PathNodeData({
    required this.minLevel,
    required this.maxLevel,
    required this.title,
    required this.icon,
  });
}

class _LevelPathMap extends StatelessWidget {
  const _LevelPathMap({required this.currentLevel});

  final int currentLevel;

  static const List<_PathNodeData> nodes = [
    _PathNodeData(
      minLevel: 1,
      maxLevel: 9,
      title: 'Beginner',
      icon: Icons.star_rounded,
    ),
    _PathNodeData(
      minLevel: 10,
      maxLevel: 19,
      title: 'Scale Master',
      icon: Icons.keyboard_rounded,
    ),
    _PathNodeData(
      minLevel: 20,
      maxLevel: 29,
      title: 'Interval Hero',
      icon: Icons.headphones_rounded,
    ),
    _PathNodeData(
      minLevel: 30,
      maxLevel: 39,
      title: 'Melody Maestro',
      icon: Icons.music_note_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const double mapHeight = 520.0;

    return SizedBox(
      height: mapHeight + 180, // Tambah space agar chest/text di bawah tidak terpotong
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // ── The Winding Dashed Line ──
          Positioned.fill(
            child: CustomPaint(
              painter: _WindingPathPainter(),
            ),
          ),

          // ── Level Nodes positioned along the curve ──
          ...List.generate(nodes.length, (index) {
            final node = nodes[index];
            final double relativeY = index / (nodes.length); // 0.0 to 0.75
            final double yPos = relativeY * mapHeight + 40;

            // X offset calculated from sine wave to match the custom painter path
            final double xOffset = math.sin(relativeY * 2.5 * math.pi) * 60;

            // Logika Range Level:
            // - Completed: Level user sudah melewati batas maksimal range node ini.
            // - Active: Level user masuk dalam range [minLevel, maxLevel] node ini.
            // - Locked: Level user belum mencapai batas minimal range node ini.
            final isCompleted = currentLevel > node.maxLevel;
            final isActive = currentLevel >= node.minLevel && currentLevel <= node.maxLevel;
            final isLocked = currentLevel < node.minLevel;

            return Positioned(
              top: yPos,
              left: 0,
              right: 0,
              child: _buildNodeWidget(node, xOffset, isCompleted, isActive, isLocked),
            );
          }),

          // ── Node 5: Dash Mystery Gift at the very end ──
          Positioned(
            top: mapHeight + 30,
            left: 0,
            right: 0,
            child: Transform.translate(
              offset: Offset(math.sin(2.5 * math.pi) * 60, 0),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 2.5,
                        style: BorderStyle.solid,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Icon(
                        Icons.card_giftcard_rounded,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'UNLOCK LEVEL 40 TO REVEAL',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNodeWidget(
    _PathNodeData node,
    double xOffset,
    bool isCompleted,
    bool isActive,
    bool isLocked,
  ) {
    Color nodeBgColor;
    Color iconColor;
    Border? border;
    List<BoxShadow>? shadow;

    if (isCompleted) {
      nodeBgColor = AppColors.accent;
      iconColor = Colors.white;
      shadow = [
        BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        )
      ];
    } else if (isActive) {
      nodeBgColor = AppColors.accent;
      iconColor = Colors.white;
      border = Border.all(color: Colors.white, width: 3);
      shadow = [
        BoxShadow(
          color: AppColors.accent.withValues(alpha: 0.4),
          blurRadius: 14,
          offset: const Offset(0, 4),
        )
      ];
    } else {
      // Locked
      nodeBgColor = Colors.grey.shade300;
      iconColor = Colors.grey.shade500;
    }

    return Transform.translate(
      offset: Offset(xOffset, 0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: nodeBgColor,
                    shape: BoxShape.circle,
                    border: border,
                    boxShadow: shadow,
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_outline_rounded : node.icon,
                    color: iconColor,
                    size: 26,
                  ),
                ),
                // Play badge for Active Node
                if (isActive)
                  Positioned(
                    top: 0,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                // Completed label banner next to Completed node
                if (isCompleted)
                  Positioned(
                    left: -70,
                    top: 18,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              node.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: isLocked ? Colors.grey.shade500 : AppColors.primaryDark,
              ),
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Text(
                'CURRENT UNIT',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark.withValues(alpha: 0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Custom Painter to draw winding dashed line path matching the sine wave positions.
class _WindingPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceTint.withValues(alpha: 0.6)
      ..strokeWidth = 6.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const double mapHeight = 520.0;
    
    // Draw path using exact same sine math formula as node positioning
    for (double y = 40; y <= mapHeight + 70; y += 4) {
      final double relativeY = (y - 40) / mapHeight;
      final double x = size.width / 2 + math.sin(relativeY * 2.5 * math.pi) * 60;
      
      if (y == 40) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Convert solid path to dashed line
    final dashPath = _buildDashedPath(path, 12, 10);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashedPath(Path source, double dashWidth, double dashGap) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final length = draw ? dashWidth : dashGap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
