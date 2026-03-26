import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';
import '../models/movie.dart';
import '../widgets/movie_row.dart';
import '../widgets/hero_banner.dart';
import 'package:reyrazak/config/app_config.dart';
import 'video_player_screen.dart';
import 'detail_screen.dart';

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

  void _playContent(Movie content, ContentProvider provider, {bool isSeries = false}) {
    if (isSeries) {
      // Navigate to detail screen for TV shows
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
      // Navigate directly to player for movies
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            movie: content,
            streamUrl: provider.getStreamUrl(content.id),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentProvider>(
      builder: (context, contentProvider, child) {
        if (contentProvider.isLoading) {
          return Container(
            color: ThemeConfig.background,
            child: const Center(
              child: CircularProgressIndicator(color: ThemeConfig.primary),
            ),
          );
        }

        if (contentProvider.errorMessage != null) {
          return Container(
            color: ThemeConfig.background,
            child: Center(
              child: Text(
                contentProvider.errorMessage!,
                style: const TextStyle(color: ThemeConfig.primary),
              ),
            ),
          );
        }

        if (contentProvider.allContent.isEmpty) {
          return Container(
            color: ThemeConfig.background,
            child: const Center(
              child: Text(
                'No content available',
                style: TextStyle(color: ThemeConfig.textPrimary, fontSize: 18),
              ),
            ),
          );
        }

        final allContent = contentProvider.allContent;
        final movies = contentProvider.movies;
        final shows = contentProvider.shows;
        final bannerContent = allContent.isNotEmpty ? allContent.first : null;

        return Container(
          color: ThemeConfig.background,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bannerContent != null)
                  HeroBanner(
                    movie: bannerContent,
                    backdropUrl: contentProvider.getBackdropUrl(bannerContent.id),
                    onPlay: () => _playContent(bannerContent, contentProvider),
                    onInfo: () {},
                  ),
                const SizedBox(height: 24),
                if (movies.isNotEmpty)
                  MovieRow(
                    title: 'Movies',
                    movies: movies,
                    getImageUrl: contentProvider.getImageUrl,
                    onMovieTap: (movie) => _playContent(movie, contentProvider),
                  ),
                if (shows.isNotEmpty)
                  MovieRow(
                    title: 'TV Shows',
                    movies: shows,
                    getImageUrl: contentProvider.getImageUrl,
                    onMovieTap: (show) => _playContent(show, contentProvider, isSeries: true),
                  ),
                if (allContent.length > 10)
                  MovieRow(
                    title: 'Trending Now',
                    movies: allContent.sublist(0, 10),
                    getImageUrl: contentProvider.getImageUrl,
                    onMovieTap: (content) => _playContent(content, contentProvider),
                  ),
                if (allContent.length > 20)
                  MovieRow(
                    title: 'Popular',
                    movies: allContent.sublist(10, 20),
                    getImageUrl: contentProvider.getImageUrl,
                    onMovieTap: (content) => _playContent(content, contentProvider),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
