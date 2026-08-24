import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:melody_sense/core/theme/app_colors.dart';

/// 14 nada (B3 + 13 nada kromatik C4–C5) sesuai hardware Smart Piano ESP32.
/// Urutan ini adalah urutan tampil default dari kiri ke kanan.
const List<String> kDefaultPianoNotes = [
  'B3',
  'C4',
  'C#4',
  'D4',
  'D#4',
  'E4',
  'F4',
  'F#4',
  'G4',
  'G#4',
  'A4',
  'A#4',
  'B4',
  'C5',
];

/// 9 nada natural (tuts putih)
const List<String> _kWhiteNotes = [
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

/// Pemetaan tuts hitam (sharp) ke indeks tuts putih di sebelahnya (kiri)
const Map<String, int> _kBlackKeyAfterWhiteIndex = {
  'C#4': 1, // setelah C4 (indeks 1)
  'D#4': 2, // setelah D4 (indeks 2)
  'F#4': 4, // setelah F4 (indeks 4)
  'G#4': 5, // setelah G4 (indeks 5)
  'A#4': 6, // setelah A4 (indeks 6)
};

/// Jarak antar tuts putih.
const double _kKeyGap = 4.0;

/// Virtual piano reusable (13 tuts kromatik) — dipakai di Explorer Mode & semua mode latihan.
///
/// Menangani tampilan tuts putih (natural) & tuts hitam (sharp/accidental)
/// dengan perbandingan proporsional piano fisik sungguhan.
///
/// Mendukung GLISSANDO lintas nada putih & hitam secara real-time.
class VirtualPiano extends StatefulWidget {
  const VirtualPiano({
    super.key,
    this.notes = kDefaultPianoNotes,
    this.activeNote,
    this.correctNote,
    this.correctNotes,
    this.wrongNote,
    this.rootNote,
    this.bridgeStartNote,
    this.bridgeEndNote,
    this.bridgeLabel,
    this.onNotePressed,
    this.showLabels = true,
    this.height,
  });

  /// Daftar nada yang ditampilkan, kiri ke kanan.
  final List<String> notes;

  /// Nada yang sedang di-highlight (misal: sedang dimainkan sistem/user).
  final String? activeNote;

  /// Nada yang benar untuk ronde ini, akan di-highlight hijau.
  final String? correctNote;

  /// Daftar nada yang di-highlight hijau (misal: guided hint melodi).
  final Set<String>? correctNotes;

  /// Nada yang salah yang ditekan user, akan di-highlight merah.
  final String? wrongNote;

  /// Nada awal jembatan visual (mis. rootNote).
  final String? bridgeStartNote;

  /// Nada acuan awal (Root Note) yang diberi highlight khusus sebagai titik jangkar.
  final String? rootNote;

  /// Nada akhir jembatan visual (mis. lastPressedNote/targetNote).
  final String? bridgeEndNote;

  /// Label yang ditampilkan di atas jembatan (mis. "5 semitones").
  final String? bridgeLabel;

  /// Dipanggil saat user menyentuh/menggeser jari ke atas tuts.
  final ValueChanged<String>? onNotePressed;

  /// Tampilkan label nama nada di bawah tiap tuts.
  final bool showLabels;

  /// Tinggi total area piano.
  final double? height;

  bool get _isInteractive => onNotePressed != null;

  @override
  State<VirtualPiano> createState() => _VirtualPianoState();
}

class _VirtualPianoState extends State<VirtualPiano> {
  /// String nada terakhir yang dipicu dalam gesture aktif.
  String? _lastTriggeredNote;

  List<String> get _whiteNotesPresent =>
      _kWhiteNotes.where((n) => widget.notes.contains(n)).toList();

  List<String> get _blackNotesPresent =>
      _kBlackKeyAfterWhiteIndex.keys.where((n) => widget.notes.contains(n)).toList();

  void _handleTouch(Offset localPosition, Size size) {
    if (!widget._isInteractive || size.width <= 0 || size.height <= 0) return;

    final whiteNotes = _whiteNotesPresent;
    if (whiteNotes.isEmpty) return;

    final numWhite = whiteNotes.length;
    final whiteKeyWidth = (size.width - _kKeyGap * (numWhite - 1)) / numWhite;
    if (whiteKeyWidth <= 0) return;

    final whiteKeyStride = whiteKeyWidth + _kKeyGap;
    final blackKeyWidth = whiteKeyWidth * 0.60;
    final blackKeyHeight = size.height * 0.58;

    String? hitNote;

    // 1. Cek hit pada tuts hitam dulu jika sentuhan di area atas
    if (localPosition.dy <= blackKeyHeight) {
      for (final blackNote in _blackNotesPresent) {
        final afterIdx = _kBlackKeyAfterWhiteIndex[blackNote];
        if (afterIdx == null) continue;

        final actualWhiteIdx = whiteNotes.indexOf(_kWhiteNotes[afterIdx]);
        if (actualWhiteIdx == -1) continue;

        final seamX = (actualWhiteIdx + 1) * whiteKeyStride - _kKeyGap / 2;
        final leftX = seamX - blackKeyWidth / 2;
        final rightX = seamX + blackKeyWidth / 2;

        if (localPosition.dx >= leftX && localPosition.dx <= rightX) {
          hitNote = blackNote;
          break;
        }
      }
    }

    // 2. Jika tidak mengenai tuts hitam, cek tuts putih
    if (hitNote == null) {
      final dx = localPosition.dx.clamp(0.0, size.width - 0.1);
      final idx = (dx / whiteKeyStride).floor().clamp(0, numWhite - 1);
      hitNote = whiteNotes[idx];
    }

    if (hitNote != _lastTriggeredNote) {
      _lastTriggeredNote = hitNote;
      HapticFeedback.lightImpact();
      widget.onNotePressed!(hitNote);
    }
  }

  void _resetGesture() {
    _lastTriggeredNote = null;
  }

  @override
  Widget build(BuildContext context) {
    final whiteNotes = _whiteNotesPresent;
    final blackNotes = _blackNotesPresent;

    final content = LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final totalHeight = constraints.maxHeight;
        final numWhite = whiteNotes.length;

        if (totalWidth <= 0 || numWhite == 0) return const SizedBox.shrink();

        final whiteKeyWidth = (totalWidth - _kKeyGap * (numWhite - 1)) / numWhite;
        final whiteKeyStride = whiteKeyWidth + _kKeyGap;
        final blackKeyWidth = whiteKeyWidth * 0.60;
        final blackKeyHeight = totalHeight * 0.58;

        // Barisan tuts putih
        final whiteKeysRow = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final note in whiteNotes) ...[
              Expanded(
                child: _PianoKey(
                  note: note,
                  isBlack: false,
                  isActive: note == widget.activeNote,
                  isCorrect: note == widget.correctNote ||
                      (widget.correctNotes != null && widget.correctNotes!.contains(note)),
                  isWrong: note == widget.wrongNote,
                  isRoot: note == widget.rootNote,
                  showLabel: widget.showLabels,
                ),
              ),
              if (note != whiteNotes.last) const SizedBox(width: _kKeyGap),
            ],
          ],
        );

        // Positioned tuts hitam
        final blackKeyWidgets = <Widget>[];
        for (final blackNote in blackNotes) {
          final afterIdx = _kBlackKeyAfterWhiteIndex[blackNote];
          if (afterIdx == null) continue;

          final actualWhiteIdx = whiteNotes.indexOf(_kWhiteNotes[afterIdx]);
          if (actualWhiteIdx == -1) continue;

          final seamX = (actualWhiteIdx + 1) * whiteKeyStride - _kKeyGap / 2;
          final leftX = seamX - blackKeyWidth / 2;
          final isBlackKeyCorrect = blackNote == widget.correctNote ||
              (widget.correctNotes != null && widget.correctNotes!.contains(blackNote));

          blackKeyWidgets.add(
            Positioned(
              left: leftX,
              top: 0,
              width: blackKeyWidth,
              height: blackKeyHeight,
              child: IgnorePointer(
                child: _PianoKey(
                  note: blackNote,
                  isBlack: true,
                  isActive: blackNote == widget.activeNote,
                  isCorrect: isBlackKeyCorrect,
                  isWrong: blackNote == widget.wrongNote,
                  isRoot: blackNote == widget.rootNote,
                  showLabel: widget.showLabels,
                ),
              ),
            ),
          );
        }

        Widget pianoStack = Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: whiteKeysRow),
            ...blackKeyWidgets,
          ],
        );

        if (widget._isInteractive) {
          pianoStack = Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => _handleTouch(
              event.localPosition,
              Size(totalWidth, totalHeight),
            ),
            onPointerMove: (event) => _handleTouch(
              event.localPosition,
              Size(totalWidth, totalHeight),
            ),
            onPointerUp: (_) => _resetGesture(),
            onPointerCancel: (_) => _resetGesture(),
            child: pianoStack,
          );
        }

        // Overlay visual jembatan jarak (Bridge) jika ada
        if (widget.bridgeStartNote != null && widget.bridgeEndNote != null) {
          pianoStack = Stack(
            clipBehavior: Clip.none,
            children: [
              pianoStack,
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _PianoBridgePainter(
                      notes: widget.notes,
                      whiteNotes: whiteNotes,
                      startNote: widget.bridgeStartNote!,
                      endNote: widget.bridgeEndNote!,
                      label: widget.bridgeLabel ?? '',
                      whiteKeyWidth: whiteKeyWidth,
                      keyGap: _kKeyGap,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return pianoStack;
      },
    );

    if (widget.height == null) return content;
    return SizedBox(height: widget.height, child: content);
  }
}

