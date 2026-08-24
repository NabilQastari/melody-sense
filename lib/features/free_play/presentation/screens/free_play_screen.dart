import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/note_notation_provider.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/pattern_painters.dart';
import 'package:melody_sense/core/widgets/sticker_badge.dart';
import 'package:melody_sense/core/widgets/torn_paper_card.dart';
import 'package:melody_sense/core/widgets/virtual_piano.dart';
import 'package:melody_sense/core/widgets/whisker_banner_header.dart';

/// Free Play — mode main bebas tanpa tantangan, timer, hearts, atau skor.
/// Diperbarui dengan Design System v3 (Whisker-Inspired) & Anti-Overflow Protection.
class FreePlayScreen extends ConsumerStatefulWidget {
  const FreePlayScreen({super.key});

  @override
  ConsumerState<FreePlayScreen> createState() => _FreePlayScreenState();
}

class _FreePlayScreenState extends ConsumerState<FreePlayScreen> {
  String? _activeNote;
  String? _lastPlayedNote;
  Timer? _highlightTimer;
  StreamSubscription<String>? _noteSub;

  @override
  void initState() {
    super.initState();
    final mode = ref.read(operatingModeProvider);
    if (mode != AppOperatingMode.explorer) {
      final wsService = ref.read(webSocketServiceProvider);
      _noteSub = wsService.noteStream.listen((note) {
        if (mode == AppOperatingMode.sense) {
          final notation = ref.read(noteNotationProvider);
          final spoken = ref.read(ttsServiceProvider).formatNoteForSpeech(note, notation);
          ref.read(ttsServiceProvider).speak('Nada $spoken');
        }
        _onNotePressed(note);
      });
    }
  }

  void _onNotePressed(String note) {
    final audio = ref.read(audioServiceProvider);
    audio.playNote(note);

    _highlightTimer?.cancel();
    setState(() {
      _activeNote = note;
      _lastPlayedNote = note;
    });

    _highlightTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() => _activeNote = null);
    });
  }

  @override
  void dispose() {
    _noteSub?.cancel();
    _highlightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final audioReady = ref.watch(audioReadyProvider);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──
            Padding(
              padding: EdgeInsets.fromLTRB(20, isLandscape ? 6 : 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                    title: 'FREE PLAY PIANO',
                    fontSize: 15,
                    rotateAngle: -0.03,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  const Spacer(),
                  StickerBadge(
                    rotateAngle: 0.04,
                    backgroundColor: AppColors.accent,
                    borderColor: AppColors.primaryDark,
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.piano_rounded, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),

            // ── Content area ──
            Expanded(
              child: audioReady.when(
                loading: () => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 3,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading audio...',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Audio error: $e',
                      style: const TextStyle(color: Colors.red)),
                ),
                data: (_) => Column(
                  children: [
                    // ── Note display ──
                    if (isLandscape)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _lastPlayedNote ?? '♪',
                                key: ValueKey(_lastPlayedNote),
                                style: GoogleFonts.fredoka(
                                  fontSize: _lastPlayedNote != null ? 36 : 26,
                                  fontWeight: FontWeight.w700,
                                  color: _lastPlayedNote != null
                                      ? AppColors.primaryDark
                                      : AppColors.primaryDark.withValues(alpha: 0.25),
                                ),
                              ),
                            ),
                            if (_lastPlayedNote != null)
                              Text(
                                _getNoteDescription(_lastPlayedNote!),
                                style: GoogleFonts.fredoka(
                                  fontSize: 12,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: TornPaperCard(
                              backgroundColor: AppColors.surfaceWhite,
                              shadowColor: AppColors.surfaceTint,
                              borderWidth: 2.8,
                              tornPosition: TornEdgePosition.both,
                              padding: const EdgeInsets.all(14),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: HalftonePatternPainter(
                                        color: AppColors.surfaceTint,
                                        opacity: 0.25,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'TEKAN TUTS UNTUK BERMAIN',
                                            style: GoogleFonts.fredoka(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryDark.withValues(alpha: 0.6),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          AnimatedSwitcher(
                                            duration: const Duration(milliseconds: 200),
                                            child: StickerBadge(
                                              key: ValueKey(_lastPlayedNote),
                                              rotateAngle: -0.04,
                                              backgroundColor: _lastPlayedNote != null
                                                  ? AppColors.accent
                                                  : AppColors.surfaceTint,
                                              borderColor: AppColors.primaryDark,
                                              borderWidth: 2.5,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 8),
                                              child: Text(
                                                _lastPlayedNote ?? '♪',
                                                style: GoogleFonts.fredoka(
                                                  fontSize: _lastPlayedNote != null ? 44 : 36,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          if (_lastPlayedNote != null)
                                            Text(
                                              _getNoteDescription(_lastPlayedNote!),
                                              style: GoogleFonts.fredoka(
                                                fontSize: 13,
                                                color: AppColors.primaryDark,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // ── Virtual Piano ──
                    Expanded(
                      flex: isLandscape ? 3 : 2,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, isLandscape ? 6 : 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final height = isLandscape
                                ? constraints.maxHeight.clamp(80.0, 200.0)
                                : constraints.maxHeight.clamp(100.0, 200.0);
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: VirtualPiano(
                                height: height,
                                activeNote: _activeNote,
                                onNotePressed: _onNotePressed,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getNoteDescription(String note) {
    if (note.contains('#')) {
      final base = note[0];
      final octave = note.substring(note.length - 1);
      return 'Nada $base Sharp Oktaf $octave';
    }
    final name = note.substring(0, note.length - 1);
    final octave = note.substring(note.length - 1);
    return 'Nada $name Oktaf $octave';
  }
}
