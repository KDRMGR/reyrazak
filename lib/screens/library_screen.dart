import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reyrazak/config/app_config.dart';
import '../providers/content_provider.dart';
import '../models/movie.dart';
import 'universal_player_screen.dart';
import 'detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _tabs = [
    {'title': 'All', 'icon': Icons.video_library},
    {'title': 'Movies', 'icon': Icons.movie},
    {'title': 'TV Shows', 'icon': Icons.tv},
    {'title': 'Anime', 'icon': Icons.animation},
    {'title': 'Music Videos', 'icon': Icons.music_video},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _playContent(Movie content, ContentProvider provider, List<Movie> playlist, int currentIndex) {
    // Check if it's a series (TV show) or movie
    final isSeries = content.title.toLowerCase().contains('series') ||
        content.title.toLowerCase().contains('season');

    if (isSeries) {
      // Navigate to detail screen for series
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(
            content: content,
            imageUrl: provider.getImageUrl(content.id),
            backdropUrl: provider.getBackdropUrl(content.id),
          ),
        ),
      );
    } else {
      // Direct play for movies and music videos with playlist support
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UniversalPlayerScreen(
            movie: content,
            streamUrl: provider.getStreamUrl(content.id),
            playlist: playlist,
            currentIndex: currentIndex,
          ),
        ),
      );
    }
  }

  List<Movie> _filterContent(List<Movie> content, String filter, ContentProvider provider) {
    if (filter == 'All') return content;

    switch (filter) {
      case 'Movies':
        return provider.movies;
      case 'TV Shows':
        return provider.shows;
      case 'Music Videos':
        return provider.musicVideos;
      case 'Anime':
        // Filter anime by title keywords (ideally should use genre from API)
        return content.where((item) {
          final title = item.title.toLowerCase();
          return title.contains('anime') ||
              title.contains('one piece') ||
              title.contains('naruto') ||
              title.contains('dragon ball') ||
              title.contains('attack on titan') ||
              title.contains('demon slayer') ||
              title.contains('my hero academia');
        }).toList();
      default:
        return content;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        return Container(
          color: ThemeConfig.background,
          child: Column(
            children: [
              // Header with Title and Tabs
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ThemeConfig.spacingXL,
                  vertical: ThemeConfig.spacingL,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      ThemeConfig.background,
                      ThemeConfig.background.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Library',
                      style: ThemeConfig.heading1,
                    ),
                    SizedBox(height: ThemeConfig.spacingL),
                    _buildTabBar(),
                  ],
                ),
              ),
              // Content Grid
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    return _buildContentGrid(
                      _filterContent(contentProvider.allContent, tab['title'], contentProvider),
                      contentProvider,
                      tab['title'],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: ThemeConfig.surface,
        borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: ThemeConfig.primary,
          borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: ThemeConfig.textPrimary,
        unselectedLabelColor: ThemeConfig.textSecondary,
        labelStyle: ThemeConfig.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: ThemeConfig.bodyMedium,
        tabs: _tabs.map((tab) {
          return Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tab['icon'], size: ThemeConfig.iconSizeM),
                SizedBox(width: ThemeConfig.spacingS),
                Text(tab['title']),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _shufflePlayMusicVideos(List<Movie> musicVideos, ContentProvider provider) {
    if (musicVideos.isEmpty) return;

    // Shuffle the list
    final shuffled = List<Movie>.from(musicVideos)..shuffle();

    // Play the first video with full playlist for next/previous navigation
    final firstVideo = shuffled.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversalPlayerScreen(
          movie: firstVideo,
          streamUrl: provider.getStreamUrl(firstVideo.id),
          playlist: shuffled,
          currentIndex: 0,
        ),
      ),
    );
  }

  Widget _buildContentGrid(
      List<Movie> content, ContentProvider provider, String category) {
    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: ThemeConfig.textSecondary.withValues(alpha: 0.3),
            ),
            SizedBox(height: ThemeConfig.spacingL),
            Text(
              'No $category Available',
              style: ThemeConfig.heading3.copyWith(
                color: ThemeConfig.textSecondary,
              ),
            ),
            SizedBox(height: ThemeConfig.spacingS),
            Text(
              'Check back later for new content',
              style: ThemeConfig.bodyMedium.copyWith(
                color: ThemeConfig.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Shuffle button for Music Videos only
        if (category == 'Music Videos' && content.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ThemeConfig.spacingXL,
              vertical: ThemeConfig.spacingM,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _shufflePlayMusicVideos(content, provider),
                icon: Icon(Icons.shuffle, size: 24),
                label: Text(
                  'Shuffle Play All',
                  style: ThemeConfig.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.primary,
                  foregroundColor: ThemeConfig.textPrimary,
                  elevation: 4,
                  shadowColor: ThemeConfig.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
                  ),
                ),
              ),
            ),
          ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(ThemeConfig.spacingXL),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 0.66,
              crossAxisSpacing: ThemeConfig.spacingM,
              mainAxisSpacing: ThemeConfig.spacingL,
            ),
            itemCount: content.length,
            itemBuilder: (context, index) {
              final item = content[index];
              return _EnhancedGridCard(
                movie: item,
                imageUrl: provider.getImageUrl(item.id),
                onTap: () => _playContent(item, provider, content, index),
                category: category,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EnhancedGridCard extends StatefulWidget {
  final Movie movie;
  final String imageUrl;
  final VoidCallback onTap;
  final String category;

  const _EnhancedGridCard({
    required this.movie,
    required this.imageUrl,
    required this.onTap,
    required this.category,
  });

  @override
  State<_EnhancedGridCard> createState() => _EnhancedGridCardState();
}

class _EnhancedGridCardState extends State<_EnhancedGridCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: ThemeConfig.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  String _getCategoryBadge() {
    final title = widget.movie.title.toLowerCase();
    if (title.contains('series') || title.contains('season')) return 'TV';
    if (title.contains('anime')) return 'Anime';
    if (title.contains('music')) return 'Music';
    return 'Movie';
  }

  Color _getCategoryColor() {
    final badge = _getCategoryBadge();
    switch (badge) {
      case 'TV':
        return Colors.blue;
      case 'Anime':
        return Colors.purple;
      case 'Music':
        return Colors.green;
      default:
        return ThemeConfig.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Poster Image
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(ThemeConfig.radiusL),
                        boxShadow: _isHovered
                            ? [
                                BoxShadow(
                                  color: _getCategoryColor().withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(ThemeConfig.radiusL),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: ThemeConfig.surface,
                                  child: Icon(
                                    Icons.movie_outlined,
                                    color: ThemeConfig.textSecondary,
                                    size: ThemeConfig.iconSizeXL,
                                  ),
                                );
                              },
                            ),
                            // Gradient Overlay (shown on hover)
                            AnimatedOpacity(
                              opacity: _isHovered ? 1.0 : 0.0,
                              duration: ThemeConfig.animationFast,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Play Button (shown on hover)
                            AnimatedOpacity(
                              opacity: _isHovered ? 1.0 : 0.0,
                              duration: ThemeConfig.animationFast,
                              child: Center(
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: ThemeConfig.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeConfig.primary
                                            .withValues(alpha: 0.5),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: ThemeConfig.textPrimary,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Category Badge
                    Positioned(
                      top: ThemeConfig.spacingS,
                      right: ThemeConfig.spacingS,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ThemeConfig.spacingS,
                          vertical: ThemeConfig.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(),
                          borderRadius:
                              BorderRadius.circular(ThemeConfig.radiusS),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          _getCategoryBadge(),
                          style: ThemeConfig.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ThemeConfig.spacingS),
              // Title
              Text(
                widget.movie.title,
                style: ThemeConfig.bodyMedium.copyWith(
                  color: _isHovered
                      ? ThemeConfig.textPrimary
                      : ThemeConfig.textSecondary,
                  fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
