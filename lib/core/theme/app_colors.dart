import 'package:flutter/material.dart';

/// Color palette resmi Melody Sense.
/// Diambil dari palette resmi desain tim (Sesi 3).
class AppColors {
  AppColors._();

  /// #51508B — heading, tombol utama, ikon aktif
  static const Color primaryDark = Color(0xFF51508B);

  /// #F2F5FF — latar layar
  static const Color background = Color(0xFFF2F5FF);

  /// #D5D4FF — card ungu muda, progress track (belum terisi)
  static const Color surfaceTint = Color(0xFFD5D4FF);

  /// #8197E5 — highlight tuts piano aktif, progress fill, aksen interaktif
  static const Color accent = Color(0xFF8197E5);

  // Turunan praktis yang sering dipakai di UI, supaya tidak hardcode
  // di banyak tempat. Nilai berikut BUKAN dari palette resmi,
  // hanya opacity/varian dari 4 warna di atas.
  static const Color surfaceWhite = Colors.white;
  static Color primaryDarkFaded = primaryDark.withValues(alpha: 0.6);
  static Color accentFaded = accent.withValues(alpha: 0.15);
}