class _PianoKey extends StatelessWidget {
  const _PianoKey({
    required this.note,
    required this.isBlack,
    required this.isActive,
    required this.showLabel,
    this.isCorrect = false,
    this.isWrong = false,
    this.isRoot = false,
  });

  static final RegExp _nonDigitRegex = RegExp(r'[^0-9]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');

  final String note;
  final bool isBlack;
  final bool isActive;
  final bool showLabel;
  final bool isCorrect;
  final bool isWrong;
  final bool isRoot;

  @override
  Widget build(BuildContext context) {
    final int octave = int.tryParse(note.replaceAll(_nonDigitRegex, '')) ?? 4;

    Color keyColor;
    Color textColor;
    BoxBorder? keyBorder;

    if (isBlack) {
      if (octave == 3) {
        keyColor = AppColors.isDark ? const Color(0xFF0D0D11) : const Color(0xFF141722);
        textColor = const Color(0xFFFFF8EE).withValues(alpha: 0.9);
      } else if (octave == 5) {
        keyColor = AppColors.isDark ? const Color(0xFF242236) : const Color(0xFF2C2A4A);
        textColor = const Color(0xFFFFF8EE);
      } else {
        keyColor = AppColors.pianoBlackKey;
        textColor = const Color(0xFFFFF8EE);
      }
    } else {
      if (octave == 3) {
        keyColor = AppColors.isDark ? const Color(0xFFE5E0D8) : const Color(0xFFE0E4F5);
        textColor = const Color(0xFF101014);
      } else if (octave == 5) {
        keyColor = AppColors.isDark ? const Color(0xFFFFFDF8) : const Color(0xFFEFF2FF);
        textColor = const Color(0xFF101014);
      } else {
        keyColor = AppColors.pianoWhiteKey;
        textColor = AppColors.isDark ? const Color(0xFF101014) : AppColors.primaryDarkFaded;
      }
    }

    if (isCorrect) {
      keyColor = Colors.green;
      textColor = Colors.white;
    } else if (isWrong) {
      keyColor = Colors.red;
      textColor = Colors.white;
    } else if (isActive) {
      keyColor = AppColors.accent;
      textColor = AppColors.surfaceWhite;
    } else if (isRoot) {
      keyColor = isBlack ? const Color(0xFF1E3A5F) : const Color(0xFFE3F2FD);
      textColor = isBlack ? Colors.white : const Color(0xFF1565C0);
      keyBorder = Border.all(color: const Color(0xFF1E88E5), width: 2.0);
    }

    final String displayLabel =
        isBlack ? note.replaceAll(_digitRegex, '') : note;

    return RepaintBoundary(
      child: AnimatedScale(
        scale: isActive ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: keyColor,
          border: keyBorder ?? Border.all(color: AppColors.primaryDark, width: isBlack ? 1.5 : 2.0),
          borderRadius: isBlack
              ? const BorderRadius.vertical(bottom: Radius.circular(8))
              : BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isBlack
                  ? Colors.black.withValues(alpha: 0.35)
                  : AppColors.primaryDark.withValues(alpha: 0.12),
              blurRadius: isBlack ? 6 : 4,
              offset: Offset(0, isBlack ? 4 : 3),
            ),
          ],
        ),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: isBlack ? 6 : 10),
        child: showLabel
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRoot && !isCorrect && !isWrong)
                    Transform.rotate(
                      angle: -0.06,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryDark, width: 1.2),
                        ),
                        child: const Text(
                          'ROOT',
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    displayLabel,
                    style: TextStyle(
                      fontSize: isBlack ? 10 : 11,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              )
            : null,
      ),
    ),
  );
}
}

