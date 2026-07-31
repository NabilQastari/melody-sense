import 'package:flutter/material.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/app_bottom_nav.dart';
import 'package:melody_sense/core/widgets/app_logo_avatar.dart';

/// Placeholder Dashboard screen — konten belum dirancang (lihat Sesi 9
/// di context file). Untuk sekarang menampilkan pesan placeholder supaya
/// navigasi tab sudah berfungsi penuh.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _PlaceholderAppBar(),
            Expanded(
              child: Center(
                child: _PlaceholderBody(
                  icon: Icons.grid_view_rounded,
                  title: 'Dashboard',
                  subtitle: 'Coming soon — Sesi 9',
                ),
              ),
            ),
            AppBottomNav(
              currentTab: AppTab.dashboard,
              onTabSelected: (tab) =>
                  navigateTab(context, AppTab.dashboard, tab),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder Progression screen — konten belum dirancang (lihat Sesi 8
/// di context file).
class ProgressionScreen extends StatelessWidget {
  const ProgressionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _PlaceholderAppBar(),
            Expanded(
              child: Center(
                child: _PlaceholderBody(
                  icon: Icons.swap_horiz_rounded,
                  title: 'Progression',
                  subtitle: 'Coming soon — Sesi 8',
                ),
              ),
            ),
            AppBottomNav(
              currentTab: AppTab.progression,
              onTabSelected: (tab) =>
                  navigateTab(context, AppTab.progression, tab),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Shared tab navigation
// ═══════════════════════════════════════════════════════════════════

/// Navigasi antar tab tanpa go_router. PracticeScreen (home) selalu
/// ada di bawah stack, tab lain di-push di atasnya.
///
/// - Tap Practice → popUntil first route (kembali ke PracticeScreen).
/// - Tap tab lain dari PracticeScreen → push screen baru.
/// - Tap tab lain dari non-Practice → pushReplacement (ganti, bukan
///   tumpuk, supaya stack tidak bertambah terus).
///
/// Fungsi ini public supaya bisa dipakai oleh PracticeScreen dan
/// StatsScreen juga (mereka mengimpor file ini).
void navigateTab(BuildContext context, AppTab current, AppTab target) {
  if (target == current) return;

  if (target == AppTab.practice) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    return;
  }

  final Widget screen;
  switch (target) {
    case AppTab.dashboard:
      screen = const DashboardScreen();
    case AppTab.progression:
      screen = const ProgressionScreen();
    case AppTab.stats:
      // StatsScreen diimpor dan di-push oleh caller (practice_screen,
      // stats_screen sendiri) yang sudah punya import-nya. Dari sini
      // (Dashboard/Progression) kita juga perlu bisa ke Stats.
      // Lazy import via deferred bukan opsi di Flutter, jadi kita
      // pakai callback yang di-register oleh StatsScreen.
      screen = _statsScreenBuilder?.call() ?? const SizedBox();
    case AppTab.practice:
      return; // handled above
  }

  if (current == AppTab.practice) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  } else {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

/// Callback yang didaftarkan oleh file yang punya akses ke StatsScreen
/// (practice_screen.dart), supaya placeholder_screens.dart tidak perlu
/// import stats_screen.dart langsung (menghindari potential issues).
Widget Function()? _statsScreenBuilder;

/// Dipanggil sekali dari file yang mengimpor StatsScreen untuk
/// mendaftarkan builder-nya.
void registerStatsScreenBuilder(Widget Function() builder) {
  _statsScreenBuilder = builder;
}

// ═══════════════════════════════════════════════════════════════════
//  Shared placeholder widgets
// ═══════════════════════════════════════════════════════════════════

class _PlaceholderAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const AppLogoAvatar(),
          const SizedBox(width: 10),
          Text(
            'Melody Sense',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const Spacer(),
          Icon(Icons.settings_outlined,
              color: AppColors.primaryDark.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}

class _PlaceholderBody extends StatelessWidget {
  const _PlaceholderBody({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 56,
            color: AppColors.primaryDark.withValues(alpha: 0.2)),
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primaryDark.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
