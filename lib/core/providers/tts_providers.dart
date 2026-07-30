import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';

/// Provider singleton untuk TTSService
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService();
});

/// StateNotifier untuk mengelola status toggle Sense Mode (Aksesibilitas)
class SenseModeNotifier extends StateNotifier<bool> {
  SenseModeNotifier(this._ref) : super(false) {
    _loadFromPrefs();
  }

  final Ref _ref;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('sense_mode') ?? false;
    state = enabled;
    _ref.read(ttsServiceProvider).setEnabled(enabled);
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sense_mode', enabled);
    _ref.read(ttsServiceProvider).setEnabled(enabled);

    if (enabled) {
      _ref.read(ttsServiceProvider).speak(
            'Sense Mode diaktifkan. Melacak narasi suara dan navigasi taktil.',
            force: true,
          );
    } else {
      _ref.read(ttsServiceProvider).speak(
            'Sense Mode dinonaktifkan.',
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
