import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/theme/app_theme_data.dart';

/// StateNotifier untuk Tema Warna Aktif
class ThemeNotifier extends StateNotifier<AppThemeData> {
  ThemeNotifier(this._prefs)
      : super(
          AppThemes.getById(
            _prefs.getString('selected_theme_id') ?? AppThemes.defaultId,
          ),
        );

  final SharedPreferences _prefs;

  /// Mengubah tema warna aktif aplikasi.
  Future<void> setTheme(AppThemeData theme) async {
    await _prefs.setString('selected_theme_id', theme.id);
    state = theme;
  }
}

/// Provider untuk tema warna aktif
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeData>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});

/// StateNotifier untuk daftar ID tema yang sudah terbuka (unlocked)
class UnlockedThemesNotifier extends StateNotifier<Set<String>> {
  UnlockedThemesNotifier(this._prefs)
      : super(
          (_prefs.getStringList('unlocked_theme_ids') ?? [AppThemes.defaultId])
              .toSet(),
        );

  final SharedPreferences _prefs;

  /// Unlock tema baru (misalnya saat klaim Mystery Chest Level 40)
  Future<void> unlockThemes(List<String> themeIds) async {
    final updated = {...state, ...themeIds};
    await _prefs.setStringList('unlocked_theme_ids', updated.toList());
    state = updated;
  }

  /// Reset tema unlocked ke default
  Future<void> resetAll() async {
    await _prefs.remove('unlocked_theme_ids');
    await _prefs.remove('selected_theme_id');
    state = {AppThemes.defaultId};
  }
}

/// Provider untuk daftar ID tema yang sudah unlocked
final unlockedThemesProvider =
    StateNotifierProvider<UnlockedThemesNotifier, Set<String>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UnlockedThemesNotifier(prefs);
});
