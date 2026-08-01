import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:melody_sense/core/network/websocket_service.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/app_logo_avatar.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/settings_screen.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';
import 'package:melody_sense/features/interval_training/presentation/screens/interval_training_submode_picker_screen.dart';
import 'package:melody_sense/features/melody_echo/presentation/screens/melody_echo_submode_picker_screen.dart';
import 'package:melody_sense/features/note_recognition/presentation/screens/note_recognition_submode_picker_screen.dart';
import 'package:melody_sense/features/rhythm_match/presentation/screens/rhythm_match_submode_screen.dart';
import 'package:melody_sense/features/stats/presentation/providers/stats_providers.dart';

/// Dashboard Screen - Refactored 100% berdasarkan referensi visual "The Whisker Watch" (Desain.md)
/// Memuat Banner Header miring ber-outline ink, Torn Paper Framing, Sticker Badges, & Halftone Accents.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final levelInfoAsync = ref.watch(levelInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Shared App Bar Header (Whisker Style) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                children: [
                  const AppLogoAvatar(),
                  const SizedBox(width: 10),

                  // Header Banner "MELODY SENSE"
                  const WhiskerBannerHeader(
                    title: 'MELODY SENSE',
                    fontSize: 15,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),

                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryDark, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDark.withValues(alpha: 0.2),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: AppColors.primaryDark,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Main Content Scroll View ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Hero Section (The Whisker Watch Ribbon + Torn Card) ──
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        TornPaperCard(
                          backgroundColor: AppColors.surfaceTint.withValues(alpha: 0.4),
                          shadowColor: AppColors.surfaceTint,
                          borderWidth: 2.8,
                          tornPosition: TornEdgePosition.bottom,
                          margin: const EdgeInsets.only(top: 14),
                          padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: StripePatternPainter(
                                    color: AppColors.primaryDark,
                                    opacity: 0.08,
                                    spacing: 14,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  levelInfoAsync.when(
                                    loading: () => const SizedBox(height: 28),
                                    error: (_, __) => const SizedBox(height: 28),
                                    data: (levelInfo) => Row(
                                      children: [
                                        StickerBadge(
                                          rotateAngle: -0.05,
                                          backgroundColor: AppColors.accent,
                                          borderColor: AppColors.primaryDark,
                                          borderWidth: 2.2,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.workspace_premium_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                'LEVEL ${levelInfo.level}',
                                                style: GoogleFonts.fredoka(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        StickerBadge(
                                          rotateAngle: 0.04,
                                          backgroundColor: AppColors.surfaceWhite,
                                          borderColor: AppColors.primaryDark,
                                          borderWidth: 2.2,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 6),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.bolt_rounded, size: 16, color: AppColors.accent),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${levelInfo.totalXp} XP',
                                                style: GoogleFonts.fredoka(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primaryDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Floating Whisker Banner Title
                        const Positioned(
                          top: 0,
                          left: 14,
                          child: WhiskerBannerHeader(
                            title: 'HELLO, MAESTRO!',
                            fontSize: 18,
                            rotateAngle: -0.05,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Smart Piano Card (Whisker Card Style) ──
                    _buildSmartPianoCard(context, ref),
                    const SizedBox(height: 18),

                    // ── Last Played Tag Sticker ──
                    Row(
                      children: [
                        StickerBadge(
                          rotateAngle: -0.03,
                          backgroundColor: AppColors.surfaceWhite,
                          borderColor: AppColors.primaryDark,
                          borderWidth: 2.2,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.history_rounded,
                                  size: 15, color: AppColors.primaryDark),
                              const SizedBox(width: 6),
                              Text(
                                'LAST PLAYED: EXPLORER MODE',
                                style: GoogleFonts.fredoka(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    const TornDivider(opacity: 0.4),
                    const SizedBox(height: 16),

                    // ── Section Title: PRACTICE MODES ──
                    Row(
                      children: [
                        const WhiskerBannerHeader(
                          title: 'PRACTICE MODES',
                          fontSize: 16,
                          rotateAngle: -0.04,
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── 2x2 Grid Challenges (Whisker Cards dengan Icon & Sticker Kaya) ──
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                      children: [
                        _ChallengeGridCard(
                          title: 'Note Recognition',
                          subtitle: 'Identify keys visually',
                          tag: 'VISUAL',
                          icon: Icons.music_note_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const NoteRecognitionSubmodePickerScreen(),
                            ),
                          ),
                        ),
                        _ChallengeGridCard(
                          title: 'Interval Training',
                          subtitle: 'Distance between notes',
                          tag: 'PITCH',
                          icon: Icons.graphic_eq_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const IntervalTrainingSubmodePickerScreen(),
                            ),
                          ),
                        ),
                        _ChallengeGridCard(
                          title: 'Rhythm Match',
                          subtitle: 'Master the timing',
                          tag: 'RHYTHM',
                          icon: Icons.timer_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RhythmMatchSubmodeScreen(),
                            ),
                          ),
                        ),
                        _ChallengeGridCard(
                          title: 'Melody Echo',
                          subtitle: 'Repeat what you hear',
                          tag: 'EAR',
                          icon: Icons.record_voice_over_rounded,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const MelodyEchoSubmodePickerScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── Personal Best Banner (Whisker Header + Halftone) ──
                    _buildPersonalBestBanner(ref),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        statusColor = Colors.green.shade600;
        break;
      case WebSocketConnectionState.connecting:
        statusText = 'Connecting...';
        statusColor = Colors.orange.shade700;
        break;
      case WebSocketConnectionState.error:
        statusText = 'Connection Error';
        statusColor = Colors.red.shade600;
        break;
      case WebSocketConnectionState.disconnected:
        statusText = 'Not Connected';
        statusColor = Colors.grey.shade600;
        break;
    }

    return TornPaperCard(
      backgroundColor: AppColors.surfaceWhite,
      shadowColor: AppColors.surfaceTint,
      borderWidth: 2.8,
      tornPosition: TornEdgePosition.bottom,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          StickerBadge(
            rotateAngle: -0.05,
            backgroundColor: AppColors.surfaceTint,
            borderColor: AppColors.primaryDark,
            borderWidth: 2.2,
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.piano_rounded,
                color: AppColors.primaryDark, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryDark, width: 1.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SMART PIANO',
                      style: GoogleFonts.fredoka(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark.withValues(alpha: 0.75),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (isConnected) {
                wsService.disconnect();
              } else {
                _showConnectDialog(context, wsService);
              }
            },
            child: StickerBadge(
              rotateAngle: 0.04,
              backgroundColor: isConnected ? Colors.red.shade400 : AppColors.accent,
              borderColor: AppColors.primaryDark,
              borderWidth: 2.4,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                isConnected ? 'DISCONNECT' : 'CONNECT',
                style: GoogleFonts.fredoka(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConnectDialog(BuildContext context, WebSocketService wsService) {
    final ipController =
        TextEditingController(text: wsService.currentIp ?? '192.168.4.1');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryDark, width: 2.8),
        ),
        backgroundColor: AppColors.surfaceWhite,
        title: Text(
          'Smart Piano Connect',
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan IP address ESP32 Smart Piano (Mode Access Point Wi-Fi default: 192.168.4.1)',
              style: TextStyle(fontSize: 12, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ipController,
              decoration: InputDecoration(
                labelText: 'ESP32 IP Address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.primaryDark, width: 2.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      BorderSide(color: AppColors.accent, width: 2.8),
                ),
                prefixIcon: Icon(Icons.wifi_rounded,
                    color: AppColors.primaryDark),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.fredoka(
                    fontWeight: FontWeight.w600, color: AppColors.primaryDark)),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primaryDark, width: 2.2),
              ),
            ),
            child: Text('CONNECT',
                style: GoogleFonts.fredoka(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalBestBanner(WidgetRef ref) {
    final bestAsync = ref.watch(topPersonalBestProvider);

    final entry = bestAsync.valueOrNull;
    final bool hasBest = entry != null;
    final String modeTitle = hasBest ? entry.mode.displayName : 'Belum Ada Rekor';
    final int scorePercent = hasBest ? entry.bestScore : 0;

    final double progressValue = (scorePercent / 100.0).clamp(0.0, 1.0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        TornPaperCard(
          backgroundColor: AppColors.darkContainer,
          shadowColor: AppColors.surfaceTint,
          borderWidth: 2.8,
          tornPosition: TornEdgePosition.both,
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: HalftonePatternPainter(
                    color: AppColors.surfaceTint,
                    opacity: 0.25,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        modeTitle,
                        style: GoogleFonts.fredoka(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$scorePercent%',
                            style: GoogleFonts.fredoka(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'PRECISION',
                            style: GoogleFonts.fredoka(
                              fontSize: 10,
                              color: AppColors.surfaceTint,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTint.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation(AppColors.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Banner Header "PERSONAL BEST"
        const Positioned(
          top: 0,
          left: 14,
          child: WhiskerBannerHeader(
            title: 'PERSONAL BEST',
            fontSize: 14,
            rotateAngle: -0.04,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ),

        // Sticker Badge "🏆 RECORD"
        Positioned(
          top: 6,
          right: 14,
          child: StickerBadge(
            rotateAngle: 0.05,
            backgroundColor: AppColors.accent,
            borderColor: Colors.white,
            borderWidth: 2.0,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'RECORD',
                  style: GoogleFonts.fredoka(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChallengeGridCard extends StatelessWidget {
  const _ChallengeGridCard({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TornPaperCard(
        backgroundColor: AppColors.surfaceWhite,
        shadowColor: AppColors.surfaceTint,
        borderWidth: 2.6,
        tornPosition: TornEdgePosition.bottom,
        padding: const EdgeInsets.all(14),
        child: Stack(
          children: [
            // Halftone Accent di latar tengah kartu agar menarik & padat
            Positioned(
              right: -10,
              top: 10,
              width: 75,
              height: 75,
              child: CustomPaint(
                painter: HalftonePatternPainter(
                  color: AppColors.surfaceTint,
                  opacity: 0.3,
                  maxRadius: 2.8,
                  spacing: 9.0,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Centered Large Icon Badge + Category Tag Sticker
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StickerBadge(
                      rotateAngle: -0.05,
                      backgroundColor: AppColors.surfaceTint,
                      borderColor: AppColors.primaryDark,
                      borderWidth: 2.4,
                      padding: const EdgeInsets.all(10),
                      child: Icon(icon, color: AppColors.primaryDark, size: 28),
                    ),
                    StickerBadge(
                      rotateAngle: 0.05,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.25),
                      borderColor: AppColors.primaryDark,
                      borderWidth: 1.8,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      child: Text(
                        tag,
                        style: GoogleFonts.fredoka(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // Title
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),

                // Subtitle
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.primaryDark.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
