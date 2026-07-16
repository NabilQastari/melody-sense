import 'package:flutter_soloud/flutter_soloud.dart';

/// 9 nada dasar sesuai hardware Smart Piano (prototipe Arduino Mega).
const List<String> kSupportedNotes = [
  'B3',
  'C4',
  'D4',
  'E4',
  'F4',
  'G4',
  'A4',
  'B4',
  'C5',
];

/// Mengelola playback audio nada untuk Explorer Mode (virtual piano).
///
/// PINDAH DARI just_audio KE flutter_soloud (evaluasi Sesi 3):
/// just_audio ternyata tidak cukup responsif untuk ear training —
/// delay terasa & tidak bisa "spam" tuts yang sama karena satu
/// AudioPlayer cuma punya satu posisi playback aktif.
///
/// flutter_soloud (native, berbasis SoLoud C++ engine) menyelesaikan
/// dua masalah itu sekaligus:
/// - Latensi jauh lebih rendah karena engine native, bukan lewat
///   platform channel per pemanggilan seperti just_audio.
/// - Tiap panggilan [SoLoud.instance.play] menghasilkan voice
///   instance baru & independen (polyphony) — nada yang sama bisa
///   ditumpuk/di-spam tanpa perlu menunggu instance sebelumnya
///   selesai atau di-reset.
///
/// CATATAN PENTING: path asset di bawah membutuhkan file audio
/// sungguhan di `assets/audio/notes/{note}.mp3`, didaftarkan di
/// `pubspec.yaml`. Selama file belum ada, [playNote] akan diam-diam
/// no-op (tidak crash).
class AudioService {
  final Map<String, AudioSource> _sources = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Inisialisasi SoLoud engine & preload semua sample nada. Panggil
  /// sekali di awal (lewat Riverpod provider), bukan tiap kali mau
  /// main nada.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await SoLoud.instance.init();
    } catch (_) {
      // Sudah ter-init sebelumnya, atau native lib gagal dimuat —
      // tidak boleh sampai crash app.
    }

    for (final note in kSupportedNotes) {
      try {
        final source =
            await SoLoud.instance.loadAsset('assets/audio/notes/$note.mp3');
        _sources[note] = source;
      } catch (_) {
        // Asset belum ada — aman diabaikan saat masih tahap UI-only.
        // playNote() akan no-op untuk nada ini sampai asetnya tersedia.
      }
    }
    _isInitialized = true;
  }

  /// Mainkan satu nada. No-op kalau nada tidak dikenali atau asetnya
  /// belum ter-load.
  ///
  /// Bisa dipanggil berkali-kali beruntun untuk nada yang sama
  /// (spam tuts) — tiap panggilan jadi voice instance baru yang
  /// independen, tidak saling menunggu/reset.
  Future<void> playNote(String note) async {
    final source = _sources[note];
    if (source == null) return;
    try {
      await SoLoud.instance.play(source);
    } catch (_) {
      // Abaikan error playback — audio gagal main tidak boleh sampai
      // meng-crash UI.
    }
  }

  /// Mainkan beberapa nada berurutan dengan jeda [gap] di antaranya.
  /// Dipakai untuk Auto Play & preview sequence (Interval Training,
  /// Melody Echo).
  Future<void> playSequence(
    List<String> notes, {
    Duration gap = const Duration(milliseconds: 450),
  }) async {
    for (var i = 0; i < notes.length; i++) {
      await playNote(notes[i]);
      if (i != notes.length - 1) {
        await Future.delayed(gap);
      }
    }
  }

  /// Panggil saat AudioService tidak dipakai lagi (mis. lewat
  /// `ref.onDispose` di provider) untuk melepas semua resource.
  Future<void> dispose() async {
    for (final source in _sources.values) {
      try {
        await SoLoud.instance.disposeSource(source);
      } catch (_) {
        // Sudah disposed atau error lain — aman diabaikan saat cleanup.
      }
    }
    _sources.clear();
    SoLoud.instance.deinit();
    _isInitialized = false;
  }
}