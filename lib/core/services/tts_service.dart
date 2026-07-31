import 'dart:async';
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
  Completer<void>? _speakCompleter;

  /// Inisialisasi engine TTS dengan bahasa Indonesia
  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('id-ID');
      await _flutterTts.setSpeechRate(0.5); // Kecepatan bicara sedang
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Callback saat selesai berbicara
      _flutterTts.setCompletionHandler(() {
        _speakCompleter?.complete();
        _speakCompleter = null;
      });

      _isInitialized = true;
    } catch (e) {
      // Fallback jika id-ID tidak tersedia di beberapa device
      try {
        await _flutterTts.setLanguage('en-US');
        _flutterTts.setCompletionHandler(() {
          _speakCompleter?.complete();
          _speakCompleter = null;
        });
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

  /// Ucapkan teks jika Sense Mode diaktifkan.
  /// Menunggu sampai speech selesai (await-able).
  Future<void> speak(String text, {bool force = false}) async {
    if ((!_isEnabled && !force) || text.trim().isEmpty) return;

    if (!_isInitialized) {
      await _initTts();
    }

    try {
      await _flutterTts.stop(); // Hentikan narasi sebelumnya jika ada
      _speakCompleter = Completer<void>();
      await _flutterTts.speak(text);
      await _speakCompleter?.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {},
      );
    } catch (e) {
      // Ignore speak errors
    }
  }

  /// Ucapkan beberapa frasa secara berurutan (satu per satu, sequential).
  /// Contoh: speakSequence(['Ronde 1', 'Tekan note C4'])
  Future<void> speakSequence(List<String> phrases, {bool force = false}) async {
    if (!_isEnabled && !force) return;
    for (final phrase in phrases) {
      if (phrase.trim().isEmpty) continue;
      await speak(phrase, force: force);
    }
  }

  /// Mengubah notasi ilmiah (mis. C#4, D4) menjadi ucapan bahasa Indonesia yang ramah (solfège + nama nada).
  String formatNoteForSpeech(String note) {
    switch (note) {
      case 'B3':
        return 'Si, B3';
      case 'C4':
        return 'Do, C4';
      case 'C#4':
        return 'Do Kres, C Sharp 4';
      case 'D4':
        return 'Re, D4';
      case 'D#4':
        return 'Re Kres, D Sharp 4';
      case 'E4':
        return 'Mi, E4';
      case 'F4':
        return 'Fa, F4';
      case 'F#4':
        return 'Fa Kres, F Sharp 4';
      case 'G4':
        return 'Sol, G4';
      case 'G#4':
        return 'Sol Kres, G Sharp 4';
      case 'A4':
        return 'La, A4';
      case 'A#4':
        return 'La Kres, A Sharp 4';
      case 'B4':
        return 'Si, B4';
      case 'C5':
        return 'Do tinggi, C5';
      default:
        return note.replaceAll('#', ' Kres ');
    }
  }

  /// Hentikan suara TTS
  Future<void> stop() async {
    try {
      _speakCompleter?.complete();
      _speakCompleter = null;
      await _flutterTts.stop();
    } catch (_) {}
  }
}
