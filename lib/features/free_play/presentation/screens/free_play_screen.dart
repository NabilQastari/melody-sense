import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melody_sense/core/domain/entities/operating_mode.dart';
import 'package:melody_sense/core/providers/audio_providers.dart';
import 'package:melody_sense/core/providers/operating_mode_providers.dart';
import 'package:melody_sense/core/providers/tts_providers.dart';
import 'package:melody_sense/core/providers/websocket_providers.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/virtual_piano.dart';

/// Free Play — mode main bebas tanpa tantangan, timer, hearts, atau
/// skor. User bisa tekan tuts sesuka hati untuk eksplorasi nada.
///
/// Fitur:
/// - Piano virtual interaktif (14 nada, B3–C5 kromatik)
/// - Highlight tuts yang baru ditekan (auto-clear 280ms)
/// - Nama nada terakhir ditampilkan besar di tengah
/// - Terhubung ke tombol fisik Smart Piano ESP32 via WebSocket
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
  StreamSubscription<String>? _noteSub;

  @override
  void initState() {
    super.initState();
    final mode = ref.read(operatingModeProvider);
    if (mode != AppOperatingMode.explorer) {
      final wsService = ref.read(webSocketServiceProvider);
      _noteSub = wsService.noteStream.listen((note) {
        if (mode == AppOperatingMode.sense) {
          ref.read(ttsServiceProvider).speak('Nada $note');
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

    _highlightTimer = Timer(const Duration(milliseconds: 280), () {
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
                                style: TextStyle(
                                  fontSize: _lastPlayedNote != null ? 36 : 26,
                                  fontWeight: FontWeight.w900,
                                  color: _lastPlayedNote != null
                                      ? AppColors.primaryDark
                                      : AppColors.primaryDark
                                          .withValues(alpha: 0.15),
                                ),
                              ),
                            ),
                            if (_lastPlayedNote != null)
                              Text(
                                _getNoteDescription(_lastPlayedNote!),
                                style: const TextStyle(
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Tekan tuts untuk bermain',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primaryDark
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 16),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  _lastPlayedNote ?? '♪',
                                  key: ValueKey(_lastPlayedNote),
                                  style: TextStyle(
                                    fontSize: _lastPlayedNote != null ? 64 : 48,
                                    fontWeight: FontWeight.w900,
                                    color: _lastPlayedNote != null
                                        ? AppColors.primaryDark
                                        : AppColors.primaryDark
                                            .withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                              if (_lastPlayedNote != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  _getNoteDescription(_lastPlayedNote!),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                    // ── Piano (Adaptive Height) ──
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 0, 12, isLandscape ? 6 : 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final pianoHeight = isLandscape
                                ? constraints.maxHeight.clamp(80.0, 200.0)
                                : constraints.maxHeight.clamp(80.0, 180.0);
                            return Align(
                              alignment: Alignment.bottomCenter,
                              child: VirtualPiano(
                                activeNote: _activeNote,
                                onNotePressed: _onNotePressed,
                                height: pianoHeight,
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
    const descriptions = {
      'B3': 'Si (oktaf 3)',
      'C4': 'Do (Middle C)',
      'C#4': 'Do# / Reb',
      'D4': 'Re',
      'D#4': 'Re# / Mib',
      'E4': 'Mi',
      'F4': 'Fa',
      'F#4': 'Fa# / Solb',
      'G4': 'Sol',
      'G#4': 'Sol# / Lab',
      'A4': 'La (440 Hz)',
      'A#4': 'La# / Sib',
      'B4': 'Si',
      'C5': 'Do (oktaf 5)',
    };
    return descriptions[note] ?? note;
  }
}
