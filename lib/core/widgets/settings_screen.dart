import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/providers/database_providers.dart';
import 'package:melody_sense/core/providers/education_progress_provider.dart';

/// Settings Screen - Sesi 9 (Pengaturan Aplikasi)
///
/// Mengatur volume audio piano, mengaktifkan Sense Mode (aksesibilitas),
/// serta menyediakan opsi untuk mereset seluruh histori latihan.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  double _volume = 1.0;
  bool _senseMode = false;
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
      _senseMode = prefs.getBool('sense_mode') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _updateVolume(double value) async {
    setState(() => _volume = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('piano_volume', value);
    // Ubah volume output SoLoud secara real-time
    SoLoud.instance.setGlobalVolume(value * 1.8); // Skala boost 1.8x
  }

  Future<void> _updateSenseMode(bool value) async {
    setState(() => _senseMode = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sense_mode', value);
  }

  Future<void> _resetProgress() async {
    final db = ref.read(appDatabaseProvider);
    final repo = ref.read(progressionRepositoryProvider);

    setState(() => _isLoading = true);

    try {
      // Hapus seluruh histori & pencapaian dari SQLite
      await db.transaction(() async {
        await db.delete(db.attempts).go();
        await db.delete(db.sessions).go();
        await db.delete(db.personalBests).go();
        await db.delete(db.achievements).go();
      });

      // Seeding ulang default achievements agar data kembali bersih tapi siap pakai
      await repo.seedDefaultAchievementsIfEmpty();

      // Reset status kelulusan submode Introduce
      await ref.read(educationProgressProvider.notifier).resetAll();

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
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTint.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
            ),

            // ── Setting Items List ──
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      children: [
                        // ── Audio Section ──
                        _buildSectionHeader('AUDIO'),
                        _buildCard([
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Piano Volume',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                                    Text(
                                      '${(_volume * 100).toInt()}%',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryDark.withValues(alpha: 0.6),
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
                        const SizedBox(height: 24),

                        // ── Accessibility Section ──
                        _buildSectionHeader('ACCESSIBILITY'),
                        _buildCard([
                          SwitchListTile(
                            value: _senseMode,
                            onChanged: _updateSenseMode,
                            title: const Text(
                              'Sense Mode',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            subtitle: const Text(
                              'Mengaktifkan panduan suara (TTS) & getaran taktil untuk tunanetra.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            activeTrackColor: AppColors.accent,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          ),
                        ]),
                        const SizedBox(height: 24),

                        // ── Maintenance Section ──
                        _buildSectionHeader('DANGER ZONE'),
                        _buildCard([
                          ListTile(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Reset Histori Latihan?'),
                                  content: const Text(
                                      'Seluruh histori latihan, statistik akurasi nada, XP, level, dan badge pencapaian Anda akan dihapus secara permanen.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _resetProgress();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Reset Data'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            title: const Text(
                              'Reset Progress Latihan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.red,
                              ),
                            ),
                            subtitle: const Text(
                              'Menghapus seluruh histori permainan, level, dan streak.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryDark.withValues(alpha: 0.5),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
