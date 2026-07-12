import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

// Import semua screen yang sudah dibuat — tinggal pilih salah satu
// di bagian `home:` MaterialApp di bawah untuk preview.
import 'package:melody_sense/features/note_recognition/presentation/screens/note_recognition_screen.dart';
import 'package:melody_sense/features/interval_training/presentation/screens/interval_training_screen.dart';
import 'package:melody_sense/features/melody_echo/presentation/screens/melody_echo_screen.dart';
import 'package:melody_sense/features/maestro_mode/presentation/screens/maestro_challenge_screen.dart';

/// ENTRY POINT SEMENTARA — hanya untuk preview UI selama pengembangan.
///
/// File ini akan diganti dengan versi final yang menggunakan go_router
/// begitu navigasi antar mode (Sesi 8+) mulai dikerjakan.
///
/// Cara pakai: ganti nilai `home:` di bawah untuk preview screen lain.
/// Putar HP (atau resize window) untuk lihat perbedaan layout
/// portrait vs landscape pada Explorer & Maestro screen.
///
/// ProviderScope WAJIB ada di sini — audioServiceProvider (Riverpod)
/// dipakai oleh NoteRecognitionScreen & IntervalTrainingScreen untuk
/// memutar audio nada.
void main() {
  runApp(const ProviderScope(child: MelodySensePreviewApp()));
}

class MelodySensePreviewApp extends StatelessWidget {
  const MelodySensePreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melody Sense (Preview)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDark,
          primary: AppColors.primaryDark,
        ),
      ),

      // ── Pilih salah satu untuk preview ──────────────────────────
      home: const NoteRecognitionScreen(),
      // home: const IntervalTrainingScreen(),
      // home: const MelodyEchoScreen(),
      // home: const MaestroChallengeScreen(),
    );
  }
}