import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/network/websocket_service.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/settings_screen.dart';
import 'package:melody_sense/features/interval_training/presentation/screens/interval_training_submode_picker_screen.dart';
import 'package:melody_sense/features/melody_echo/presentation/screens/melody_echo_submode_picker_screen.dart';
import 'package:melody_sense/features/note_recognition/presentation/screens/note_recognition_submode_picker_screen.dart';
import 'package:melody_sense/features/rhythm_match/presentation/screens/rhythm_match_submode_screen.dart';
import 'package:melody_sense/features/stats/presentation/providers/stats_providers.dart';

/// Dashboard Screen - Sesi 9 (Halaman Dashboard)
///
/// Menampilkan ringkasan status belajar pemain, kontrol koneksi piano fisik (Smart Piano),
/// akses cepat ke 4 mode tantangan utama, serta personal best terbaik pemain.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelInfoAsync = ref.watch(levelInfoProvider);

    return Column(
      children: [
        // ── Shared App Bar Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceTint,
                child: Icon(Icons.person, size: 18, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 10),
              const Text(
                'Melody Sense',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
                child: Icon(Icons.settings_outlined, color: AppColors.primaryDark.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),

        // ── Main Content ──
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Welcome & Level Title ──
                const Text(
                  'Hello, Maestro!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                levelInfoAsync.when(
                  loading: () => const SizedBox(height: 24),
                  error: (_, __) => const SizedBox(height: 24),
                  data: (levelInfo) => Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.workspace_premium_rounded, size: 14, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Level ${levelInfo.level}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${levelInfo.totalXp} XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Smart Piano Connection Card ──
                _buildSmartPianoCard(context, ref),
                const SizedBox(height: 16),

                // ── Last Played Tag ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTint.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_rounded, size: 14, color: AppColors.primaryDark.withValues(alpha: 0.7)),
                      const SizedBox(width: 6),
                      Text(
                        'Last played: Explorer Mode',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── 2x2 Grid Challenges ──
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: [
                    _ChallengeGridCard(
                      title: 'Note Recognition',
                      subtitle: 'Identify keys visually',
                      icon: Icons.music_note_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NoteRecognitionSubmodePickerScreen()),
                      ),
                    ),
                    _ChallengeGridCard(
                      title: 'Interval Training',
                      subtitle: 'Distance between notes',
                      icon: Icons.graphic_eq_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const IntervalTrainingSubmodePickerScreen()),
                      ),
                    ),
                    _ChallengeGridCard(
                      title: 'Melody Echo',
                      subtitle: 'Repeat what you hear',
                      icon: Icons.record_voice_over_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MelodyEchoSubmodePickerScreen()),
                      ),
                    ),
                    _ChallengeGridCard(
                      title: 'Rhythm Match',
                      subtitle: 'Master the timing',
                      icon: Icons.timer_rounded,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RhythmMatchSubmodeScreen()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Personal Best Banner ──
                _buildPersonalBestBanner(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartPianoCard(BuildContext context, WidgetRef ref) {
    final connectionStateAsync = ref.watch(webSocketConnectionStateProvider);
    final wsService = ref.watch(webSocketServiceProvider);

    final connectionState = connectionStateAsync.maybeWhen(
      data: (state) => state,
      orElse: () => wsService.connectionState,
    );

    String statusText;
    Color statusColor;
    bool isConnected = connectionState == WebSocketConnectionState.connected;

    switch (connectionState) {
      case WebSocketConnectionState.connected:
        statusText = 'Connected (${wsService.currentIp})';
        statusColor = Colors.green;
        break;
      case WebSocketConnectionState.connecting:
        statusText = 'Connecting...';
        statusColor = Colors.orange;
        break;
      case WebSocketConnectionState.error:
        statusText = 'Connection Error';
        statusColor = Colors.red;
        break;
      case WebSocketConnectionState.disconnected:
        statusText = 'Not Connected';
        statusColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceTint.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.piano_rounded, color: AppColors.primaryDark, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'SMART PIANO',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (isConnected) {
                wsService.disconnect();
              } else {
                _showConnectDialog(context, wsService);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isConnected ? Colors.red.shade400 : AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              isConnected ? 'Disconnect' : 'Connect',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectDialog(BuildContext context, WebSocketService wsService) {
    final ipController = TextEditingController(text: wsService.currentIp ?? '192.168.4.1');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Smart Piano WebSocket Connect'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan IP address ESP32 Smart Piano (Mode Access Point Wi-Fi default: 192.168.4.1)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                labelText: 'ESP32 IP Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.wifi_rounded),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final ip = ipController.text.trim();
              if (ip.isNotEmpty) {
                wsService.connect(ip);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBestBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.primaryDark.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERSONAL BEST',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Melody Echo',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '98%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Precision',
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.98,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeGridCard extends StatelessWidget {
  const _ChallengeGridCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceTint.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 18),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
