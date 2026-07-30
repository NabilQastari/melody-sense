import 'package:flutter_tts/flutter_tts.dart';

/// TTSService — Layanan Text-to-Speech untuk Sense Mode (Aksesibilitas)
/// 
/// Membantu membaca narasi soal, feedback benar/salah, nama nada,
/// serta instruksi aplikasi dalam Bahasa Indonesia (`id-ID`).
class TTSService {
  TTSService() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isEnabled = false;

  /// Inisialisasi engine TTS dengan bahasa Indonesia
  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('id-ID');
      await _flutterTts.setSpeechRate(0.5); // Kecepatan bicara sedang
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      // Fallback jika id-ID tidak tersedia di beberapa device
      try {
        await _flutterTts.setLanguage('en-US');
        _isInitialized = true;
      } catch (_) {}
    }
  }

  /// Atur apakah Sense Mode aktif
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Status apakah Sense Mode sedang aktif
  bool get isEnabled => _isEnabled;

  /// Ucapkan teks jika Sense Mode diaktifkan
  Future<void> speak(String text, {bool force = false}) async {
    if ((!_isEnabled && !force) || text.trim().isEmpty) return;

    if (!_isInitialized) {
      await _initTts();
    }

    try {
      await _flutterTts.stop(); // Hentikan narasi sebelumnya jika ada
      await _flutterTts.speak(text);
    } catch (e) {
      // Ignore speak errors
    }
  }

  /// Hentikan suara TTS
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }
}
