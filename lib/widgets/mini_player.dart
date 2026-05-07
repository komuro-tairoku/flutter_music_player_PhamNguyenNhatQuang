import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playback_state_model.dart';
import '../provider/audio_provider.dart';
import '../provider/theme_provider.dart';
import '../utils/constants.dart';
import 'album_art.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        final currentSong = audioProvider.currentSong;
        if (currentSong == null) return const SizedBox.shrink();

        final bgColor =
            isDark ? AppColors.surfaceDark : AppColors.surface;
        final textPrimary =
            isDark ? AppColors.textOnDark : AppColors.textPrimary;
        final textSecondary = AppColors.textSecondary;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Progress line ────────────────────────────────────
                // FIX: Use combined playbackStateStream instead of
                // nesting StreamBuilder<bool> + StreamBuilder<Duration>
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.cardRadius),
                  ),
                  child: StreamBuilder<PlaybackStateModel>(
                    stream: audioProvider.playbackStateStream,
                    builder: (context, snapshot) {
                      final progress =
                          snapshot.data?.progress.clamp(0.0, 1.0) ?? 0.0;
                      return SizedBox(
                        height: 2,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor:
                              isDark ? AppColors.dividerDark : AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          minHeight: 2,
                        ),
                      );
                    },
                  ),
                ),

                // ── Content row ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                  child: Row(
                    children: [
                      // Album art
                      AlbumArtWidget(
                        albumArtPath: currentSong.albumArt,
                        songId: currentSong.id,
                        size: 44,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 12),

                      // Song info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              currentSong.title,
                              style: TextStyle(
                                color: textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentSong.artist,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      StreamBuilder<bool>(
                        stream: audioProvider.playingStream,
                        builder: (context, snapshot) {
                          final isPlaying = snapshot.data ?? false;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ControlButton(
                                icon: isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                size: 26,
                                color: textPrimary,
                                onTap: () => audioProvider.playPause(),
                              ),
                              const SizedBox(width: 2),
                              _ControlButton(
                                icon: Icons.skip_next_rounded,
                                size: 24,
                                color: textSecondary,
                                onTap: () => audioProvider.next(),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}
