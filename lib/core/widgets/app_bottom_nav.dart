import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum AppTab { dashboard, practice, progression, stats }

/// Bottom nav bar — diperbarui dengan Design System v3 micro sticker-dot indicator
/// pada ikon aktif tanpa menggunakan torn paper agar tetap stabil & bersih.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  static const _items = <_NavItem>[
    _NavItem(AppTab.dashboard, Icons.grid_view_rounded, 'Dashboard'),
    _NavItem(AppTab.practice, Icons.music_note_rounded, 'Practice'),
    _NavItem(AppTab.progression, Icons.trending_up_rounded, 'Progression'),
    _NavItem(AppTab.stats, Icons.bar_chart_rounded, 'Stats'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryDark,
            width: 2.2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.1),
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _items.map((item) {
          final active = item.tab == currentTab;
          return _buildItem(item, active);
        }).toList(),
      ),
    );
  }

  Widget _buildItem(_NavItem item, bool active) {
    final color = active ? AppColors.primaryDark : Colors.grey.shade400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTabSelected(item.tab),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Icon(item.icon, size: 22, color: color),
                if (active)
                  Positioned(
                    top: -2,
                    right: -4,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryDark, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: GoogleFonts.fredoka(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: active ? 28 : 0,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.tab, this.icon, this.label);
  final AppTab tab;
  final IconData icon;
  final String label;
}