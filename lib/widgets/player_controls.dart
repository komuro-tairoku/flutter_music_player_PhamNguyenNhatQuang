import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../provider/audio_provider.dart';
import '../utils/constants.dart';

class PlayerControls extends StatelessWidget {
  final AudioProvider provider;
  final bool isDark;

  const PlayerControls({
    Key? key,
    required this.provider,
    this.isDark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final secondaryColor = AppColors.textTertiary;

    return Column(
      children: [
        // ── Main controls row ─────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Shuffle
            _SecondaryButton(
              icon: Icons.shuffle_rounded,
              color: provider.isShuffleEnabled
                  ? AppColors.primary
                  : secondaryColor,
              onTap: () => provider.toggleShuffle(),
              isDot: provider.isShuffleEnabled,
            ),

            // Previous
            GestureDetector(
              onTap: () => provider.previous(),
              child: Icon(
                Icons.skip_previous_rounded,
                color: iconColor,
                size: 36,
              ),
            ),

            // Play / Pause
            StreamBuilder<bool>(
              stream: provider.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                return _PlayButton(
                  isPlaying: isPlaying,
                  onTap: () => provider.playPause(),
                );
              },
            ),

            // Next
            GestureDetector(
              onTap: () => provider.next(),
              child: Icon(
                Icons.skip_next_rounded,
                color: iconColor,
                size: 36,
              ),
            ),

            // Repeat
            _SecondaryButton(
              icon: provider.loopMode == LoopMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
              color: provider.loopMode == LoopMode.off
                  ? secondaryColor
                  : AppColors.primary,
              onTap: () => provider.toggleRepeat(),
              isDot: provider.loopMode != LoopMode.off,
            ),
          ],
        ),
      ],
    );
  }
}

// ── Play / Pause button ──────────────────────────────────────────────────────

class _PlayButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: child,
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            key: ValueKey(isPlaying),
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

// ── Secondary icon button (shuffle/repeat) ───────────────────────────────────

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDot;

  const _SecondaryButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.isDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            if (isDot)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
