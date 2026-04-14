import 'package:flutter/material.dart';
import 'package:reyrazak/config/app_config.dart';
import '../services/api_service.dart';
import '../models/movie.dart';
import '../screens/detail_screen.dart';

/// Collections Row Widget
///
/// Displays a horizontal scrolling row of collections/box sets.
/// Used on the Home Screen to showcase curated content collections.
class CollectionsRow extends StatefulWidget {
  final ApiService apiService;

  const CollectionsRow({
    super.key,
    required this.apiService,
  });

  @override
  State<CollectionsRow> createState() => _CollectionsRowState();
}

class _CollectionsRowState extends State<CollectionsRow> {
  List<Movie> _collections = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final collections = await widget.apiService.fetchCollections();

      setState(() {
        _collections = collections
            .map((json) => Movie.fromJson(json))
            .take(10) // Show up to 10 collections
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading collections: $e');
      setState(() {
        _error = 'Failed to load collections';
        _isLoading = false;
      });
    }
  }

  void _openCollection(Movie collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScreen(
          content: collection,
          imageUrl: widget.apiService.getImageUrl(collection.id),
          backdropUrl: widget.apiService.getBackdropUrl(collection.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_collections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ThemeConfig.spacingXL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Collections',
                style: ThemeConfig.heading2,
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to full collections view
                },
                icon: Icon(
                  Icons.arrow_forward,
                  color: ThemeConfig.textSecondary,
                  size: ThemeConfig.iconSizeM,
                ),
                label: Text(
                  'See All',
                  style: ThemeConfig.bodyMedium.copyWith(
                    color: ThemeConfig.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: ThemeConfig.spacingM),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: ThemeConfig.spacingXL),
            itemCount: _collections.length,
            itemBuilder: (context, index) {
              final collection = _collections[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < _collections.length - 1 ? ThemeConfig.spacingM : 0,
                ),
                child: _CollectionCard(
                  collection: collection,
                  imageUrl: widget.apiService.getImageUrl(collection.id),
                  onTap: () => _openCollection(collection),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ThemeConfig.spacingXL),
          child: Text(
            'Collections',
            style: ThemeConfig.heading2,
          ),
        ),
        SizedBox(height: ThemeConfig.spacingM),
        SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(
              color: ThemeConfig.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ThemeConfig.spacingXL),
          child: Text(
            'Collections',
            style: ThemeConfig.heading2,
          ),
        ),
        SizedBox(height: ThemeConfig.spacingM),
        SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: ThemeConfig.textSecondary,
                  size: ThemeConfig.iconSizeXL,
                ),
                SizedBox(height: ThemeConfig.spacingS),
                Text(
                  _error ?? 'Failed to load collections',
                  style: ThemeConfig.bodyMedium.copyWith(
                    color: ThemeConfig.textSecondary,
                  ),
                ),
                SizedBox(height: ThemeConfig.spacingM),
                TextButton.icon(
                  onPressed: _loadCollections,
                  icon: Icon(Icons.refresh, size: ThemeConfig.iconSizeM),
                  label: const Text('Retry'),
                  style: TextButton.styleFrom(
                    foregroundColor: ThemeConfig.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Collection Card Widget
class _CollectionCard extends StatefulWidget {
  final Movie collection;
  final String imageUrl;
  final VoidCallback onTap;

  const _CollectionCard({
    required this.collection,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: ThemeConfig.animationFast,
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: ThemeConfig.primary.withValues(alpha: 0.4),
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
              borderRadius: BorderRadius.circular(ThemeConfig.radiusL),
              child: Stack(
                children: [
                  // Background Image
                  Container(
                    width: 320,
                    height: 200,
                    color: ThemeConfig.surface,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: ThemeConfig.surface,
                          child: Icon(
                            Icons.collections,
                            color: ThemeConfig.textSecondary,
                            size: ThemeConfig.iconSizeXL,
                          ),
                        );
                      },
                    ),
                  ),
                  // Gradient Overlay
                  Container(
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
                  // Collection Badge
                  Positioned(
                    top: ThemeConfig.spacingS,
                    left: ThemeConfig.spacingS,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ThemeConfig.spacingS,
                        vertical: ThemeConfig.spacingXS,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConfig.accent,
                        borderRadius: BorderRadius.circular(ThemeConfig.radiusS),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.collections,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: ThemeConfig.spacingXS),
                          Text(
                            'Collection',
                            style: ThemeConfig.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Play Button Overlay (shown on hover)
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
                              color: ThemeConfig.primary.withValues(alpha: 0.5),
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
                  // Collection Title and Info
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: EdgeInsets.all(ThemeConfig.spacingM),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.collection.title,
                            style: ThemeConfig.heading3.copyWith(
                              color: ThemeConfig.textPrimary,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: ThemeConfig.spacingXS),
                          Row(
                            children: [
                              Icon(
                                Icons.movie,
                                size: ThemeConfig.iconSizeS,
                                color: ThemeConfig.textSecondary,
                              ),
                              SizedBox(width: ThemeConfig.spacingXS),
                              Text(
                                'View Collection',
                                style: ThemeConfig.caption.copyWith(
                                  color: ThemeConfig.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
