import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'package:reyrazak/config/app_config.dart';
import 'movie_card.dart';

class MovieRow extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final String Function(String) getImageUrl;
  final Function(Movie) onMovieTap;

  const MovieRow({
    super.key,
    required this.title,
    required this.movies,
    required this.getImageUrl,
    required this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 16),
            child: Text(
              title,
              style: const TextStyle(
                color: ThemeConfig.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            height: 320,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              physics: const BouncingScrollPhysics(),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return MovieCard(
                  movie: movie,
                  imageUrl: getImageUrl(movie.id),
                  onTap: () => onMovieTap(movie),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
