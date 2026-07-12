import 'package:just_audio/just_audio.dart';

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
/// Desain: satu [AudioPlayer] per nada, di-preload sekali lewat
/// [initialize], supaya saat nada ditekan playback nyaris instan
/// (`seek(Duration.zero)` + `play()`) — bukan load-dari-nol tiap kali,
/// yang akan terasa lag untuk kebutuhan ear training real-time.
///
/// CATATAN PENTING: path asset di bawah membutuhkan file audio
/// sungguhan di `assets/audio/notes/{note}.mp3`, didaftarkan di
/// `pubspec.yaml` (lihat instruksi terpisah). Selama file belum ada,
/// [playNote] akan diam-diam no-op (tidak crash), supaya UI tetap
/// bisa dites tanpa aset. Evaluasi latensi (lihat context file)
/// dilakukan setelah file asli terpasang — kalau masih terasa lag,
/// pertimbangkan flutter_soloud sebagai pengganti.
class AudioService {
  final Map<String, AudioPlayer> _players = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Preload semua sample nada. Panggil sekali di awal (mis. lewat
  /// Riverpod provider), bukan tiap kali mau main nada.
  Future<void> initialize() async {
    if (_isInitialized) return;
    for (final note in kSupportedNotes) {
      final player = AudioPlayer();
      try {
        await player.setAsset('assets/audio/notes/$note.mp3');
      } catch (_) {
        // Asset belum ada — aman diabaikan saat masih tahap UI-only.
        // playNote() akan no-op untuk nada ini sampai asetnya tersedia.
      }
      _players[note] = player;
    }
    _isInitialized = true;
  }

  /// Mainkan satu nada dari awal. No-op kalau nada tidak dikenali
  /// atau asetnya belum ter-load.
  Future<void> playNote(String note) async {
    final player = _players[note];
    if (player == null) return;
    try {
      await player.seek(Duration.zero);
      await player.play();
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
  /// `ref.onDispose` di provider) untuk melepas semua resource player.
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
    _isInitialized = false;
  }
}