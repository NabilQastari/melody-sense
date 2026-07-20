import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/audio/audio_service.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart';
import 'package:melody_sense/core/domain/repositories/practice_repository.dart';
import 'package:melody_sense/core/domain/repositories/progression_repository.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/database_providers.dart';

import '../state/note_recognition_state.dart';

/// XP tetap per jawaban benar. Belum ada bonus kecepatan/streak —
/// bisa direvisi kalau tim mau menambahkan itu di sesi polish.
const _xpPerCorrect = 10;

/// Domain logic Note Recognition: generate target nada, cek jawaban,
/// catat setiap attempt ke [PracticeRepository], update hearts/xp,
/// dan tutup sesi (submit skor + level/streak/achievement lewat
/// [ProgressionRepository]) begitu hearts habis atau semua ronde selesai.
///
/// State null berarti sesi baru masih dalam proses dibuat
/// (menunggu `startSession` yang async) — UI wajib menghandle ini
/// (lihat NoteRecognitionScreen).
class NoteRecognitionController extends StateNotifier<NoteRecognitionState?> {
  NoteRecognitionController(this._ref) : super(null) {
    _start();
  }

  final Ref _ref;
  final _random = Random();
  DateTime? _roundStartedAt;
  bool _isTransitioning = false;

  PracticeRepository get _practiceRepo =>
      _ref.read(practiceRepositoryProvider);
  ProgressionRepository get _progressionRepo =>
      _ref.read(progressionRepositoryProvider);
  AudioService get _audio => _ref.read(audioServiceProvider);

  Future<void> _start() async {
    // Seeding achievement default (idempotent — no-op kalau tabel sudah
    // terisi). Sementara dipanggil di sini karena app belum punya titik
    // startup tunggal (main.dart masih preview screen manual, belum
    // go_router — lihat konteks proyek). Pindahkan ke startup app begitu
    // itu siap, supaya tidak dipanggil ulang tiap kali layar ini dibuka.
    await _progressionRepo.seedDefaultAchievementsIfEmpty();

    final sessionId = await _practiceRepo.startSession(
      TrainingMode.noteRecognition,
    );
    final target = _pickNextNote();
    state = NoteRecognitionState(
      targetNote: target,
      sessionId: sessionId,
      mysteryRoundIndex: _random.nextInt(10), // Ronde acak 0-9
    );
    _roundStartedAt = DateTime.now();
    _isTransitioning = false;

    // Putar nada target pertama setelah inisialisasi selesai & audio siap
    Future.delayed(const Duration(milliseconds: 500), () {
      _playNoteWithStatus(target);
    });
  }

  /// Pilih nada acak, hindari sama persis dengan [avoid] (nada ronde
  /// sebelumnya) supaya tidak terasa berulang.
  String _pickNextNote([String? avoid]) {
    String note;
    do {
      note = kAvailableNotes[_random.nextInt(kAvailableNotes.length)];
    } while (note == avoid && kAvailableNotes.length > 1);
    return note;
  }

  Future<void> _playNoteWithStatus(String note) async {
    if (!mounted) return;
    state = state?.copyWith(isPlaying: true);
    await _audio.playNote(note);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    state = state?.copyWith(isPlaying: false);
  }

  /// Dipanggil dari tombol Auto Play / kartu prompt — memutar ulang
  /// nada target tanpa dihitung sebagai jawaban.
  Future<void> playTarget() async {
    final current = state;
    if (current == null || _isTransitioning) return;
    await _playNoteWithStatus(current.targetNote);
  }

