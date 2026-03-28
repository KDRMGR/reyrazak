import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import 'package:reyrazak/config/app_config.dart';
import 'universal_player_screen.dart';

class DetailScreen extends StatefulWidget {
  final Movie content;
  final String imageUrl;
  final String backdropUrl;

  const DetailScreen({
    super.key,
    required this.content,
    required this.imageUrl,
    required this.backdropUrl,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = true;
  List<dynamic> _seasons = [];
  Map<String, List<dynamic>> _episodes = {};
  int? _selectedSeasonIndex;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final seasons = await authService.apiService.fetchSeasons(widget.content.id);
      setState(() {
        _seasons = seasons;
        _isLoading = false;
        if (_seasons.isNotEmpty) {
          _selectedSeasonIndex = 0;
          _loadEpisodes(_seasons[0]['Id']);
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadEpisodes(String seasonId) async {
    if (_episodes.containsKey(seasonId)) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final episodes = await authService.apiService.fetchEpisodes(seasonId);
      setState(() {
        _episodes[seasonId] = episodes;
      });
    } catch (e) {
      print('Error loading episodes: $e');
    }
  }

  void _playEpisode(String episodeId, String episodeTitle) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final streamUrl = authService.apiService.getStreamUrl(episodeId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversalPlayerScreen(
          movie: Movie(id: episodeId, title: episodeTitle),
          streamUrl: streamUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: ThemeConfig.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.backdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: ThemeConfig.surface);
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          ThemeConfig.background.withOpacity(0.7),
                          ThemeConfig.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.content.title,
                    style: const TextStyle(
                      color: ThemeConfig.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: ThemeConfig.primary),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: ThemeConfig.primary),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else if (_seasons.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No seasons available',
                          style: TextStyle(color: ThemeConfig.textSecondary),
                        ),
                      ),
                    )
                  else ...[
                    // Season selector
                    const Text(
                      'Seasons',
                      style: TextStyle(
                        color: ThemeConfig.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _seasons.length,
                        itemBuilder: (context, index) {
                          final season = _seasons[index];
                          final isSelected = _selectedSeasonIndex == index;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedSeasonIndex = index;
                                });
                                _loadEpisodes(season['Id']);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                    ? ThemeConfig.primary
                                    : ThemeConfig.surface,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    season['Name'] ?? 'Season ${index + 1}',
                                    style: TextStyle(
                                      color: isSelected
                                        ? ThemeConfig.textPrimary
                                        : ThemeConfig.textSecondary,
                                      fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Episodes list
                    if (_selectedSeasonIndex != null) ...[
                      const Text(
                        'Episodes',
                        style: TextStyle(
                          color: ThemeConfig.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildEpisodesList(),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesList() {
    final seasonId = _seasons[_selectedSeasonIndex!]['Id'];
    final episodes = _episodes[seasonId];

    if (episodes == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(color: ThemeConfig.primary),
        ),
      );
    }

    if (episodes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No episodes available',
            style: TextStyle(color: ThemeConfig.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final episodeNumber = episode['IndexNumber'] ?? (index + 1);
        final episodeName = episode['Name'] ?? 'Episode $episodeNumber';
        final overview = episode['Overview'] ?? '';
        final runtime = episode['RunTimeTicks'] != null
            ? '${(episode['RunTimeTicks'] / 600000000).round()} min'
            : '';

        return InkWell(
          onTap: () => _playEpisode(episode['Id'], episodeName),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: ThemeConfig.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Episode thumbnail
                Container(
                  width: 150,
                  height: 90,
                  decoration: BoxDecoration(
                    color: ThemeConfig.background,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (episode['Id'] != null)
                        Image.network(
                          '${ApiService.baseUrl}/Items/${episode['Id']}/Images/Primary',
                          fit: BoxFit.cover,
                          width: 150,
                          height: 90,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: ThemeConfig.background);
                          },
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 40,
                      ),
                    ],
                  ),
                ),

                // Episode info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$episodeNumber.',
                              style: const TextStyle(
                                color: ThemeConfig.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                episodeName,
                                style: const TextStyle(
                                  color: ThemeConfig.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (runtime.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            runtime,
                            style: const TextStyle(
                              color: ThemeConfig.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (overview.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            overview,
                            style: const TextStyle(
                              color: ThemeConfig.textSecondary,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
