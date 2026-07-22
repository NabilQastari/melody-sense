import 'package:flutter/foundation.dart';

enum SongDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case SongDifficulty.easy:
        return 'Easy';
      case SongDifficulty.medium:
        return 'Medium';
      case SongDifficulty.hard:
        return 'Hard';
    }
  }
}

@immutable
class RhythmSong {
  const RhythmSong({
    required this.id,
    required this.title,
    required this.artist,
    required this.difficulty,
    required this.bpm,
    required this.notes,
    required this.description,
  });

  final String id;
  final String title;
  final String artist;
  final SongDifficulty difficulty;
  final int bpm;

  /// Urutan nada melodi lagu dari awal sampai akhir.
  final List<String> notes;

  final String description;

  int get totalNotes => notes.length;
}

/// Daftar lagu bawaan untuk Rhythm Match yang pas untuk 14 tuts piano.
const kRhythmSongs = [
  RhythmSong(
    id: 'mary_lamb',
    title: 'Mary Had a Little Lamb',
    artist: 'Traditional',
    difficulty: SongDifficulty.easy,
    bpm: 85,
    description: 'Melodi klasik populer sederhana berurutan nada E4, D4, C4, G4.',
    notes: [
      'E4', 'D4', 'C4', 'D4', 'E4', 'E4', 'E4',
      'D4', 'D4', 'D4', 'E4', 'G4', 'G4',
      'E4', 'D4', 'C4', 'D4', 'E4', 'E4', 'E4', 'E4',
      'D4', 'D4', 'E4', 'D4', 'C4',
    ],
  ),
  RhythmSong(
    id: 'happy_birthday',
    title: 'Happy Birthday',
    artist: 'Traditional',
    difficulty: SongDifficulty.medium,
    bpm: 95,
    description: 'Lagu populer dengan tuts hitam A#4 & melodi oktaf tinggi C5.',
    notes: [
      'C4', 'C4', 'D4', 'C4', 'F4', 'E4',
      'C4', 'C4', 'D4', 'C4', 'G4', 'F4',
      'C4', 'C4', 'C5', 'A4', 'F4', 'E4', 'D4',
      'A#4', 'A#4', 'A4', 'F4', 'G4', 'F4',
    ],
  ),
  RhythmSong(
    id: 'ode_to_joy',
    title: 'Ode to Joy (Beethoven)',
    artist: 'L. v. Beethoven',
    difficulty: SongDifficulty.hard,
    bpm: 110,
    description: 'Tema utama simfoni ke-9 Beethoven yang megah mencakup nada B3 s/d G4.',
    notes: [
      // Frase A
      'E4', 'E4', 'F4', 'G4', 'G4', 'F4', 'E4', 'D4',
      'C4', 'C4', 'D4', 'E4', 'E4', 'D4', 'D4',

      // Frase A' (variasi, kadens ke tonik)
      'E4', 'E4', 'F4', 'G4', 'G4', 'F4', 'E4', 'D4',
      'C4', 'C4', 'D4', 'E4', 'D4', 'C4', 'C4',

      // Frase B
      'D4', 'D4', 'E4', 'C4', 'D4', 'E4', 'F4', 'E4', 'C4',
      'D4', 'E4', 'F4', 'E4', 'C4', 'C4',

      // Frase A'' (penutup)
      'D4', 'D4', 'E4', 'C4', 'D4', 'E4', 'F4', 'E4', 'C4',
      'D4', 'E4', 'D4', 'C4', 'C4', 'C4',
    ],
  ),
];
