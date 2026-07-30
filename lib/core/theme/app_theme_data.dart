import 'package:flutter/material.dart';

/// Definisi satu tema warna untuk Melody Sense.
class AppThemeData {
  const AppThemeData({
    required this.id,
    required this.name,
    required this.primaryDark,
    required this.background,
    required this.surfaceTint,
    required this.accent,
    this.surfaceWhite = Colors.white,
    this.isUnlockable = true,
  });

  final String id;
  final String name;
  final Color primaryDark;
  final Color background;
  final Color surfaceTint;
  final Color accent;
  final Color surfaceWhite;
  final bool isUnlockable;

  Color get primaryDarkFaded => primaryDark.withValues(alpha: 0.6);
  Color get accentFaded => accent.withValues(alpha: 0.15);
}

/// Registry semua tema yang tersedia di Melody Sense.
class AppThemes {
  AppThemes._();

  static const String defaultId = 'default';
  static const String whiskerDarkId = 'whisker_dark';
  static const String oceanBlueId = 'ocean_blue';
  static const String forestGreenId = 'forest_green';
  static const String sunsetOrangeId = 'sunset_orange';

  static const AppThemeData defaultTheme = AppThemeData(
    id: defaultId,
    name: 'Lavender Dream',
    primaryDark: Color(0xFF51508B),
    background: Color(0xFFF2F5FF),
    surfaceTint: Color(0xFFD5D4FF),
    accent: Color(0xFF8197E5),
    isUnlockable: false, // selalu terbuka
  );

  static const AppThemeData whiskerDark = AppThemeData(
    id: whiskerDarkId,
    name: 'Whisker Dark',
    primaryDark: Color(0xFFFFF8EE),
    background: Color(0xFF141417),
    surfaceTint: Color(0xFF2D2D35),
    accent: Color(0xFFE6344A),
    surfaceWhite: Color(0xFF222228),
  );

  static const AppThemeData oceanBlue = AppThemeData(
    id: oceanBlueId,
    name: 'Ocean Blue',
    primaryDark: Color(0xFF1B3A5C),
    background: Color(0xFFE8F4FD),
    surfaceTint: Color(0xFFB8D8EB),
    accent: Color(0xFF4CA6D8),
  );

  static const AppThemeData forestGreen = AppThemeData(
    id: forestGreenId,
    name: 'Forest Green',
    primaryDark: Color(0xFF2D5016),
    background: Color(0xFFF0F7E8),
    surfaceTint: Color(0xFFC5E0A5),
    accent: Color(0xFF6BBF4E),
  );

  static const AppThemeData sunsetOrange = AppThemeData(
    id: sunsetOrangeId,
    name: 'Sunset Orange',
    primaryDark: Color(0xFF6B2D10),
    background: Color(0xFFFFF5EB),
    surfaceTint: Color(0xFFF5D0B0),
    accent: Color(0xFFE88540),
  );

  /// Semua tema tersedia (urut tampilan).
  static const List<AppThemeData> all = [
    defaultTheme,
    whiskerDark,
    oceanBlue,
    forestGreen,
    sunsetOrange,
  ];

  /// Tema-tema yang di-unlock dari Mystery Chest Level 40.
  static const List<String> chestUnlockIds = [
    whiskerDarkId,
    oceanBlueId,
    forestGreenId,
    sunsetOrangeId,
  ];

  static AppThemeData getById(String id) {
    return all.firstWhere(
      (t) => t.id == id,
      orElse: () => defaultTheme,
    );
  }
}
