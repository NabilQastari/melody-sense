import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/virtual_piano.dart';

/// Free Play — mode main bebas tanpa tantangan, timer, hearts, atau
/// skor. User bisa tekan tuts sesuka hati untuk eksplorasi nada.
///
/// Fitur:
/// - Piano virtual interaktif (9 nada, B3–C5)
/// - Highlight tuts yang baru ditekan (auto-clear 280ms)
/// - Nama nada terakhir ditampilkan besar di tengah
/// - Tidak ada sesi/attempt yang dicatat ke database
class FreePlayScreen extends ConsumerStatefulWidget {
  const FreePlayScreen({super.key});

  @override
  ConsumerState<FreePlayScreen> createState() => _FreePlayScreenState();
}

class _FreePlayScreenState extends ConsumerState<FreePlayScreen> {
  String? _activeNote;
  String? _lastPlayedNote;
  Timer? _highlightTimer;

  void _onNotePressed(String note) {
    final audio = ref.read(audioServiceProvider);
    audio.playNote(note);

    _highlightTimer?.cancel();

    setState(() {
      _activeNote = note;
      _lastPlayedNote = note;
    });

    _highlightTimer = Timer(const Duration(milliseconds: 280), () {
      if (mounted) setState(() => _activeNote = null);
    });
  }

  @override
  void dispose() {
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
                        color: AppColors.surfaceTint.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.primaryDark),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Main Bebas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.piano_rounded,
                      color: AppColors.primaryDark.withValues(alpha: 0.4)),
                ],
              ),
            ),

            // ── Content area ──
            Expanded(
              child: audioReady.when(
                loading: () => const Center(
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
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tekan tuts untuk bermain',
                              style: TextStyle(
                                fontSize: isLandscape ? 11 : 13,
                                color: AppColors.primaryDark
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            SizedBox(height: isLandscape ? 6 : 16),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _lastPlayedNote ?? '♪',
                                key: ValueKey(_lastPlayedNote),
                                style: TextStyle(
                                  fontSize: _lastPlayedNote != null
                                      ? (isLandscape ? 40 : 64)
                                      : (isLandscape ? 30 : 48),
                                  fontWeight: FontWeight.w900,
                                  color: _lastPlayedNote != null
                                      ? AppColors.primaryDark
                                      : AppColors.primaryDark
                                          .withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                            if (_lastPlayedNote != null) ...[
                              SizedBox(height: isLandscape ? 2 : 8),
                              Text(
                                _getNoteDescription(_lastPlayedNote!),
                                style: TextStyle(
                                  fontSize: isLandscape ? 12 : 14,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // ── Piano ──
                    Padding(
                      padding: EdgeInsets.fromLTRB(12, 0, 12, isLandscape ? 8 : 16),
                      child: VirtualPiano(
                        activeNote: _activeNote,
                        onNotePressed: _onNotePressed,
                        height: isLandscape ? 110 : 180,
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
    const descriptions = {
      'B3': 'Si (oktaf 3)',
      'C4': 'Do (Middle C)',
      'D4': 'Re',
      'E4': 'Mi',
      'F4': 'Fa',
      'G4': 'Sol',
      'A4': 'La (440 Hz)',
      'B4': 'Si',
      'C5': 'Do (oktaf 5)',
    };
    return descriptions[note] ?? note;
  }
}