class _PianoBridgePainter extends CustomPainter {
  _PianoBridgePainter({
    required this.notes,
    required this.whiteNotes,
    required this.startNote,
    required this.endNote,
    required this.label,
    required this.whiteKeyWidth,
    required this.keyGap,
  });

  final List<String> notes;
  final List<String> whiteNotes;
  final String startNote;
  final String endNote;
  final String label;
  final double whiteKeyWidth;
  final double keyGap;

  double _getNoteCenterX(String note) {
    final whiteStride = whiteKeyWidth + keyGap;
    if (_kBlackKeyAfterWhiteIndex.containsKey(note)) {
      final afterIdx = _kBlackKeyAfterWhiteIndex[note]!;
      final actualWhiteIdx = whiteNotes.indexOf(_kWhiteNotes[afterIdx]);
      if (actualWhiteIdx != -1) {
        return (actualWhiteIdx + 1) * whiteStride - keyGap / 2;
      }
    }

    final wIdx = whiteNotes.indexOf(note);
    if (wIdx != -1) {
      return wIdx * whiteStride + whiteKeyWidth / 2;
    }
    return 0.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final x1 = _getNoteCenterX(startNote);
    final x2 = _getNoteCenterX(endNote);
    if (x1 == 0.0 && x2 == 0.0) return;

    final y = size.height * 0.35;

    final paint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(x1, y);

    final controlX = (x1 + x2) / 2;
    final controlY = y - 45;
    path.quadraticBezierTo(controlX, controlY, x2, y);

    canvas.drawCircle(
      Offset(x1, y),
      5.0,
      Paint()..color = AppColors.primaryDark..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(x2, y),
      5.0,
      Paint()..color = AppColors.primaryDark..style = PaintingStyle.fill,
    );

    canvas.drawPath(path, paint);

    final bx = 0.25 * x1 + 0.5 * controlX + 0.25 * x2;
    final by = 0.25 * y + 0.5 * controlY + 0.25 * y;

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: AppColors.primaryDark,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final pillRect = Rect.fromCenter(
      center: Offset(bx, by - 5),
      width: textPainter.width + 12,
      height: textPainter.height + 6,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(8)),
      Paint()..color = Colors.white..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pillRect, const Radius.circular(8)),
      Paint()
        ..color = AppColors.primaryDark.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    textPainter.paint(
      canvas,
      Offset(bx - textPainter.width / 2, by - 5 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PianoBridgePainter oldDelegate) {
    return oldDelegate.startNote != startNote ||
        oldDelegate.endNote != endNote ||
        oldDelegate.label != label ||
        oldDelegate.whiteKeyWidth != whiteKeyWidth ||
        oldDelegate.keyGap != keyGap;
  }
}