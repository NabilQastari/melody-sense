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

  // Turunan opacity praktis
  static Color get primaryDarkFaded => _currentTheme.primaryDarkFaded;
  static Color get accentFaded => _currentTheme.accentFaded;
}