import 'package:flutter/material.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart' show RoundFeedback;
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/virtual_piano.dart';

/// Shell UI untuk semua gameplay Maestro Mode (piano fisik via WebSocket).
///
/// Sama seperti [ExplorerGameplayScreen], SATU layar ini merender dua
/// layout tergantung [Orientation] — portrait mengikuti pola 05c,
/// landscape mengikuti pola 05d. Piano di sini selalu non-interaktif:
/// nada didorong dari hardware, bukan disentuh lewat layar.
class MaestroGameplayScreen extends StatelessWidget {
  const MaestroGameplayScreen({
    super.key,
    this.isConnected = true,
    required this.title,
    this.subtitle,
    this.targetLabel,
    this.targetValue,
    this.rootNote,
    this.correctNote,
    this.wrongNote,
    this.bridgeStartNote,
    this.bridgeEndNote,
    this.bridgeLabel,
    this.showPianoLabels = true,
    this.xp = 0,
    this.progress = 0.0,
    this.activeHardwareNote,
    this.comboCount,
    this.onAutoPlay,
    this.isPlaying = false,
    this.isMysteryRound = false,
    this.feedback = RoundFeedback.none,
    this.roundIndex = 0,
    this.totalRounds = 0,
    this.onClose,
  });

  final bool isConnected;

  /// Portrait: judul besar (mis. "Repeat the Melody").
  /// Landscape: nama challenge di bawah label "CURRENT CHALLENGE".
  final String title;

  /// Hanya dipakai di portrait, mis. instruksi latihan.
  final String? subtitle;

  /// Label target (mis: "Mulai dari C4 → Tebak Nada Kedua").
  final String? targetLabel;

  /// Nilai target (mis: "Major 2nd (+2 semitones)" atau "C4").
  final String? targetValue;

  /// Nada acuan (Root Note) yang diberi penanda khusus di tuts piano.
  final String? rootNote;

  /// Nada jawaban benar yang di-highlight hijau.
  final String? correctNote;

  /// Nada jawaban salah yang di-highlight merah.
  final String? wrongNote;

  /// Nada awal jembatan visual.
  final String? bridgeStartNote;

  /// Nada akhir jembatan visual.
  final String? bridgeEndNote;

  /// Label jembatan visual (mis: "2 semitones").
  final String? bridgeLabel;

  /// Tampilkan nama nada pada tuts piano.
  final bool showPianoLabels;

  final int xp;

  /// 0.0 - 1.0
  final double progress;

  /// Nada yang sedang ditekan di Smart Piano fisik (dari WebSocket).
  final String? activeHardwareNote;

  /// Null = tidak tampilkan combo badge (mis. Melody Echo tidak punya
  /// combo di desain).
  final int? comboCount;

