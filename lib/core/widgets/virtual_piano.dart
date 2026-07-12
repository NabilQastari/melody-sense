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

/// Virtual piano reusable — dipakai di Explorer Mode (semua mode latihan).
///
/// Menangani tampilan saja (presentation). Pemanggil bertanggung jawab
/// memutar audio & mencatat attempt lewat callback [onNotePressed],
/// sesuai prinsip Clean Architecture (widget ini tidak tahu soal
/// domain/data layer).
class VirtualPiano extends StatelessWidget {
  const VirtualPiano({
    super.key,
    this.notes = kDefaultPianoNotes,
    this.activeNote,
    this.onNotePressed,
    this.showLabels = true,
    this.height,
  });

  /// Daftar nada yang ditampilkan, kiri ke kanan.
  final List<String> notes;

  /// Nada yang sedang di-highlight (misal: sedang dimainkan sistem,
  /// atau baru saja ditekan user). Null = tidak ada yang aktif.
  final String? activeNote;

  /// Dipanggil saat user menekan salah satu tuts. Null = piano nonaktif
  /// (misal saat sequence contoh sedang diputar).
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
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final note in notes) ...[
          Expanded(
            child: _PianoKey(
              note: note,
              isActive: note == activeNote,
              showLabel: showLabels,
              interactive: _isInteractive,
              onTap: _isInteractive ? () => onNotePressed!(note) : null,
            ),
          ),
          if (note != notes.last) const SizedBox(width: 6),
        ],
      ],
    );

    if (height == null) return row;
    return SizedBox(height: height, child: row);
  }
}

class _PianoKey extends StatelessWidget {
  const _PianoKey({
    required this.note,
    required this.isActive,
    required this.showLabel,
    required this.interactive,
    this.onTap,
  });

  final String note;
  final bool isActive;
  final bool showLabel;
  final bool interactive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : AppColors.surfaceWhite,
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
                    color: isActive
                        ? AppColors.surfaceWhite
                        : AppColors.primaryDarkFaded,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}