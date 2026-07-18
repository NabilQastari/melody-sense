import 'package:flutter/foundation.dart';

import 'package:melody_sense/core/domain/entities/progression_entities.dart';
// Reuse kAvailableNotes & RoundFeedback dari Note Recognition — keduanya
// generik (bukan spesifik note recognition), tapi belum ada rumah
// bersama untuk ini. Pertimbangkan pindahkan ke core/ kalau fitur
// ketiga (Melody Echo/Rhythm Match) butuh juga.
//
// `export` di baris berikutnya WAJIB ada (bukan cuma `import ... show`)
// supaya file lain yang meng-import interval_training_state.dart (mis.
// controller) ikut kebagian kedua nama ini — import biasa tidak
// diteruskan secara transitif, cuma berlaku di file ini sendiri.
import 'package:melody_sense/features/note_recognition/presentation/state/note_recognition_state.dart'
    show kAvailableNotes, RoundFeedback;
export 'package:melody_sense/features/note_recognition/presentation/state/note_recognition_state.dart'
    show kAvailableNotes, RoundFeedback;

/// Definisi satu interval musik: nama tampilan + jarak semitone (naik).
class IntervalDefinition {
  const IntervalDefinition(this.name, this.semitones);

  final String name;
  final int semitones;
}

/// Interval yang didukung mode ini. Nama & jarak semitone standar teori
/// musik — dibatasi ke yang bisa dibentuk NAIK (ascending) dari salah
/// satu nada di [kAvailableNotes] ke nada lain yang juga ada di
/// [kAvailableNotes] (lihat [kValidIntervalRounds]).
const kIntervalDefinitions = [
  IntervalDefinition('Minor 2nd', 1),
  IntervalDefinition('Major 2nd', 2),
  IntervalDefinition('Minor 3rd', 3),
  IntervalDefinition('Major 3rd', 4),
  IntervalDefinition('Perfect 4th', 5),
  IntervalDefinition('Perfect 5th', 7),
  IntervalDefinition('Major 6th', 9),
  IntervalDefinition('Major 7th', 11),
  IntervalDefinition('Octave', 12),
];

/// Posisi semitone tiap nada di [kAvailableNotes], C4 = 0 sebagai acuan.
/// Dipakai untuk menghitung nada target dari root note + interval.
/// NOTE: nada-nada ini diatonis (bukan kromatis penuh), jadi jaraknya
/// tidak selalu 1 semitone antar nada bertetangga di daftar.
const _semitoneByNote = {
  'B3': -1,
  'C4': 0,
  'D4': 2,
  'E4': 4,
  'F4': 5,
  'G4': 7,
  'A4': 9,
  'B4': 11,
  'C5': 12,
};

/// Satu kombinasi root+interval yang valid — nada target-nya (root +
/// semitones) juga ada di [kAvailableNotes], jadi bisa dijawab dengan
/// menekan tuts piano yang tersedia (tidak semua root x interval punya
/// pasangan valid, mis. D4 + Major 3rd = F#4 yang tidak ada di daftar).
@immutable
class IntervalRoundOption {
  const IntervalRoundOption({
    required this.rootNote,
    required this.targetNote,
    required this.intervalName,
  });

  final String rootNote;
  final String targetNote;
  final String intervalName;
}

/// Semua kombinasi (root, interval, target) yang valid dalam batas
/// kAvailableNotes (B3-C5). Dihitung sekali (top-level final, bukan
/// di-generate ulang tiap ronde) — dipakai IntervalTrainingController
/// untuk memilih ronde acak.
final List<IntervalRoundOption> kValidIntervalRounds = _buildValidRounds();

List<IntervalRoundOption> _buildValidRounds() {
  final noteBySemitone = {
    for (final entry in _semitoneByNote.entries) entry.value: entry.key,
  };

  final options = <IntervalRoundOption>[];
  for (final root in kAvailableNotes) {
    final rootSemitone = _semitoneByNote[root]!;
    for (final interval in kIntervalDefinitions) {
      final targetNote = noteBySemitone[rootSemitone + interval.semitones];
      if (targetNote != null) {
        options.add(IntervalRoundOption(
          rootNote: root,
          targetNote: targetNote,
          intervalName: interval.name,
        ));
      }
    }
  }
  return options;
}

@immutable
class IntervalTrainingState {
  const IntervalTrainingState({
    required this.currentRound,
    required this.sessionId,
    this.xp = 0,
    this.livesTotal = 3,
    this.livesRemaining = 3,
    this.roundIndex = 0,
    this.correctCount = 0,
    this.totalRounds = 10,
    this.feedback = RoundFeedback.none,
    this.isSessionOver = false,
    this.completion,
  });

  final IntervalRoundOption currentRound;
  final int sessionId;
  final int xp;
  final int livesTotal;
  final int livesRemaining;

  /// Jumlah ronde yang SUDAH diselesaikan (benar maupun salah).
  final int roundIndex;

  /// Jumlah jawaban BENAR saja — sama seperti Note Recognition, dipisah
  /// dari roundIndex supaya akurasi sesi tidak perlu ditebak dari xp.
  final int correctCount;
  final int totalRounds;
  final RoundFeedback feedback;
  final bool isSessionOver;

  /// Hasil ProgressionRepository.completeSession() — null selama sesi
  /// masih berjalan ATAU sudah berakhir tapi orkestrasi progression
  /// belum selesai diawait. Sama seperti Note Recognition, screen
  /// menunggu field ini terisi sebelum pindah ke SessionResultScreen.
  final SessionCompletionResult? completion;

  String get rootNote => currentRound.rootNote;

  /// Nada kedua (jawaban) yang harus ditebak user — TIDAK ditampilkan
  /// langsung di UI, cuma dipakai controller untuk mencocokkan jawaban.
  String get targetNote => currentRound.targetNote;

  String get intervalName => currentRound.intervalName;

  /// 0.0 - 1.0, dikonsumsi langsung oleh ExplorerGameplayScreen.progress.
  double get progress =>
      totalRounds == 0 ? 0.0 : (roundIndex / totalRounds).clamp(0.0, 1.0);

  /// 0.0 - 1.0, dikonsumsi SessionResultScreen (ring akurasi).
  double get accuracy =>
      roundIndex == 0 ? 0.0 : (correctCount / roundIndex).clamp(0.0, 1.0);

  /// Menang = sesi berakhir karena semua ronde selesai dengan hearts
  /// masih tersisa (bukan karena hearts habis).
  bool get isWin => livesRemaining > 0;

  IntervalTrainingState copyWith({
    IntervalRoundOption? currentRound,
    int? sessionId,
    int? xp,
    int? livesTotal,
    int? livesRemaining,
    int? roundIndex,
    int? correctCount,
    int? totalRounds,
    RoundFeedback? feedback,
    bool? isSessionOver,
    SessionCompletionResult? completion,
  }) {
    return IntervalTrainingState(
      currentRound: currentRound ?? this.currentRound,
      sessionId: sessionId ?? this.sessionId,
      xp: xp ?? this.xp,
      livesTotal: livesTotal ?? this.livesTotal,
      livesRemaining: livesRemaining ?? this.livesRemaining,
      roundIndex: roundIndex ?? this.roundIndex,
      correctCount: correctCount ?? this.correctCount,
      totalRounds: totalRounds ?? this.totalRounds,
      feedback: feedback ?? this.feedback,
      isSessionOver: isSessionOver ?? this.isSessionOver,
      completion: completion ?? this.completion,
    );
  }
}