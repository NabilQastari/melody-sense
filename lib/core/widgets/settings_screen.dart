import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/theme/app_theme_data.dart';
import 'package:melody_sense/core/domain/entities/note_notation.dart';
import 'package:melody_sense/core/providers/database_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';
import 'package:melody_sense/core/providers/note_notation_provider.dart';
import 'package:melody_sense/core/providers/theme_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

import 'package:melody_sense/features/progression/presentation/screens/progression_screen.dart';

/// Settings Screen - Sesi 9 (Pengaturan Aplikasi)
/// Menggunakan TornDivider dan WhiskerBannerHeader sesuai Desain.md.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _volume = 1.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _volume = prefs.getDouble('piano_volume') ?? 1.0;
      _isLoading = false;
    });
  }

  Future<void> _updateVolume(double value) async {
    setState(() => _volume = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('piano_volume', value);
    SoLoud.instance.setGlobalVolume(value * 1.8);
  }

  Future<void> _updateSenseMode(bool value) async {
    await ref.read(senseModeProvider.notifier).toggle(value);
  }

  Future<void> _resetProgress() async {
    final db = ref.read(appDatabaseProvider);
    final repo = ref.read(progressionRepositoryProvider);

    setState(() => _isLoading = true);

    try {
      await db.transaction(() async {
        await db.delete(db.attempts).go();
        await db.delete(db.sessions).go();
        await db.delete(db.personalBests).go();
        await db.delete(db.achievements).go();
      });

      await repo.seedDefaultAchievementsIfEmpty();
      await ref.read(educationProgressProvider.notifier).resetAll();
      await ref.read(unlockedThemesProvider.notifier).resetAll();
      await ref.read(claimedChestsProvider.notifier).resetAll();
      await ref.read(themeProvider.notifier).setTheme(AppThemes.defaultTheme);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Histori latihan berhasil di-reset!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal reset progress: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar Header (Whisker Style) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryDark, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.15),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const WhiskerBannerHeader(
                    title: 'PENGATURAN',
                    fontSize: 15,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Body Scrollable ──
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      children: [
                        // ── Audio Section ──
                        _buildSectionHeader('AUDIO & VOLUMEN'),
                        const SizedBox(height: 10),
                        _buildCard([
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Volume Suara Piano',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    Text(
                                      '${(_volume * 100).toInt()}%',
                                      style: GoogleFonts.fredoka(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.volume_mute_rounded,
                                        size: 20, color: AppColors.primaryDark.withValues(alpha: 0.5)),
                                    Expanded(
                                      child: Slider(
                                        value: _volume,
                                        onChanged: _updateVolume,
                                        activeColor: AppColors.accent,
                                        inactiveColor: AppColors.surfaceTint,
                                      ),
                                    ),
                                    Icon(Icons.volume_up_rounded,
                                        size: 20, color: AppColors.primaryDark.withValues(alpha: 0.8)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        const TornDivider(opacity: 0.35),
                        const SizedBox(height: 16),

                        // ── Theme Selector Section (hidden until Mystery Chest opened) ──
                        Consumer(
                          builder: (context, ref, _) {
                            final claimedSet = ref.watch(claimedChestsProvider);
                            final hasOpenedChest = claimedSet.contains(40);

                            if (!hasOpenedChest) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('TEMA WARNA'),
                                const SizedBox(height: 10),
                                _buildCard([
                                  Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Pilih Tema Palette Aplikasi',
                                          style: GoogleFonts.fredoka(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tema eksklusif dari Mystery Chest Level 40!',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryDark.withValues(alpha: 0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Consumer(
                                          builder: (context, ref, _) {
                                            final activeTheme = ref.watch(themeProvider);
                                            final unlockedSet = ref.watch(unlockedThemesProvider);

                                            return Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children: AppThemes.all.map((theme) {
                                                final isUnlocked = unlockedSet.contains(theme.id);
                                                final isSelected = activeTheme.id == theme.id;

                                                return GestureDetector(
                                                  onTap: isUnlocked
                                                      ? () => ref.read(themeProvider.notifier).setTheme(theme)
                                                      : () {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Tema ini terkunci! Capai Level 40 dan buka Mystery Chest.'),
                                                              duration: Duration(seconds: 2),
                                                            ),
                                                          );
                                                        },
                                                  child: Opacity(
                                                    opacity: isUnlocked ? 1.0 : 0.55,
                                                    child: Container(
                                                      width: 140,
                                                      padding: const EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                        color: theme.surfaceWhite,
                                                        borderRadius: BorderRadius.circular(14),
                                                        border: Border.all(
                                                          color: isSelected ? theme.accent : theme.primaryDark,
                                                          width: isSelected ? 3.0 : 1.8,
                                                        ),
                                                        boxShadow: [
                                                          if (isSelected)
                                                            BoxShadow(
                                                              color: theme.accent.withValues(alpha: 0.3),
                                                              blurRadius: 6,
                                                              offset: const Offset(0, 2),
                                                            ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              // Palette Dots
                                                              Container(
                                                                width: 14,
                                                                height: 14,
                                                                decoration: BoxDecoration(
                                                                  color: theme.background,
                                                                  shape: BoxShape.circle,
                                                                  border:
                                                                      Border.all(color: theme.primaryDark, width: 1),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Container(
                                                                width: 14,
                                                                height: 14,
                                                                decoration: BoxDecoration(
                                                                  color: theme.surfaceTint,
                                                                  shape: BoxShape.circle,
                                                                  border:
                                                                      Border.all(color: theme.primaryDark, width: 1),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Container(
                                                                width: 14,
                                                                height: 14,
                                                                decoration: BoxDecoration(
                                                                  color: theme.accent,
                                                                  shape: BoxShape.circle,
                                                                  border:
                                                                      Border.all(color: theme.primaryDark, width: 1),
                                                                ),
                                                              ),
                                                              const Spacer(),
                                                              if (!isUnlocked)
                                                                Icon(Icons.lock_outline_rounded,
                                                                    size: 14, color: theme.primaryDark)
                                                              else if (isSelected)
                                                                Icon(Icons.check_circle_rounded,
                                                                    size: 16, color: theme.accent),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            theme.name,
                                                            style: GoogleFonts.fredoka(
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              color: theme.primaryDark,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 16),
                                const TornDivider(opacity: 0.35),
                                const SizedBox(height: 16),
                              ],
                            );
                          },
                        ),

                        // ── Accessibility Section ──
                        _buildSectionHeader('AKSESIBILITAS & TTS'),
                        const SizedBox(height: 10),
                        _buildCard([
                          SwitchListTile(
                            value: ref.watch(senseModeProvider),
                            onChanged: _updateSenseMode,
                            title: Text(
                              'Sense Mode',
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            subtitle: Text(
                              'Mengaktifkan panduan suara (TTS) & getaran taktil untuk tunanetra.',
                              style: TextStyle(fontSize: 11.5, color: AppColors.primaryDark.withValues(alpha: 0.7)),
                            ),
                            activeTrackColor: AppColors.accent,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          ),
                          const Divider(height: 1, indent: 16, endIndent: 16),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Format Notasi Pembacaan Suara (TTS)',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pilih bagaimana TTS membaca nama nada saat latihan.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.primaryDark.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final currentNotation = ref.watch(noteNotationProvider);
                                    return Row(
                                      children: [
                                        Expanded(
                                          child: ChoiceChip(
                                            label: const Text('Solfège (Do Re Mi)'),
                                            selected: currentNotation == NoteNotation.solfege,
                                            onSelected: (selected) {
                                              if (selected) {
                                                ref.read(noteNotationProvider.notifier).setNotation(NoteNotation.solfege);
                                              }
                                            },
                                            selectedColor: AppColors.accent,
                                            labelStyle: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: currentNotation == NoteNotation.solfege ? Colors.white : AppColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ChoiceChip(
                                            label: const Text('Scientific (C D E)'),
                                            selected: currentNotation == NoteNotation.scientific,
                                            onSelected: (selected) {
                                              if (selected) {
                                                ref.read(noteNotationProvider.notifier).setNotation(NoteNotation.scientific);
                                              }
                                            },
                                            selectedColor: AppColors.accent,
                                            labelStyle: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                              color: currentNotation == NoteNotation.scientific ? Colors.white : AppColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]),
                        const SizedBox(height: 16),
                        const TornDivider(opacity: 0.35),
                        const SizedBox(height: 16),

                        // ── Danger Zone ──
                        _buildSectionHeader('DANGER ZONE'),
                        const SizedBox(height: 10),
                        _buildCard([
                          ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: AppColors.surfaceWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    side: BorderSide(color: AppColors.primaryDark, width: 2.4),
                                  ),
                                  title: Text(
                                    'Reset Histori Latihan?',
                                    style: GoogleFonts.fredoka(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  content: Text(
                                      'Seluruh histori latihan, statistik akurasi nada, XP, level, dan tema unlocked Anda akan dihapus secara permanen.',
                                      style: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.85)),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Batal',
                                          style: GoogleFonts.fredoka(
                                              color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _resetProgress();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade600,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          side: BorderSide(color: AppColors.primaryDark, width: 2),
                                        ),
                                      ),
                                      child: Text('Reset Data',
                                          style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            title: Text(
                              'Reset Progress Latihan',
                              style: GoogleFonts.fredoka(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.red.shade700,
                              ),
                            ),
                            subtitle: const Text(
                              'Hapus seluruh statistik, XP, level, dan pencapaian.',
                              style: TextStyle(fontSize: 11, color: Colors.redAccent),
                            ),
                            trailing: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                          ),
                        ]),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return WhiskerBannerHeader(
      title: title,
      fontSize: 13,
      rotateAngle: -0.02,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.1),
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
