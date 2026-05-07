import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../provider/audio_provider.dart';
import '../provider/playlist_provider.dart';
import '../provider/theme_provider.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class PlaylistScreen extends StatelessWidget {
  final PlaylistModel playlist;

  const PlaylistScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 28,
            color: textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          playlist.name,
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz_rounded, color: textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<PlaylistProvider, AudioProvider>(
        builder: (context, playlistProvider, audioProvider, _) {
          final allSongs = audioProvider.playlist;
          final songs = playlistProvider.getSongsForPlaylist(
            playlist,
            allSongs,
          );

          if (songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: 56,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Playlist is empty',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textOnDarkSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add songs from your library',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Play all button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Text(
                      '${songs.length} songs',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    _PlayAllButton(
                      onTap: () => _playAll(context, songs, audioProvider),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(
                      bottom: AppSizes.miniPlayerHeight + 16),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final song = songs[index];
                    final isCurrent =
                        audioProvider.currentSong?.id == song.id;
                    return SongTile(
                      song: song,
                      isCurrentSong: isCurrent,
                      onTap: () => _playSong(
                          context, songs, index, audioProvider),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _playAll(
      BuildContext context, List<SongModel> songs, AudioProvider provider) {
    provider.setPlaylist(songs, 0);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const NowPlayingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _playSong(
    BuildContext context,
    List<SongModel> songs,
    int index,
    AudioProvider provider,
  ) {
    provider.setPlaylist(songs, index);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const NowPlayingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class _PlayAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayAllButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius:
              BorderRadius.circular(AppSizes.buttonRadius),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded,
                color: Colors.white, size: 18),
            SizedBox(width: 4),
            Text(
              'Play all',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
