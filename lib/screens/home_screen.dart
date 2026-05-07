import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../provider/audio_provider.dart';
import '../provider/theme_provider.dart';
import '../services/playlist_service.dart';
import '../services/permission_service.dart';
import '../utils/constants.dart';
import '../widgets/song_tile.dart';
import 'now_playing_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PlaylistService _playlistService = PlaylistService();
  final PermissionService _permissionService = PermissionService();
  final TextEditingController _searchController = TextEditingController();

  List<SongModel> _allSongs = [];
  List<SongModel> _filteredSongs = [];
  bool _isLoading = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSongs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    final hasPermission =
        await _permissionService.requestAudioPermission();

    if (!hasPermission) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showPermissionBanner();
      }
      return;
    }

    try {
      final songs = await _playlistService.getAllSongs();
      if (!mounted) return;
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load music: $e'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showPermissionBanner() {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: const Text(AppStrings.permissionMessage),
        backgroundColor: AppColors.surface,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              _loadSongs();
            },
            child: const Text(
              'Allow',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _filterSongs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        final q = query.toLowerCase();
        _filteredSongs = _allSongs.where((song) {
          return song.title.toLowerCase().contains(q) ||
              song.artist.toLowerCase().contains(q) ||
              (song.album?.toLowerCase().contains(q) ?? false);
        }).toList();
      }
    });
  }

  // FIX: correctly find song in _allSongs by id, then set full playlist
  void _playSong(SongModel tappedSong) {
    final audioProvider = context.read<AudioProvider>();
    final songIndex = _allSongs.indexWhere((s) => s.id == tappedSong.id);
    if (songIndex != -1) {
      audioProvider.setPlaylist(_allSongs, songIndex);
    } else {
      audioProvider.playSong(tappedSong);
    }
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const NowPlayingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.background;
    final textPrimary =
        isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final textSecondary = AppColors.textSecondary;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPadding, 24, AppSizes.screenPadding, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Library',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                            letterSpacing: -1,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      if (!_isLoading && _allSongs.isNotEmpty)
                        Text(
                          '${_allSongs.length} tracks',
                          style: TextStyle(
                            fontSize: 12,
                            color: textSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      const SizedBox(width: 12),
                      _ThemeToggleButton(isDark: isDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Search bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.screenPadding),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isSearching
                        ? AppColors.primary.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  onChanged: (v) {
                    _filterSongs(v);
                    setState(() => _isSearching = v.isNotEmpty);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search songs, artists…',
                    hintStyle: TextStyle(
                      color: textSecondary.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: _isSearching
                          ? AppColors.primary
                          : textSecondary,
                      size: 20,
                    ),
                    suffixIcon: _isSearching
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _filterSongs('');
                              setState(() => _isSearching = false);
                            },
                            child: Icon(Icons.close_rounded,
                                color: textSecondary, size: 18),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Song list ───────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? _buildLoadingState(isDark)
                  : _allSongs.isEmpty
                      ? _buildEmptyState(isDark, textSecondary)
                      : _filteredSongs.isEmpty
                          ? _buildNoResultsState(textSecondary)
                          : _buildSongList(isDark),
            ),

            // Bottom padding for mini player
            const SizedBox(height: AppSizes.miniPlayerHeight + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPadding, vertical: 8),
      itemCount: 8,
      itemBuilder: (_, i) => _SkeletonTile(isDark: isDark, index: i),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textSecondary) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.music_note_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.noSongsFound,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.addMusicMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: _loadSongs,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(Color textSecondary) {
    return Center(
      child: Text(
        'No results for "${_searchController.text}"',
        style: TextStyle(color: textSecondary, fontSize: 14),
      ),
    );
  }

  Widget _buildSongList(bool isDark) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, _) {
        return ListView.builder(
          padding: const EdgeInsets.only(
              top: 8, bottom: AppSizes.miniPlayerHeight + 16),
          itemCount: _filteredSongs.length,
          itemBuilder: (context, index) {
            final song = _filteredSongs[index];
            final isCurrent = audioProvider.currentSong?.id == song.id;
            return SongTile(
              song: song,
              isCurrentSong: isCurrent,
              onTap: () => _playSong(song),
            );
          },
        );
      },
    );
  }
}

// ── Theme toggle button ──────────────────────────────────────────────────────

class _ThemeToggleButton extends StatelessWidget {
  final bool isDark;
  const _ThemeToggleButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ThemeProvider>().toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 20,
          color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Skeleton loading tile ────────────────────────────────────────────────────

class _SkeletonTile extends StatefulWidget {
  final bool isDark;
  final int index;
  const _SkeletonTile({required this.isDark, required this.index});

  @override
  State<_SkeletonTile> createState() => _SkeletonTileState();
}

class _SkeletonTileState extends State<_SkeletonTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.isDark ? const Color(0xFF2A2724) : AppColors.surface;
    final highlight =
        widget.isDark ? const Color(0xFF343028) : AppColors.surfaceElevated;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final color = Color.lerp(base, highlight, _anim.value)!;
          return Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(AppSizes.albumArtBorderRadius),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 13,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 11,
                      width: 120,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
