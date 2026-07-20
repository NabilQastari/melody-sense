import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:melody_sense/core/domain/entities/practice_entities.dart' show RoundFeedback;
import 'package:melody_sense/core/theme/app_colors.dart';
import 'package:melody_sense/core/widgets/virtual_piano.dart';

/// Shell UI untuk semua gameplay Explorer Mode (virtual piano interaktif).
///
/// SATU layar ini merender dua layout berbeda tergantung [Orientation]
/// perangkat — bukan dua layar terpisah. Portrait mengikuti pola desain
/// 05a, landscape mengikuti pola desain 05b. Datanya (target, progress,
/// xp, dst.) tetap sama; yang berubah cuma susunan elemennya.
///
/// Dipakai oleh fitur-fitur spesifik (note_recognition, interval_training,
/// dst.) lewat wrapper screen masing-masing yang menyuplai konten sesuai
/// jenis latihan — shell ini sendiri tidak tahu soal domain logic.
class ExplorerGameplayScreen extends StatefulWidget {
  const ExplorerGameplayScreen({
    super.key,
    required this.targetLabel,
    required this.targetValue,
    this.xp = 0,
    this.livesTotal,
    this.livesRemaining,
    this.progress = 0.0,
    this.sequenceNotes = const [],
    this.correctNote,
    this.wrongNote,
    this.isMysteryRound = false,
    this.feedback = RoundFeedback.none,
    this.roundIndex = 0,
    this.totalRounds = 0,
    this.isPlaying = false,
    this.onNotePressed,
    this.onAutoPlay,
    this.onHint,
    this.onClose,
  });

  /// Label kecil di atas target, mis. "Identify the sound" / "Target".
  final String targetLabel;

  /// Nilai target yang ditampilkan besar/sebagai badge, mis. "C4" atau
  /// "Major 3rd".
  final String targetValue;

  final int xp;

  /// Null = mode ini tidak pakai sistem heart/lives (mis. Interval
  /// Training landscape tidak menampilkannya di desain).
  final int? livesTotal;
  final int? livesRemaining;

  /// 0.0 - 1.0
  final double progress;

  /// Nada-nada yang sudah dimainkan sebagai bagian sequence saat ini.
  /// Kosong = tidak tampilkan sequence row (mis. Note Recognition).
  final List<String> sequenceNotes;

  final String? correctNote;
  final String? wrongNote;
  final bool isMysteryRound;
  final RoundFeedback feedback;
  final int roundIndex;
  final int totalRounds;
  final bool isPlaying;

  final ValueChanged<String>? onNotePressed;
  final VoidCallback? onAutoPlay;
  final VoidCallback? onHint;
  final VoidCallback? onClose;

  @override
  State<ExplorerGameplayScreen> createState() =>
      _ExplorerGameplayScreenState();
}

class _ExplorerGameplayScreenState extends State<ExplorerGameplayScreen> {
  String? _activeNote;
  Timer? _clearHighlightTimer;

  /// Durasi highlight tuts sebelum otomatis hilang. Meniru tuts piano
  /// fisik yang kembali ke posisi normal setelah bunyi/sentuhan
  /// selesai — bukan menetap sampai tuts lain ditekan.
  static const _highlightDuration = Duration(milliseconds: 100);

  void _handleNotePressed(String note) {
    setState(() => _activeNote = note);
    widget.onNotePressed?.call(note);

    // Reset timer tiap kali ada tekanan baru, supaya kalau user
    // menekan cepat berturut-turut, highlight tidak berkedip putus-
    // nyambung sebelum waktunya.
    _clearHighlightTimer?.cancel();
    _clearHighlightTimer = Timer(_highlightDuration, () {
      if (mounted) setState(() => _activeNote = null);
    });
  }

