import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../provider/playlist_provider.dart';
import '../provider/theme_provider.dart';
import '../utils/constants.dart';
import '../utils/duration_formatter.dart';
import 'album_art.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final bool isCurrentSong;

  const SongTile({
    Key? key,
    required this.song,
    required this.onTap,
    this.isCurrentSong = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final textPrimary =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final textSecondary = AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.primary.withOpacity(0.06),
      highlightColor: AppColors.primary.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            // ── Album art with playing indicator ─────────────────────
            Stack(
              children: [
                AlbumArtWidget(
                  albumArtPath: song.albumArt,
                  songId: song.id,
                  size: 50,
                  borderRadius: 8,
                ),
                if (isCurrentSong)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.equalizer_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            // ── Song info ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: TextStyle(
                      color:
                          isCurrentSong ? AppColors.primary : textPrimary,
                      fontWeight: isCurrentSong
                          ? FontWeight.w600
                          : FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.duration != null
                        ? '${song.artist}  ·  ${DurationFormatter.format(song.duration!)}'
                        : song.artist,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── More button ──────────────────────────────────────────
            GestureDetector(
              onTap: () => _showOptionsMenu(context),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: textSecondary,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final playlists = context.read<PlaylistProvider>().playlists;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Song header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AlbumArtWidget(
                      albumArtPath: song.albumArt,
                      songId: song.id,
                      size: 44,
                      borderRadius: 8,
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
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
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

              Divider(
                height: 1,
                color: isDark
                    ? AppColors.dividerDark
                    : AppColors.divider,
              ),

              _OptionTile(
                icon: Icons.playlist_add_rounded,
                label: 'Add to playlist',
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddToPlaylist(context, playlists);
                },
              ),
              _OptionTile(
                icon: Icons.queue_music_rounded,
                label: 'Play next',
                onTap: () => Navigator.pop(ctx),
              ),
              _OptionTile(
                icon: Icons.info_outline_rounded,
                label: 'Song info',
                onTap: () {
                  Navigator.pop(ctx);
                  _showSongInfo(context);
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showAddToPlaylist(BuildContext context, playlists) {
    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No playlists yet — create one first!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.surfaceDark : AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add to playlist',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              ...playlists.map(
                (playlist) => ListTile(
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.queue_music_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  title: Text(
                    playlist.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${playlist.songCount} songs',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  onTap: () {
                    context
                        .read<PlaylistProvider>()
                        .addSongToPlaylist(playlist.id, song.id);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added to ${playlist.name}'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showSongInfo(BuildContext context) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: const Text(
          'Song Info',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _infoRow('Title', song.title),
            _infoRow('Artist', song.artist),
            _infoRow('Album', song.album ?? 'Unknown'),
            if (song.duration != null)
              _infoRow(
                  'Duration', DurationFormatter.format(song.duration!)),
            if (song.fileSize != null)
              _infoRow(
                  'Size',
                  DurationFormatter.formatFileSize(song.fileSize!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap,
      minLeadingWidth: 24,
    );
  }
}
