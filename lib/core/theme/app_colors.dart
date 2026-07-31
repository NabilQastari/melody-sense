import 'package:flutter/material.dart';
import 'package:melody_sense/core/theme/app_theme_data.dart';

/// Color palette resmi Melody Sense.
/// Mendukung dynamic theme switching (Default, Whisker Dark, Ocean Blue, dll).
class AppColors {
  AppColors._();

  static AppThemeData _currentTheme = AppThemes.defaultTheme;

  /// Terapkan tema warna aktif.
  static void applyTheme(AppThemeData theme) {
    _currentTheme = theme;
  }

  static AppThemeData get currentTheme => _currentTheme;

  /// Express getter whether active theme is Dark Mode
  static bool get isDark => _currentTheme.isDark;

  /// Heading, tombol utama, ikon aktif, outline ink
  static Color get primaryDark => _currentTheme.primaryDark;

  /// Latar belakang layar
  static Color get background => _currentTheme.background;

  /// Card tint, progress track (belum terisi)
  static Color get surfaceTint => _currentTheme.surfaceTint;

  /// Highlight tuts piano aktif, progress fill, aksen interaktif
  static Color get accent => _currentTheme.accent;

  /// Warna dasar kartu/permukaan (Putih atau Abu Gelap di Dark Mode)
  static Color get surfaceWhite => _currentTheme.surfaceWhite;

  /// Warna kertas stiker / torn paper terang
  static Color get paperWhite => _currentTheme.paperWhite;

  /// Warna teks di atas paper white
  static Color get paperText => _currentTheme.paperText;

  /// Container bertema gelap (untuk banner/badge serbaguna)
  static Color get darkContainer => _currentTheme.darkContainer;

  /// Teks di dalam dark container
  static Color get darkContainerText => _currentTheme.darkContainerText;

  /// Warna outline/stroke komik ink
  static Color get inkBorder => _currentTheme.inkBorder;

  /// Warna tuts piano
  static Color get pianoWhiteKey => _currentTheme.pianoWhiteKey;
  static Color get pianoBlackKey => _currentTheme.pianoBlackKey;

  // Turunan opacity praktis
  static Color get primaryDarkFaded => _currentTheme.primaryDarkFaded;
  static Color get accentFaded => _currentTheme.accentFaded;
}