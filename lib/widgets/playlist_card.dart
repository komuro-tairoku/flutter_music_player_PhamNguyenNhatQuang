import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../utils/constants.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistModel playlist;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const PlaylistCard({
    Key? key,
    required this.playlist,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        child: Row(
          children: [
            // Cover art
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.cardRadius),
                  bottomLeft: Radius.circular(AppSizes.cardRadius),
                ),
              ),
              child: Icon(
                Icons.queue_music_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color:
                          isDark ? AppColors.textOnDark : AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${playlist.songCount} ${playlist.songCount == 1 ? 'song' : 'songs'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Delete
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
