import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../utils/colors.dart';

class HeroBanner extends StatelessWidget {
  final Movie movie;
  final String backdropUrl;
  final VoidCallback onPlay;
  final VoidCallback onInfo;

  const HeroBanner({
    super.key,
    required this.movie,
    required this.backdropUrl,
    required this.onPlay,
    required this.onInfo,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Stack(
        children: [
          // Backdrop Image
          Positioned.fill(
            child: Image.network(
              backdropUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  child: const Icon(
                    Icons.movie,
                    color: AppColors.textSecondary,
                    size: 100,
                  ),
                );
              },
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.3),
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),
          // Content
          Positioned(
            bottom: 80,
            left: 40,
            right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.play_arrow,
                      label: 'Play',
                      onPressed: onPlay,
                      isPrimary: true,
                    ),
                    const SizedBox(width: 16),
                    _ActionButton(
                      icon: Icons.info_outline,
                      label: 'More Info',
                      onPressed: onInfo,
                      isPrimary: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton.icon(
          onPressed: widget.onPressed,
          icon: Icon(widget.icon, size: 28),
          label: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isPrimary
                ? AppColors.textPrimary
                : AppColors.surface.withOpacity(0.8),
            foregroundColor: widget.isPrimary
                ? AppColors.background
                : AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: _isHovered ? 8 : 2,
          ),
        ),
      ),
    );
  }
}
