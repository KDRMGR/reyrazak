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
      final seasons =
          await authService.apiService.fetchSeasons(widget.content.id);
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
      debugPrint('Error loading episodes: $e');
    }
  }

  void _playEpisode(String episodeId, String episodeTitle) {
    final authService = Provider.of<AuthService>(context, listen: false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UniversalPlayerScreen(
          movie: Movie(id: episodeId, title: episodeTitle),
          streamUrl: authService.apiService.getStreamUrl(episodeId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // ── Full-screen backdrop ────────────────────────────────────────
          Positioned.fill(
            child: Image.network(
              // Prefer the wide backdrop; fall back to the poster
              widget.backdropUrl.isNotEmpty
                  ? widget.backdropUrl
                  : widget.imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) =>
                  Container(color: ThemeConfig.background),
            ),
          ),

          // ── Gradient overlay: transparent top → opaque bottom ──────────
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 0.65, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                    ThemeConfig.background.withValues(alpha: 0.88),
                    ThemeConfig.background,
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable content ─────────────────────────────────────────
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Show title in the space under the transparent app bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 220, 20, 0),
                    child: Text(
                      widget.content.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: ThemeConfig.primary),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: ThemeConfig.primary),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_seasons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No seasons available',
            style: TextStyle(color: ThemeConfig.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Season selector label
        const Text(
          'Seasons',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Season chips
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _seasons.length,
            itemBuilder: (context, index) {
              final season = _seasons[index];
              final isSelected = _selectedSeasonIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() => _selectedSeasonIndex = index);
                    _loadEpisodes(season['Id']);
                  },
                  child: AnimatedContainer(
                    duration: ThemeConfig.animationFast,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ThemeConfig.primary
                          : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? ThemeConfig.primary
                            : Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      season['Name'] ?? 'Season ${index + 1}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.75),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        if (_selectedSeasonIndex != null) ...[
          const Text(
            'Episodes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildEpisodesList(),
        ],
      ],
    );
  }

  Widget _buildEpisodesList() {
    final seasonId = _seasons[_selectedSeasonIndex!]['Id'];
    final episodes = _episodes[seasonId];

    if (episodes == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: ThemeConfig.primary),
        ),
      );
    }

    if (episodes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No episodes available',
              style: TextStyle(color: ThemeConfig.textSecondary)),
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
          borderRadius: BorderRadius.circular(10),
          onTap: () => _playEpisode(episode['Id'], episodeName),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              // Glass-card feel on top of the full-bleed backdrop
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Episode thumbnail
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                  child: SizedBox(
                    width: 150,
                    height: 90,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (episode['Id'] != null)
                          Image.network(
                            '${ApiService.baseUrl}/Items/${episode['Id']}/Images/Primary',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: ThemeConfig.background),
                          ),
                        Container(
                            color: Colors.black.withValues(alpha: 0.3)),
                        const Center(
                          child: Icon(Icons.play_circle_outline,
                              color: Colors.white, size: 38),
                        ),
                      ],
                    ),
                  ),
                ),

                // Episode info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$episodeNumber. ',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                episodeName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
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
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (overview.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            overview,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
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
