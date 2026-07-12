/// Entity domain, sengaja tidak bergantung ke Drift sama sekali
/// supaya logic game bisa ditest tanpa database (sesuai prinsip Clean Architecture
/// yang disepakati Sesi 1).

enum TrainingMode {
  noteRecognition,
  intervalTraining,
  melodyEcho,
  rhythmMatch;

  /// String yang disimpan di kolom `mode` pada tabel Sessions/PersonalBests.
  String get storageKey {
    switch (this) {
      case TrainingMode.noteRecognition:
        return 'note_recognition';
      case TrainingMode.intervalTraining:
        return 'interval_training';
      case TrainingMode.melodyEcho:
        return 'melody_echo';
      case TrainingMode.rhythmMatch:
        return 'rhythm_match';
    }
  }

  static TrainingMode fromStorageKey(String key) {
    return TrainingMode.values.firstWhere((m) => m.storageKey == key);
  }
}

class PracticeSession {
  final int id;
  final TrainingMode mode;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int xpEarned;
  final int score;

  const PracticeSession({
    required this.id,
    required this.mode,
    required this.startedAt,
    this.endedAt,
    this.xpEarned = 0,
    this.score = 0,
  });
}

class NoteAttempt {
  final int id;
  final int sessionId;
  final String note;
  final bool isCorrect;
  final int responseTimeMs;
  final DateTime timestamp;

  const NoteAttempt({
    required this.id,
    required this.sessionId,
    required this.note,
    required this.isCorrect,
    required this.responseTimeMs,
    required this.timestamp,
  });
}

class NoteAccuracyStat {
  final String note;
  final int totalAttempts;
  final int correctAttempts;
  final double accuracy; // 0.0 - 1.0

  const NoteAccuracyStat({
    required this.note,
    required this.totalAttempts,
    required this.correctAttempts,
    required this.accuracy,
  });
}
