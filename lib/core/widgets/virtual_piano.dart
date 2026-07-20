import 'package:flutter/material.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

/// 9 nada dasar sesuai hardware Smart Piano (prototipe Arduino Mega).
/// Urutan ini adalah urutan tampil default dari kiri ke kanan.
const List<String> kDefaultPianoNotes = [
  'B3',
  'C4',
  'D4',
  'E4',
  'F4',
  'G4',
  'A4',
  'B4',
  'C5',
];

/// Jarak antar tuts (harus sinkron dengan spacer di _buildKeys).
const double _kKeyGap = 6.0;

/// Virtual piano reusable — dipakai di Explorer Mode (semua mode latihan).
///
/// Menangani tampilan saja (presentation). Pemanggil bertanggung jawab
/// memutar audio & mencatat attempt lewat callback [onNotePressed],
/// sesuai prinsip Clean Architecture (widget ini tidak tahu soal
/// domain/data layer).
///
/// Mendukung GLISSANDO: satu sentuhan yang digeser (swipe) lintas
/// beberapa tuts akan memicu [onNotePressed] untuk tiap tuts yang
/// dilewati, bukan cuma tuts yang pertama disentuh. Deteksi posisi
/// jari dihitung manual dari koordinat X terhadap lebar tiap tuts
/// (bukan pakai gesture detector per-tuts individual), supaya gesture
/// tunggal bisa "membaca" perpindahan lintas widget.
class VirtualPiano extends StatefulWidget {
  const VirtualPiano({
    super.key,
    this.notes = kDefaultPianoNotes,
    this.activeNote,
    this.correctNote,
    this.wrongNote,
    this.onNotePressed,
    this.showLabels = true,
    this.height,
  });

  /// Daftar nada yang ditampilkan, kiri ke kanan.
  final List<String> notes;

  /// Nada yang sedang di-highlight (misal: sedang dimainkan sistem,
  /// atau baru saja ditekan user). Null = tidak ada yang aktif.
  final String? activeNote;

  /// Nada yang benar untuk ronde ini, akan di-highlight hijau.
  final String? correctNote;

  /// Nada yang salah yang ditekan user, akan di-highlight merah.
  final String? wrongNote;

  /// Dipanggil saat user menyentuh/menggeser jari ke atas salah satu
  /// tuts. Bisa terpanggil beberapa kali dalam satu sentuhan kalau
  /// jari digeser lintas tuts (glissando). Null = piano nonaktif
  /// (misal saat menampilkan status hardware read-only).
  final ValueChanged<String>? onNotePressed;

  /// Tampilkan label nama nada di bawah tiap tuts.
  final bool showLabels;

  /// Tinggi total area piano. Kalau null (default), piano akan mengisi
  /// ruang vertikal yang tersedia dari parent — WAJIB dibungkus
  /// [Expanded] atau [Flexible] oleh pemanggil dalam kasus ini, supaya
  /// tidak overflow di layar pendek (mis. landscape).
  final double? height;

  bool get _isInteractive => onNotePressed != null;

  @override
  State<VirtualPiano> createState() => _VirtualPianoState();
}

class _VirtualPianoState extends State<VirtualPiano> {
  /// Index tuts terakhir yang sudah dipicu dalam gesture yang sedang
  /// berjalan. Dipakai supaya jari yang diam di satu tuts tidak
  /// memicu onNotePressed berulang-ulang tiap frame — hanya berpindah
  /// tuts yang memicu panggilan baru.
  int? _lastTriggeredIndex;

  void _handleTouch(Offset localPosition, double totalWidth) {
    if (!widget._isInteractive) return;

    final count = widget.notes.length;
    if (count == 0 || totalWidth <= 0) return;

    final keyWidth = (totalWidth - _kKeyGap * (count - 1)) / count;
    if (keyWidth <= 0) return;

    final stride = keyWidth + _kKeyGap;
    final dx = localPosition.dx.clamp(0.0, totalWidth);
    final index = (dx / stride).floor().clamp(0, count - 1);

    if (index != _lastTriggeredIndex) {
      _lastTriggeredIndex = index;
      widget.onNotePressed!(widget.notes[index]);
    }
  }

  void _resetGesture() {
    _lastTriggeredIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final keys = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final note in widget.notes) ...[
              Expanded(
                child: _PianoKey(
                  note: note,
                  isActive: note == widget.activeNote,
                  isCorrect: note == widget.correctNote,
                  isWrong: note == widget.wrongNote,
                  showLabel: widget.showLabels,
                ),
              ),
              if (note != widget.notes.last) const SizedBox(width: _kKeyGap),
            ],
          ],
        );

        if (!widget._isInteractive) return keys;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          // onPanDown fires langsung saat pertama disentuh (bukan
          // menunggu gerakan/pelepasan) — jadi tuts pertama tetap
          // responsif instan seperti tap biasa.
          onPanDown: (details) =>
              _handleTouch(details.localPosition, constraints.maxWidth),
          // onPanUpdate menangani jari yang bergeser lintas tuts —
          // inilah yang mewujudkan glissando.
          onPanUpdate: (details) =>
              _handleTouch(details.localPosition, constraints.maxWidth),
          onPanEnd: (_) => _resetGesture(),
          onPanCancel: _resetGesture,
          child: keys,
        );
      },
    );

    if (widget.height == null) return content;
    return SizedBox(height: widget.height, child: content);
  }
}

class _PianoKey extends StatelessWidget {
  const _PianoKey({
    required this.note,
    required this.isActive,
    required this.showLabel,
    this.isCorrect = false,
    this.isWrong = false,
  });

  final String note;
  final bool isActive;
  final bool showLabel;
  final bool isCorrect;
  final bool isWrong;

  @override
  Widget build(BuildContext context) {
    Color keyColor = AppColors.surfaceWhite;
    Color textColor = AppColors.primaryDarkFaded;

    if (isCorrect) {
      keyColor = Colors.green;
      textColor = Colors.white;
    } else if (isWrong) {
      keyColor = Colors.red;
      textColor = Colors.white;
    } else if (isActive) {
      keyColor = AppColors.accent;
      textColor = AppColors.surfaceWhite;
    }

    return AnimatedScale(
      scale: isActive ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: keyColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 12),
        child: showLabel
            ? Text(
                note,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              )
            : null,
      ),
    );
  }
}