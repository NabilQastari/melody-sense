import 'package:flutter/material.dart';

import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/app_bottom_nav.dart';
import 'package:melody_sense/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:melody_sense/features/practice/presentation/screens/practice_screen.dart';
import 'package:melody_sense/features/progression/presentation/screens/progression_screen.dart';
import 'package:melody_sense/features/stats/presentation/screens/stats_screen.dart';

/// Shell utama app — menampung semua tab di satu tempat lewat
/// [IndexedStack] + bottom nav. Hanya SATU navbar yang ada, dan dia
/// hilang otomatis saat user masuk gameplay (karena gameplay screen
/// di-push ON TOP of this, menutupi navbar).
///
/// Default tab: Practice (index 1).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Dashboard tab (Sesi 9 default)

  static const _tabs = <AppTab>[
    AppTab.dashboard,
    AppTab.practice,
    AppTab.progression,
    AppTab.stats,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  DashboardScreen(),     // 0
                  PracticeScreen(),      // 1
                  ProgressionScreen(),   // 2
                  StatsScreen(),         // 3
                ],
              ),
            ),
            AppBottomNav(
              currentTab: _tabs[_currentIndex],
              onTabSelected: (tab) {
                final idx = _tabs.indexOf(tab);
                if (idx >= 0) setState(() => _currentIndex = idx);
              },
            ),
          ],
        ),
      ),
    );
  }
}


