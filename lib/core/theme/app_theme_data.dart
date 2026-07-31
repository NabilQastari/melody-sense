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
    this.paperWhite = const Color(0xFFFFFFFF),
    this.paperText = const Color(0xFF141418),
    this.isUnlockable = true,
  });

  final String id;
  final String name;
  final Color primaryDark;
  final Color background;
  final Color surfaceTint;
  final Color accent;
  final Color surfaceWhite;
  final Color paperWhite;
  final Color paperText;
  final bool isUnlockable;

  bool get isDark => id == AppThemes.whiskerDarkId;

  Color get primaryDarkFaded => primaryDark.withValues(alpha: 0.6);
  Color get accentFaded => accent.withValues(alpha: 0.15);

  /// Container bertema gelap (untuk Banner Header / Dark Cards / Action Badges)
  Color get darkContainer => isDark ? const Color(0xFF282634) : primaryDark;

  /// Warna teks di dalam container bertema gelap
  Color get darkContainerText => isDark ? const Color(0xFFFFF8EE) : Colors.white;

  /// Warna outline/stroke untuk teks dan border bertema komik ink
  Color get inkBorder => isDark ? const Color(0xFF000000) : primaryDark;

  /// Warna tuts putih piano agar tetap terang & kontras di dark mode
  Color get pianoWhiteKey => isDark ? const Color(0xFFFFFDF8) : surfaceWhite;

  /// Warna tuts hitam piano
  Color get pianoBlackKey => isDark ? const Color(0xFF121216) : const Color(0xFF1E222D);
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
    primaryDark: Color(0xFFFFF8EE), // Soft warm cream for main text and borders
    background: Color(0xFF101014),  // Deep charcoal black background (The Whisker Watch theme)
    surfaceTint: Color(0xFF2E2A38), // Dark shadow elevation stack tint
    accent: Color(0xFFFF2B4A),      // Iconic vibrant Whisker Red accent (pitch deck red)
    surfaceWhite: Color(0xFF1E1D26),// Sleek dark charcoal surface fill for cards
    paperWhite: Color(0xFFFFF8EE),  // Warm cream for torn paper badges
    paperText: Color(0xFF101014),   // Dark text on white/cream paper
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
