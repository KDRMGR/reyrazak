import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';
import '../widgets/movie_row.dart';
import 'player_screen.dart';

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
      Provider.of<MovieProvider>(context, listen: false).fetchMovies();
    });
  }

  void _playMovie(Movie movie, MovieProvider provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerScreen(
          movie: movie,
          streamUrl: provider.getStreamUrl(movie.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'REYRAZAK',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          if (movieProvider.errorMessage != null) {
            return Center(
              child: Text(
                movieProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (movieProvider.movies.isEmpty) {
            return const Center(
              child: Text(
                'No movies available',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final movies = movieProvider.movies;
          final bannerMovie = movies.isNotEmpty ? movies.first : null;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (bannerMovie != null)
                  GestureDetector(
                    onTap: () => _playMovie(bannerMovie, movieProvider),
                    child: Stack(
                      children: [
                        Image.network(
                          movieProvider.getImageUrl(bannerMovie.id),
                          width: double.infinity,
                          height: 400,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 400,
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.movie,
                                color: Colors.grey,
                                size: 100,
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black,
                                  Colors.black.withOpacity(0.0),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bannerMovie.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => _playMovie(bannerMovie, movieProvider),
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Play'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                MovieRow(
                  title: 'All Movies',
                  movies: movies,
                  getImageUrl: movieProvider.getImageUrl,
                  onMovieTap: (movie) => _playMovie(movie, movieProvider),
                ),
                const SizedBox(height: 24),
                if (movies.length > 10)
                  MovieRow(
                    title: 'Continue Watching',
                    movies: movies.sublist(0, 10),
                    getImageUrl: movieProvider.getImageUrl,
                    onMovieTap: (movie) => _playMovie(movie, movieProvider),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
