import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The 4 top-level tabs shown in the app's bottom navigation.
enum AppTab { dashboard, practice, progression, stats }

/// Bottom nav bar — desain mengikuti pola SessionResultScreen
/// (ikon + label teks, active tab warna gelap + underline indicator,
/// inactive abu-abu). SATU instance di HomeScreen, bukan per-halaman.
///
/// Navbar ini TIDAK tampil di halaman gameplay atau hasil sesi —
/// halaman-halaman itu di-push ON TOP of HomeScreen, sehingga
/// navbar tertutup secara alami.
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
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          top: BorderSide(
            color: AppColors.surfaceTint.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
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
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            // Underline indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: active ? 24 : 0,
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.circular(1),
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