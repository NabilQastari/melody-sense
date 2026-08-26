import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../domain/entities/note_notation.dart';
import '../domain/entities/operating_mode.dart';
import '../providers/operating_mode_providers.dart';
import '../providers/tts_providers.dart';

/// TTSService — Layanan Text-to-Speech untuk Sense Mode (Aksesibilitas)
/// 
/// Membantu membaca narasi soal, feedback benar/salah, nama nada,
/// serta instruksi aplikasi dalam Bahasa Indonesia (`id-ID` / `in-ID`).
class TTSService {
  TTSService(this._ref) {
    _initTts();
  }

  final Ref _ref;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  Completer<void>? _speakCompleter;

  /// Status apakah TTS sedang aktif.
  /// TTS aktif jika Global TTS Setting (`senseModeProvider`) bernilai true,
  /// ATAU mode operasional saat ini adalah Sense Mode (`AppOperatingMode.sense`).
  bool get isEnabled {
    final globalTts = _ref.read(senseModeProvider);
    final mode = _ref.read(operatingModeProvider);
    return globalTts || mode == AppOperatingMode.sense;
  }

  /// Compatibility helper method
  void setEnabled(bool enabled) {
    // Dynamic calculation via isEnabled getter
  }

  /// Inisialisasi engine TTS dengan bahasa Indonesia (dengan fallback in-ID -> en-US)
  Future<void> _initTts() async {
    try {
      // 1. Coba id-ID (Standard Kode Indonesia)
      final bool isIdAvailable = await _flutterTts.isLanguageAvailable('id-ID');
      if (isIdAvailable) {
        await _flutterTts.setLanguage('id-ID');
      } else {
        // 2. Coba in-ID (ISO Locale lama di Android)
        final bool isInAvailable = await _flutterTts.isLanguageAvailable('in-ID');
        if (isInAvailable) {
          await _flutterTts.setLanguage('in-ID');
        } else {
          // 3. Fallback ke en-US
          await _flutterTts.setLanguage('en-US');
        }
      }

      await _flutterTts.setSpeechRate(0.48); // Kecepatan bicara sedang
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Callback saat selesai berbicara
      _flutterTts.setCompletionHandler(() {
        _speakCompleter?.complete();
        _speakCompleter = null;
      });

      _isInitialized = true;
    } catch (e) {
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

  /// Ucapkan teks jika Sense Mode / Global TTS diaktifkan.
  /// Menunggu sampai speech selesai (await-able).
  Future<void> speak(String text, {bool force = false}) async {
    if ((!isEnabled && !force) || text.trim().isEmpty) return;

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
  /// Contoh: speakSequence(['Ronde 1', 'Tekan nada Do'])
  Future<void> speakSequence(List<String> phrases, {bool force = false}) async {
    if (!isEnabled && !force) return;
    for (final phrase in phrases) {
      if (phrase.trim().isEmpty) continue;
      await speak(phrase, force: force);
    }
  }

  /// Mengubah notasi ilmiah (mis. C#4, D4) menjadi ucapan berdasarkan opsi `NoteNotation`.
  /// `solfege`: "Do, Re, Mi, Fa..." (tanpa embel-embel C4/F4)
  /// `scientific`: "C4, D4, F Sharp 4..."
  String formatNoteForSpeech(String note, [NoteNotation notation = NoteNotation.solfege]) {
    if (notation == NoteNotation.solfege) {
      switch (note) {
        case 'B3':
          return 'Si rendah';
        case 'C4':
          return 'Do';
        case 'C#4':
          return 'Do Kres';
        case 'D4':
          return 'Re';
        case 'D#4':
          return 'Re Kres';
        case 'E4':
          return 'Mi';
        case 'F4':
          return 'Fa';
        case 'F#4':
          return 'Fa Kres';
        case 'G4':
          return 'Sol';
        case 'G#4':
          return 'Sol Kres';
        case 'A4':
          return 'La';
        case 'A#4':
          return 'La Kres';
        case 'B4':
          return 'Si';
        case 'C5':
          return 'Do tinggi';
        default:
          return note.replaceAll('#', ' Kres ');
      }
    } else {
      switch (note) {
        case 'C#4':
          return 'C Sharp 4';
        case 'D#4':
          return 'D Sharp 4';
        case 'F#4':
          return 'F Sharp 4';
        case 'G#4':
          return 'G Sharp 4';
        case 'A#4':
          return 'A Sharp 4';
        default:
          return note;
      }
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
