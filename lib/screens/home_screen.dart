import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../models/movie.dart';
import '../widgets/movie_row.dart';
import '../widgets/hero_banner.dart';
import '../widgets/continue_watching_row.dart';
import '../widgets/collections_row.dart';
import 'package:reyrazak/config/app_config.dart';
import 'universal_player_screen.dart';
import 'detail_screen.dart';

/// Enhanced Home Screen
///
/// Modern Netflix-style home screen featuring:
/// - Hero banner with featured content
/// - Continue Watching section
/// - Collections/Box Sets
/// - Genre-based content rows
/// - Trending and Popular sections
/// - Recently Added content
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ContentProvider>(context, listen: false).fetchAllContent();
    });
  }

  void _playContent(Movie content, ContentProvider provider) {
    if (content.isSeries) {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UniversalPlayerScreen(
            movie: content,
            streamUrl: provider.getStreamUrl(content.id),
          ),
        ),
      );
    }
  }

  /// Filter content by genre/tag keywords
  List<Movie> _filterByKeywords(List<Movie> content, List<String> keywords) {
    return content.where((item) {
      final title = item.title.toLowerCase();
      return keywords.any((keyword) => title.contains(keyword.toLowerCase()));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        if (contentProvider.isLoading) {
          return Container(
            color: ThemeConfig.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: ThemeConfig.primary),
                  SizedBox(height: ThemeConfig.spacingL),
                  Text(
                    'Loading your content...',
                    style: ThemeConfig.bodyLarge.copyWith(
                      color: ThemeConfig.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (contentProvider.errorMessage != null) {
          return Container(
            color: ThemeConfig.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: ThemeConfig.primary,
                    size: ThemeConfig.iconSizeXL * 2,
                  ),
                  SizedBox(height: ThemeConfig.spacingL),
                  Text(
                    'Oops! Something went wrong',
                    style: ThemeConfig.heading2,
                  ),
                  SizedBox(height: ThemeConfig.spacingS),
                  Text(
                    contentProvider.errorMessage!,
                    style: ThemeConfig.bodyMedium.copyWith(
                      color: ThemeConfig.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ThemeConfig.spacingL),
                  ElevatedButton.icon(
                    onPressed: () {
                      contentProvider.fetchAllContent();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: ThemeConfig.spacingL,
                        vertical: ThemeConfig.spacingM,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (contentProvider.allContent.isEmpty) {
          return Container(
            color: ThemeConfig.background,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_outlined,
                    color: ThemeConfig.textSecondary.withValues(alpha: 0.3),
                    size: ThemeConfig.iconSizeXL * 2,
                  ),
                  SizedBox(height: ThemeConfig.spacingL),
                  Text(
                    'No content available',
                    style: ThemeConfig.heading2.copyWith(
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
            ),
          );
        }

        final allContent = contentProvider.allContent;
        final movies = contentProvider.movies;
        final shows = contentProvider.shows;

        // Get featured content for banner (first item or random selection)
        final bannerContent = allContent.isNotEmpty ? allContent.first : null;

        // Filter content by categories
        final animeContent = _filterByKeywords(allContent, ['anime', 'one piece', 'naruto', 'dragon ball']);
        final musicContent = _filterByKeywords(allContent, ['music', 'concert']);
        final actionContent = _filterByKeywords(allContent, ['action', 'avengers', 'spider', 'batman']);
        final comedyContent = _filterByKeywords(allContent, ['comedy', 'friends', 'office']);

        // Recently added (last items in the list)
        final recentlyAdded = allContent.length > 10
            ? allContent.reversed.take(10).toList()
            : allContent;

        return Container(
          color: ThemeConfig.background,
          child: RefreshIndicator(
            onRefresh: () => contentProvider.fetchAllContent(),
            color: ThemeConfig.primary,
            backgroundColor: ThemeConfig.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Banner - Featured Content
                  if (bannerContent != null)
                    HeroBanner(
                      movie: bannerContent,
                      backdropUrl: contentProvider.getBackdropUrl(bannerContent.id),
                      onPlay: () => _playContent(bannerContent, contentProvider),
                      onInfo: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              content: bannerContent,
                              imageUrl: contentProvider.getImageUrl(bannerContent.id),
                              backdropUrl: contentProvider.getBackdropUrl(bannerContent.id),
                            ),
                          ),
                        );
                      },
                    ),

                  SizedBox(height: ThemeConfig.spacingXL),

                  // Continue Watching Section
                  ContinueWatchingRow(
                    apiService: contentProvider.apiService,
                  ),

                  SizedBox(height: ThemeConfig.spacingXL),

                  // Collections Section
                  CollectionsRow(
                    apiService: contentProvider.apiService,
                  ),

                  SizedBox(height: ThemeConfig.spacingXL),

                  // Trending Now
                  if (allContent.length > 10)
                    MovieRow(
                      title: 'Trending Now',
                      movies: allContent.sublist(0, 10),
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (content) =>
                          _playContent(content, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingL),

                  // Movies Section
                  if (movies.isNotEmpty)
                    MovieRow(
                      title: 'Movies',
                      movies: movies.take(15).toList(),
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (movie) =>
                          _playContent(movie, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingL),

                  // TV Shows Section
                  if (shows.isNotEmpty)
                    MovieRow(
                      title: 'TV Shows',
                      movies: shows.take(15).toList(),
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (show) =>
                          _playContent(show, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingL),

                  // Anime Section
                  if (animeContent.isNotEmpty)
                    MovieRow(
                      title: 'Anime',
                      movies: animeContent.take(15).toList(),
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (anime) =>
                          _playContent(anime, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingL),

                  // Music Videos Section
                  if (musicContent.isNotEmpty)
                    MovieRow(
                      title: 'Music Videos',
                      movies: musicContent.take(15).toList(),
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (music) =>
                          _playContent(music, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingL),

                  // Action Section
                  if (actionContent.isNotEmpty)
                    MovieRow(
                      title: 'Action & Adventure',
                      movies: actionContent.take(15).toList(),
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (content) =>
                          _playContent(content, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingL),

                  // Comedy Section
                  if (comedyContent.isNotEmpty)
                    MovieRow(
                      title: 'Comedy',
                      movies: comedyContent.take(15).toList(),
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (content) =>
                          _playContent(content, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingL),

                  // Recently Added Section
                  if (recentlyAdded.isNotEmpty)
                    MovieRow(
                      title: 'Recently Added',
                      movies: recentlyAdded,
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (content) =>
                          _playContent(content, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingL),

                  // Popular Section
                  if (allContent.length > 20)
                    MovieRow(
                      title: 'Popular on REY-Play',
                      movies: allContent.sublist(10, 20),
                      getImageUrl: contentProvider.getImageUrl,
                      onMovieTap: (content) =>
                          _playContent(content, contentProvider),
                    ),

                  SizedBox(height: ThemeConfig.spacingXXL),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
