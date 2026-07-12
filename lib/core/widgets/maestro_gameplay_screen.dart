import 'package:flutter/material.dart';
import 'package:melody_sense/core/theme/app_colors.dart';
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
    this.xp = 0,
    this.progress = 0.0,
    this.activeHardwareNote,
    this.comboCount,
    this.onClose,
  });

  final bool isConnected;

  /// Portrait: judul besar (mis. "Repeat the Melody").
  /// Landscape: nama challenge di bawah label "CURRENT CHALLENGE".
  final String title;

  /// Hanya dipakai di portrait, mis. instruksi latihan.
  final String? subtitle;

  final int xp;

  /// 0.0 - 1.0
  final double progress;

  /// Nada yang sedang ditekan di Smart Piano fisik (dari WebSocket).
  final String? activeHardwareNote;

  /// Null = tidak tampilkan combo badge (mis. Melody Echo tidak punya
  /// combo di desain).
  final int? comboCount;

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
              const Spacer(),
              _CloseButton(onTap: onClose),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ProgressBar(progress: progress)),
              const SizedBox(width: 10),
              _XpCounter(xp: xp),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 12),
          const Expanded(child: Center(child: _MascotWithSoundWave())),
          const SizedBox(height: 16),
          const Text(
            'PHYSICAL DEVICE STATUS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          VirtualPiano(
            height: 48,
            showLabels: false,
            activeNote: activeHardwareNote,
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
              const SizedBox(width: 4),
              _ConnectionBadge(isConnected: isConnected),
              const Spacer(),
              if (comboCount != null) _ComboBadge(count: comboCount!),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'CURRENT CHALLENGE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _ProgressBar(progress: progress, height: 6)),
              const SizedBox(width: 10),
              Text(
                '${(progress.clamp(0.0, 1.0) * 100).round()}% Completed',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight.clamp(0.0, 300.0);
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: VirtualPiano(
                    height: height,
                    activeNote: activeHardwareNote,
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
        const Icon(Icons.monetization_on, color: Colors.amber, size: 15),
        const SizedBox(width: 3),
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
        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
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
            style: const TextStyle(
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
            style: const TextStyle(
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
          decoration: const BoxDecoration(
            color: AppColors.surfaceTint,
            shape: BoxShape.circle,
          ),
          child: const Icon(
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