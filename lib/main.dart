import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/home_screen.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';

/// Entry point — HomeScreen menampung semua tab (Dashboard, Practice,
/// Progression, Stats) lewat IndexedStack + satu bottom navbar.
///
/// ProviderScope WAJIB ada di sini — audioServiceProvider (Riverpod)
/// dipakai oleh NoteRecognitionScreen & IntervalTrainingScreen untuk
/// memutar audio nada.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MelodySenseApp(),
    ),
  );
}



class MelodySenseApp extends StatelessWidget {
  const MelodySenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melody Sense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryDark,
          primary: AppColors.primaryDark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}