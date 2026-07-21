import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider untuk instance SharedPreferences yang di-initialize saat start-up.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must override sharedPreferencesProvider in main.dart');
});

/// Melacak status kelulusan/membaca submode "Introduce" untuk setiap jenis latihan.
class EducationProgressNotifier extends StateNotifier<Map<String, bool>> {
  EducationProgressNotifier(this._prefs)
      : super({
          'note_recognition': _prefs.getBool('introduced_note_recognition') ?? false,
          'interval_training': _prefs.getBool('introduced_interval_training') ?? false,
          'melody_echo': _prefs.getBool('introduced_melody_echo') ?? false,
          'rhythm_match': _prefs.getBool('introduced_rhythm_match') ?? false,
        });

  final SharedPreferences _prefs;

  /// Tandai submode Introduce sebagai selesai dibaca.
  Future<void> markIntroduceCompleted(String modeKey) async {
    await _prefs.setBool('introduced_$modeKey', true);
    state = {
      ...state,
      modeKey: true,
    };
  }

  /// Reset seluruh status Introduce (misalnya saat Danger Zone reset).
  Future<void> resetAll() async {
    await _prefs.remove('introduced_note_recognition');
    await _prefs.remove('introduced_interval_training');
    await _prefs.remove('introduced_melody_echo');
    await _prefs.remove('introduced_rhythm_match');
    state = {
      'note_recognition': false,
      'interval_training': false,
      'melody_echo': false,
      'rhythm_match': false,
    };
  }
}

/// Provider state notifier untuk progres edukasi introduce.
final educationProgressProvider =
    StateNotifierProvider<EducationProgressNotifier, Map<String, bool>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return EducationProgressNotifier(prefs);
});
