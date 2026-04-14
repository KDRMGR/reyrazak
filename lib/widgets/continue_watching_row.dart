import 'package:flutter/material.dart';
import 'package:reyrazak/config/app_config.dart';
import '../services/watch_progress_service.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import '../screens/universal_player_screen.dart';

class ContinueWatchingRow extends StatefulWidget {
  final ApiService apiService;

  const ContinueWatchingRow({
    super.key,
    required this.apiService,
  });

  @override
  State<ContinueWatchingRow> createState() => _ContinueWatchingRowState();
}

class _ContinueWatchingRowState extends State<ContinueWatchingRow> {
  final WatchProgressService _progressService = WatchProgressService();
  List<WatchProgress> _continueWatchingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContinueWatching();
  }

  Future<void> _loadContinueWatching() async {
    setState(() => _isLoading = true);
    try {
      final items = await _progressService.getContinueWatching();
      if (mounted) {
        setState(() {
          _continueWatchingItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _resumeWatching(WatchProgress item) {
    final movie = Movie(
      id: item.contentId,
      title: item.displayTitle,
    );

    // Convert stored ticks back to a Duration so the player can seek on start
    final resumePosition = item.positionTicks > 0
        ? Duration(microseconds: item.positionTicks ~/ 10)
        : null;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversalPlayerScreen(
          movie: movie,
          streamUrl: widget.apiService.getStreamUrl(item.contentId),
          startPosition: resumePosition,
        ),
      ),
    ).then((_) => _loadContinueWatching());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: ThemeConfig.primary),
        ),
      );
    }

    if (_continueWatchingItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ThemeConfig.spacingXL,
            vertical: ThemeConfig.spacingM,
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_outline,
                color: ThemeConfig.primary,
                size: ThemeConfig.iconSizeL,
              ),
              SizedBox(width: ThemeConfig.spacingM),
              Text(
                'Continue Watching',
                style: ThemeConfig.heading2,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: ThemeConfig.spacingXL),
            scrollDirection: Axis.horizontal,
            itemCount: _continueWatchingItems.length,
            itemBuilder: (context, index) {
              return _ContinueWatchingCard(
                item: _continueWatchingItems[index],
                onTap: () => _resumeWatching(_continueWatchingItems[index]),
                onRemove: () async {
                  await _progressService.removeFromContinueWatching(
                    _continueWatchingItems[index].contentId,
                  );
                  _loadContinueWatching();
                },
                // Always derive the image URL from the content ID — the
                // posterUrl field is metadata only; the actual URL is built
                // server-side from the ID.
                imageUrl: widget.apiService
                    .getImageUrl(_continueWatchingItems[index].contentId),
              );
            },
          ),
        ),
        SizedBox(height: ThemeConfig.spacingL),
      ],
    );
  }
}

class _ContinueWatchingCard extends StatefulWidget {
  final WatchProgress item;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final String imageUrl;

  const _ContinueWatchingCard({
    required this.item,
    required this.onTap,
    required this.onRemove,
    required this.imageUrl,
  });

  @override
  State<_ContinueWatchingCard> createState() => _ContinueWatchingCardState();
}

class _ContinueWatchingCardState extends State<_ContinueWatchingCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 300,
          margin: EdgeInsets.only(right: ThemeConfig.spacingM),
          child: AnimatedScale(
            duration: ThemeConfig.animationFast,
            scale: _isHovered ? 1.05 : 1.0,
            child: Stack(
              children: [
                // Background Card
                Container(
                  decoration: BoxDecoration(
                    color: ThemeConfig.surface,
                    borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
                    boxShadow: _isHovered
                        ? [
                            BoxShadow(
                              color: ThemeConfig.primary.withValues(alpha: 0.3),
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
                  child: Row(
                    children: [
                      // Thumbnail with Progress
                      SizedBox(
                        width: 120,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    Radius.circular(ThemeConfig.radiusL),
                                bottomLeft:
                                    Radius.circular(ThemeConfig.radiusL),
                              ),
                              child: AspectRatio(
                                aspectRatio: 2 / 3,
                                child: widget.imageUrl.isNotEmpty
                                    ? Image.network(
                                        widget.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stack) {
                                          return Container(
                                            color: ThemeConfig.surface,
                                            child: Icon(
                                              Icons.movie_outlined,
                                              color: ThemeConfig.textSecondary,
                                              size: ThemeConfig.iconSizeXL,
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: ThemeConfig.surface,
                                        child: Icon(
                                          Icons.movie_outlined,
                                          color: ThemeConfig.textSecondary,
                                          size: ThemeConfig.iconSizeXL,
                                        ),
                                      ),
                              ),
                            ),
                            // Play Icon Overlay
                            if (_isHovered)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          Radius.circular(ThemeConfig.radiusL),
                                      bottomLeft:
                                          Radius.circular(ThemeConfig.radiusL),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    size: 48,
                                    color: ThemeConfig.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Content Info
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(ThemeConfig.spacingM),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.item.displayTitle,
                                style: ThemeConfig.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: ThemeConfig.spacingS),
                              Text(
                                widget.item.timeRemainingFormatted,
                                style: ThemeConfig.bodySmall.copyWith(
                                  color: ThemeConfig.textSecondary,
                                ),
                              ),
                              SizedBox(height: ThemeConfig.spacingS),
                              // Progress Bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: widget.item.progress,
                                  backgroundColor: ThemeConfig.surface
                                      .withValues(alpha: 0.3),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ThemeConfig.primary,
                                  ),
                                  minHeight: 4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Remove Button
                if (_isHovered)
                  Positioned(
                    top: ThemeConfig.spacingS,
                    right: ThemeConfig.spacingS,
                    child: GestureDetector(
                      onTap: widget.onRemove,
                      child: Container(
                        padding: EdgeInsets.all(ThemeConfig.spacingXS),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: ThemeConfig.iconSizeM,
                          color: ThemeConfig.textPrimary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
