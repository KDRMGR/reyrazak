import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'package:reyrazak/config/app_config.dart';

class MovieCard extends StatefulWidget {
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
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 180,
          margin: const EdgeInsets.only(right: 12),
          transform: Matrix4.identity()..scale(_isHovered ? 1.08 : 1.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.imageUrl,
                    width: 180,
                    height: 270,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 180,
                        height: 270,
                        color: ThemeConfig.surface,
                        child: const Icon(
                          Icons.movie,
                          color: ThemeConfig.textSecondary,
                          size: 60,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.movie.title,
                  style: TextStyle(
                    color: _isHovered ? ThemeConfig.textPrimary : ThemeConfig.textSecondary,
                    fontSize: 14,
                    fontWeight: _isHovered ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