  final VoidCallback? onAutoPlay;
  final bool isPlaying;
  final bool isMysteryRound;
  final RoundFeedback feedback;
  final int roundIndex;
  final int totalRounds;

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortrait(context)
                : _buildLandscape(context);
          },
        ),
      ),
    );
  }

  Widget _buildPortrait(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _ConnectionBadge(isConnected: isConnected),
              const SizedBox(width: 8),
              _XpCounter(xp: xp),
              const Spacer(),
              if (onAutoPlay != null) _AutoPlayPill(onTap: onAutoPlay),
              const SizedBox(width: 8),
              _CloseButton(onTap: onClose),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ProgressBar(progress: progress)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          if (targetValue != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.paperWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryDark, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (targetLabel != null)
                    Text(
                      targetLabel!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.paperText.withValues(alpha: 0.75),
                      ),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    targetValue!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.paperText,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: onAutoPlay != null
                  ? _NotePromptCard(
                      onTap: onAutoPlay,
                      isMystery: isMysteryRound,
                      isPlaying: isPlaying,
                    )
                  : const _MascotWithSoundWave(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.piano_rounded, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(
                'VISUALIZER HARDWARE SMART PIANO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          VirtualPiano(
            height: 110,
            showLabels: showPianoLabels,
            activeNote: activeHardwareNote,
            rootNote: rootNote,
            correctNote: correctNote,
            wrongNote: wrongNote,
            bridgeStartNote: bridgeStartNote,
            bridgeEndNote: bridgeEndNote,
            bridgeLabel: bridgeLabel,
            onNotePressed: null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLandscape(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CloseButton(onTap: onClose),
              const SizedBox(width: 8),
              _ConnectionBadge(isConnected: isConnected),
              const Spacer(),
              if (onAutoPlay != null) ...[
                _AutoPlayPill(onTap: onAutoPlay),
                const SizedBox(width: 8),
              ],
              if (comboCount != null) _ComboBadge(count: comboCount!),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    if (targetValue != null)
                      Text(
                        '$targetLabel — $targetValue',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                  ],
                ),
              ),
              if (onAutoPlay != null) ...[
                _NotePromptCard(
                  onTap: onAutoPlay,
                  isMystery: isMysteryRound,
                  isPlaying: isPlaying,
                ),
                const SizedBox(width: 12),
              ],
              _XpCounter(xp: xp),
            ],
          ),
          const SizedBox(height: 8),
          _ProgressBar(progress: progress, height: 6),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight.clamp(0.0, 300.0);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: VirtualPiano(
                    height: height,
                    showLabels: showPianoLabels,
                    activeNote: activeHardwareNote,
                    rootNote: rootNote,
                    correctNote: correctNote,
                    wrongNote: wrongNote,
                    bridgeStartNote: bridgeStartNote,
                    bridgeEndNote: bridgeEndNote,
                    bridgeLabel: bridgeLabel,
                    onNotePressed: null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(Icons.close, color: AppColors.primaryDark),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}

class _XpCounter extends StatelessWidget {
  const _XpCounter({required this.xp});
  final int xp;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.monetization_on, color: Colors.amber, size: 15),
        const SizedBox(width: 3),
        Text(
          '$xp',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, this.height = 6});
  final double progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: AppColors.surfaceTint,
        valueColor: AlwaysStoppedAnimation(AppColors.accent),
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.isConnected});
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.accentFaded,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            size: 13,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 5),
          Text(
            isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComboBadge extends StatelessWidget {
  const _ComboBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, size: 13, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            '${count}x Combo',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.surfaceWhite,
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoPlayPill extends StatelessWidget {
  const _AutoPlayPill({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_fill,
                color: AppColors.surfaceWhite, size: 16),
            SizedBox(width: 6),
            Text(
              'Auto Play',
              style: TextStyle(
                color: AppColors.surfaceWhite,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotePromptCard extends StatelessWidget {
  const _NotePromptCard({
    this.onTap,
    this.isMystery = false,
    this.isPlaying = false,
  });
  final VoidCallback? onTap;
  final bool isMystery;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TornPaperCard(
        width: 130,
        height: 130,
        backgroundColor: AppColors.surfaceWhite,
        shadowColor: AppColors.surfaceTint,
        borderWidth: 2.8,
        tornPosition: TornEdgePosition.bottom,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StickerBadge(
              rotateAngle: -0.04,
              backgroundColor: isMystery ? Colors.amber.shade700 : AppColors.accent,
              borderColor: AppColors.primaryDark,
              borderWidth: 2.0,
              padding: const EdgeInsets.all(8),
              child: Icon(
                isPlaying ? Icons.volume_up_rounded : Icons.music_note_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPlaying ? 'PLAYING...' : 'TAP TO PLAY',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder maskot + sound wave. Ilustrasi maskot asli akan
/// menyusul dari desain (belum ada aset final).
class _MascotWithSoundWave extends StatelessWidget {
  const _MascotWithSoundWave();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.surfaceTint,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.face_rounded,
            size: 36,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(12, (i) {
            final heights = [8.0, 16.0, 24.0, 32.0, 20.0, 28.0];
            final h = heights[i % heights.length];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 3,
                height: h,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}