  @override
  void dispose() {
    _clearHighlightTimer?.cancel();
    super.dispose();
  }

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
    final hasLives = widget.livesTotal != null && widget.livesRemaining != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _CloseButton(onTap: widget.onClose),
              const SizedBox(width: 12),
              _XpCounter(xp: widget.xp),
              if (hasLives) ...[
                const SizedBox(width: 12),
                _LivesRow(
                  total: widget.livesTotal!,
                  remaining: widget.livesRemaining!,
                ),
              ],
              const Spacer(),
              _AutoPlayPill(onTap: widget.onAutoPlay),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.totalRounds > 0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Round ${widget.roundIndex + 1} of ${widget.totalRounds}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ).animate(key: ValueKey(widget.roundIndex)).fadeIn().slideX(begin: -0.2, end: 0),
                if (widget.isMysteryRound)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Mystery Round!',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .shimmer(color: Colors.amber.shade200, duration: 1.seconds),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          _ProgressBar(progress: widget.progress),
          const SizedBox(height: 32),
          Text(
            widget.targetLabel,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.targetValue,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            flex: 3,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  _NotePromptCard(
                    onTap: widget.onAutoPlay,
                    isMystery: widget.isMysteryRound,
                    isPlaying: widget.isPlaying,
                  ),
                  if (widget.feedback != RoundFeedback.none)
                    Positioned(
                      bottom: -24,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.feedback == RoundFeedback.correct
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: widget.feedback == RoundFeedback.correct
                                ? Colors.green
                                : Colors.red,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          widget.feedback == RoundFeedback.correct ? 'Correct!' : 'Wrong!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: widget.feedback == RoundFeedback.correct
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      )
                      .animate(key: ValueKey('${widget.roundIndex}_${widget.feedback}'))
                      .scaleXY(
                        begin: widget.feedback == RoundFeedback.correct ? 0.6 : 1.0,
                        end: 1.0,
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      )
                      .shake(
                        hz: widget.feedback == RoundFeedback.wrong ? 6 : 0,
                        duration: 400.ms,
                      )
                      .then(delay: 800.ms)
                      .fadeOut(duration: 300.ms),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: _CappedPiano(
              maxHeight: 220,
              activeNote: _activeNote,
              correctNote: widget.correctNote,
              wrongNote: widget.wrongNote,
              onNotePressed: _handleNotePressed,
            ),
          ),
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
              _CloseButton(onTap: widget.onClose),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.targetLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.targetValue,
                            style: const TextStyle(
                              color: AppColors.surfaceWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _ProgressBar(progress: widget.progress, height: 6),
                  ],
                ),
              ),
              _XpCounter(xp: widget.xp),
            ],
          ),
          const SizedBox(height: 10),
          if (widget.totalRounds > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Round ${widget.roundIndex + 1} of ${widget.totalRounds}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ).animate(key: ValueKey(widget.roundIndex)).fadeIn().slideX(begin: -0.2, end: 0),
                if (widget.isMysteryRound) ...[
                  const SizedBox(width: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        'Mystery Round!',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.amber,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .shimmer(color: Colors.amber.shade200, duration: 1.seconds),
                    ],
                  ),
                ],
              ],
            ),
          const SizedBox(height: 10),
          if (widget.sequenceNotes.isNotEmpty)
            Column(
              children: [
                const Text(
                  'Listen to the sequence...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final note in widget.sequenceNotes) ...[
                      _NoteChip(note: note),
                      const SizedBox(width: 8),
                    ],
                    _HintButton(onTap: widget.onHint),
                    const Spacer(),
                    _AutoPlayCircle(onTap: widget.onAutoPlay),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (widget.feedback != RoundFeedback.none && widget.sequenceNotes.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.feedback == RoundFeedback.correct
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.feedback == RoundFeedback.correct
                        ? Colors.green
                        : Colors.red,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  widget.feedback == RoundFeedback.correct ? 'Correct!' : 'Wrong!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: widget.feedback == RoundFeedback.correct
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              )
              .animate(key: ValueKey('${widget.roundIndex}_${widget.feedback}'))
              .scaleXY(
                begin: widget.feedback == RoundFeedback.correct ? 0.6 : 1.0,
                end: 1.0,
                duration: 400.ms,
                curve: Curves.elasticOut,
              )
              .shake(
                hz: widget.feedback == RoundFeedback.wrong ? 6 : 0,
                duration: 400.ms,
              )
              .then(delay: 800.ms)
              .fadeOut(duration: 300.ms),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _CappedPiano(
              maxHeight: 260,
              activeNote: _activeNote,
              correctNote: widget.correctNote,
              wrongNote: widget.wrongNote,
              onNotePressed: _handleNotePressed,
            ),
          ),
        ],
      ),
    );
  }
}

/// Membatasi tinggi piano supaya tidak memanjang berlebihan saat ruang
/// vertikal yang tersedia jauh lebih besar dari kebutuhan desain asli.
class _CappedPiano extends StatelessWidget {
  const _CappedPiano({
    required this.maxHeight,
    required this.activeNote,
    this.correctNote,
    this.wrongNote,
    required this.onNotePressed,
  });

  final double maxHeight;
  final String? activeNote;
  final String? correctNote;
  final String? wrongNote;
  final ValueChanged<String> onNotePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.clamp(0.0, maxHeight);
        return Align(
          alignment: Alignment.bottomCenter,
          child: VirtualPiano(
            height: height,
            activeNote: activeNote,
            correctNote: correctNote,
            wrongNote: wrongNote,
            onNotePressed: onNotePressed,
          ),
        );
      },
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
      icon: const Icon(Icons.close, color: AppColors.primaryDark),
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
        const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
        const SizedBox(width: 4),
        Text(
          '$xp',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _LivesRow extends StatelessWidget {
  const _LivesRow({required this.total, required this.remaining});
  final int total;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final filled = i < remaining;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Icon(
            filled ? Icons.favorite : Icons.favorite_border,
            color: filled ? Colors.redAccent : Colors.grey.shade300,
            size: 16,
          ),
        );
      }),
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
        child: const Row(
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

class _AutoPlayCircle extends StatelessWidget {
  const _AutoPlayCircle({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.surfaceTint,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: AppColors.primaryDark,
          size: 22,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress, this.height = 8});
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
        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
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
    Widget card = Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isMystery
                ? Colors.amber.withValues(alpha: 0.3)
                : AppColors.primaryDark.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: isMystery
            ? Border.all(color: Colors.amber, width: 2)
            : null,
      ),
      child: Icon(
        isMystery ? Icons.stars_rounded : Icons.music_note_rounded,
        size: 48,
        color: isMystery ? Colors.amber : AppColors.accent,
      ),
    );

    if (isPlaying) {
      card = card
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .scaleXY(begin: 1.0, end: 1.06, duration: 400.ms, curve: Curves.easeInOut)
          .boxShadow(
            begin: BoxShadow(color: AppColors.accent.withValues(alpha: 0), blurRadius: 0),
            end: BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 2),
            duration: 400.ms,
          );
    } else if (isMystery) {
      card = card
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(color: Colors.amber.withValues(alpha: 0.4), duration: 1500.ms)
          .animate(onPlay: (controller) => controller.repeat(reverse: true))
          .boxShadow(
            begin: BoxShadow(color: Colors.amber.withValues(alpha: 0.1), blurRadius: 8),
            end: BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 1),
            duration: 1.seconds,
          );
    }

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}


class _NoteChip extends StatelessWidget {
  const _NoteChip({required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        shape: BoxShape.circle,
      ),
      child: Text(
        note,
        style: const TextStyle(
          color: AppColors.surfaceWhite,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceTint, width: 1.5),
        ),
        child: const Text(
          '?',
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}