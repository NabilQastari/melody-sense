import 'package:flutter/material.dart';
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

  void _handleNotePressed(String note) {
    setState(() => _activeNote = note);
    widget.onNotePressed?.call(note);
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
              child: _NotePromptCard(onTap: widget.onAutoPlay),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            flex: 2,
            child: _CappedPiano(
              maxHeight: 220,
              activeNote: _activeNote,
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
          const SizedBox(height: 20),
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
          const SizedBox(height: 12),
          Expanded(
            child: _CappedPiano(
              maxHeight: 260,
              activeNote: _activeNote,
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
    required this.onNotePressed,
  });

  final double maxHeight;
  final String? activeNote;
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
  const _NotePromptCard({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.music_note_rounded,
          size: 48,
          color: AppColors.accent,
        ),
      ),
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