import 'package:flutter/material.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/theme/app_theme_data.dart';

/// Reusable App Logo Avatar Widget.
///
/// Menampilkan logo bertema dinamis yang menyesuaikan warna tema aktif:
/// - Default (Lavender Dream) : assets/images/logo_lavender.png
/// - Whisker Dark             : assets/images/logo_whisker_dark.png
/// - Ocean Blue               : assets/images/logo_ocean_blue.png
/// - Forest Green             : assets/images/logo_forest_green.png
/// - Sunset Orange            : assets/images/logo_sunset_orange.png
class AppLogoAvatar extends StatelessWidget {
  const AppLogoAvatar({
    super.key,
    this.size = 38.0,
    this.onTap,
  });

  final double size;
  final VoidCallback? onTap;

  /// Memetakan ID tema aktif ke jalur asset PNG yang sesuai
  static String getLogoAssetPath(String themeId) {
    switch (themeId) {
      case AppThemes.whiskerDarkId:
        return 'assets/images/logo_whisker_dark.png';
      case AppThemes.oceanBlueId:
        return 'assets/images/logo_ocean_blue.png';
      case AppThemes.forestGreenId:
        return 'assets/images/logo_forest_green.png';
      case AppThemes.sunsetOrangeId:
        return 'assets/images/logo_sunset_orange.png';
      case AppThemes.defaultId:
      default:
        return 'assets/images/logo_lavender.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeId = AppColors.currentTheme.id;
    final logoPath = getLogoAssetPath(themeId);

    Widget content = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        logoPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback jika file gambar logo belum ditaruh di assets/images/
          return Icon(
            Icons.music_note_rounded,
            size: size * 0.75,
            color: AppColors.primaryDark,
          );
        },
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
