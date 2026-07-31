import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/splash_screen.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/providers/theme_providers.dart';

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

class MelodySenseApp extends ConsumerWidget {
  const MelodySenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(themeProvider);
    AppColors.applyTheme(activeTheme);

    return MaterialApp(
      key: ValueKey(activeTheme.id),
      title: 'Melody Sense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: activeTheme.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: activeTheme.primaryDark,
          primary: activeTheme.primaryDark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}