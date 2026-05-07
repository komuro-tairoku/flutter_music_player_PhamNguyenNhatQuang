import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playback_state_model.dart';
import '../provider/audio_provider.dart';
import '../provider/theme_provider.dart';
import '../utils/constants.dart';
import '../widgets/album_art.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final textSecondary = AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, _) {
          final currentSong = audioProvider.currentSong;

          if (currentSong == null) {
            return const _EmptyState();
          }

          return SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 30,
                          color: textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'NOW PLAYING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentSong.album ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: textSecondary,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_horiz_rounded,
                            color: textPrimary),
                        onPressed: () =>
                            _showSongOptions(context, audioProvider),
                      ),
                    ],
                  ),
                ),

                // ── Album art ─────────────────────────────────────────
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: Center(
                      child: _AnimatedAlbumArt(
                        key: ValueKey(currentSong.id),
                        child: AlbumArtWidget(
                          albumArtPath: currentSong.albumArt,
                          songId: currentSong.id,
                          size: MediaQuery.of(context).size.width - 64,
                          borderRadius: AppSizes.cardRadius,
                          showShadow: true,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Song info ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: textPrimary,
                                letterSpacing: -0.5,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentSong.artist,
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Progress bar (FIX: single StreamBuilder with combined stream) ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding - 4),
                  child: StreamBuilder<PlaybackStateModel>(
                    stream: audioProvider.playbackStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      return ProgressBarWidget(
                        position: state?.position ?? Duration.zero,
                        duration: state?.duration ?? Duration.zero,
                        onSeek: audioProvider.seek,
                        isDark: isDark,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // ── Player controls ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding),
                  child: PlayerControls(
                    provider: audioProvider,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 12),

                // ── Volume ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.screenPadding),
                  child: _VolumeControl(
                    volume: audioProvider.volume,
                    onChanged: audioProvider.setVolume,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSongOptions(BuildContext context, AudioProvider provider) {
    final song = provider.currentSong;
    if (song == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          context.read<ThemeProvider>().isDarkMode
              ? AppColors.surfaceDark
              : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AlbumArtWidget(
                    albumArtPath: song.albumArt,
                    songId: song.id,
                    size: 48,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          song.artist,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            ListTile(
              leading: const Icon(Icons.queue_music_rounded,
                  color: AppColors.primary),
              title: const Text('View queue'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary),
              title: const Text('Song info'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Animated album art (scale in on song change) ────────────────────────────

class _AnimatedAlbumArt extends StatefulWidget {
  final Widget child;
  const _AnimatedAlbumArt({Key? key, required this.child}) : super(key: key);

  @override
  State<_AnimatedAlbumArt> createState() => _AnimatedAlbumArtState();
}

class _AnimatedAlbumArtState extends State<_AnimatedAlbumArt>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.scale(
          scale: _scale.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

// ── Volume control ───────────────────────────────────────────────────────────

class _VolumeControl extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;
  final bool isDark;

  const _VolumeControl({
    required this.volume,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.textTertiary;
    return Row(
      children: [
        Icon(Icons.volume_mute_rounded, size: 18, color: iconColor),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: isDark
                  ? AppColors.dividerDark
                  : AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.15),
            ),
            child: Slider(
              value: volume,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ),
        Icon(Icons.volume_up_rounded, size: 18, color: iconColor),
      ],
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.music_off_rounded,
              size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'No song playing',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