  /// Dipanggil setiap kali user menekan tuts piano. Ini yang dianggap
  /// sebagai jawaban (bukan aksi eksplorasi bebas) — sesuai desain
  /// Note Recognition di mana setiap tuts yang ditekan langsung dinilai.
  Future<void> submitAnswer(String note) async {
    final current = state;
    if (current == null || current.isSessionOver || _isTransitioning) return;

    _isTransitioning = true;
    _audio.playNote(note);

    final isCorrect = note == current.targetNote;
    final responseTimeMs = _roundStartedAt == null
        ? 0
        : DateTime.now().difference(_roundStartedAt!).inMilliseconds;

    await _practiceRepo.logAttempt(
      sessionId: current.sessionId,
      note: note,
      isCorrect: isCorrect,
      responseTimeMs: responseTimeMs,
    );

    final isMystery = current.roundIndex == current.mysteryRoundIndex;
    final addedXp = isCorrect ? (isMystery ? _xpPerCorrect * 2 : _xpPerCorrect) : 0;
    final nextXp = current.xp + addedXp;
    final nextLives = isCorrect ? current.livesRemaining : current.livesRemaining - 1;
    final nextCorrectCount = isCorrect ? current.correctCount + 1 : current.correctCount;
    final sessionOver = nextLives <= 0 || (current.roundIndex + 1) >= current.totalRounds;

    // Update state dengan feedback dan detail input
    state = current.copyWith(
      xp: nextXp,
      livesRemaining: nextLives,
      correctCount: nextCorrectCount,
      feedback: isCorrect ? RoundFeedback.correct : RoundFeedback.wrong,
      lastPressedNote: note,
    );

    if (!isCorrect) {
      // Compare playback: nada target -> jeda singkat -> nada salah yang ditekan user
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        _audio.playSequence([current.targetNote, note], gap: const Duration(milliseconds: 500));
      });
    }

    // Tunggu durasi transisi (lebih lama jika salah agar compare playback selesai)
    final delayMs = isCorrect ? 1200 : 2000;
    await Future.delayed(Duration(milliseconds: delayMs));

    if (!mounted) return;

    if (sessionOver) {
      state = state?.copyWith(isSessionOver: true);
      await _finishSession(xpEarned: nextXp);
    } else {
      final nextRoundIndex = current.roundIndex + 1;
      final nextNote = _pickNextNote(current.targetNote);
      state = state?.copyWith(
        roundIndex: nextRoundIndex,
        targetNote: nextNote,
        feedback: RoundFeedback.none,
        lastPressedNote: null,
      );
      _roundStartedAt = DateTime.now();
      _isTransitioning = false;

      // Putar nada target ronde baru secara otomatis
      _playNoteWithStatus(nextNote);
    }
  }

  Future<void> _finishSession({required int xpEarned}) async {
    final current = state;
    if (current == null) return;

    // Skor sederhana = XP yang didapat sesi ini. Definisi skor yang
    // lebih canggih (mis. bobot response time) bisa direvisi saat
    // statistik/leaderboard digarap (Sesi 7-8).
    final score = xpEarned;

    await _practiceRepo.finishSession(
      sessionId: current.sessionId,
      xpEarned: xpEarned,
      score: score,
    );

    // Dipanggil SETELAH finishSession() supaya getTotalXp() di dalam
    // completeSession() sudah mencakup XP sesi ini (dipakai untuk
    // deteksi level-up).
    final completion = await _progressionRepo.completeSession(
      mode: TrainingMode.noteRecognition,
      score: score,
      xpEarnedThisSession: xpEarned,
      correctCount: current.correctCount,
      totalRounds: current.totalRounds,
    );

    // Pakai `state` (bukan `current`) supaya merge di atas nilai terbaru,
    // berjaga-jaga kalau ada perubahan state lain selama await di atas.
    if (!mounted) return;
    state = state?.copyWith(completion: completion);
  }

  /// Mulai sesi baru dari awal (xp/hearts/round direset). Belum ada
  /// tombol "Main Lagi" di UI Sesi 3-4, tapi controller sudah siap
  /// dipanggil begitu tombolnya ada.
  Future<void> restart() => _start();

}

final noteRecognitionControllerProvider = StateNotifierProvider.autoDispose<
    NoteRecognitionController, NoteRecognitionState?>(
  (ref) => NoteRecognitionController(ref),
);
