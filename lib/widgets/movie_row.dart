import 'package:flutter/material.dart';
import '../models/movie.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 270,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
    );
  }
}
