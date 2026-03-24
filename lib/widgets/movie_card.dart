import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final String imageUrl;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                imageUrl,
                width: 150,
                height: 225,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 225,
                    color: Colors.grey[900],
                    child: const Icon(
                      Icons.movie,
                      color: Colors.grey,
                      size: 50,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
