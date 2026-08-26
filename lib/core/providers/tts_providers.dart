import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';

/// Provider singleton untuk TTSService
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService(ref);
});

/// StateNotifier untuk mengelola status toggle Pengaturan TTS Global (Aksesibilitas)
class SenseModeNotifier extends StateNotifier<bool> {
  SenseModeNotifier(this._ref) : super(false) {
    _loadFromPrefs();
  }

  final Ref _ref;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('sense_mode') ?? false;
    state = enabled;
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sense_mode', enabled);

    if (enabled) {
      _ref.read(ttsServiceProvider).speak(
            'Panduan suara TTS diaktifkan untuk seluruh aplikasi.',
            force: true,
          );
    } else {
      _ref.read(ttsServiceProvider).stop();
      _ref.read(ttsServiceProvider).speak(
            'Panduan suara TTS dinonaktifkan.',
            force: true,
          );
    }
  }
}

/// Provider state untuk status aktif/nonaktif Sense Mode
final senseModeProvider =
    StateNotifierProvider<SenseModeNotifier, bool>((ref) {
  return SenseModeNotifier(ref);
});
