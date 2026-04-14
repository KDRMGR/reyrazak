import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reyrazak/config/app_config.dart';
import '../providers/content_provider.dart';
import '../models/movie.dart';
import '../services/cms_service.dart';
import 'cms_edit_screen.dart';

class CmsScreen extends StatefulWidget {
  const CmsScreen({super.key});

  @override
  State<CmsScreen> createState() => _CmsScreenState();
}

class _CmsScreenState extends State<CmsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _filter = 'All'; // All | Overridden | Movies | TV Shows | Music

  static const List<String> _filters = [
    'All',
    'Overridden',
    'Movies',
    'TV Shows',
    'Music',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
        () => setState(() => _query = _searchController.text.trim()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Movie> _applyFilter(List<Movie> all, CmsService cms) {
    var list = all;

    switch (_filter) {
      case 'Overridden':
        list = list.where((m) => cms.getOverride(m.id)?.hasAnyOverride == true).toList();
        break;
      case 'Movies':
        list = list.where((m) => m.isMovie).toList();
        break;
      case 'TV Shows':
        list = list.where((m) => m.isSeries).toList();
        break;
      case 'Music':
        list = list.where((m) => m.isMusicVideo).toList();
        break;
    }

    if (_query.isNotEmpty) {
      list = list
          .where((m) => m.title.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ContentProvider, CmsService>(
      builder: (context, content, cms, _) {
        final items = _applyFilter(content.allContent, cms);

        return Scaffold(
          backgroundColor: ThemeConfig.background,
          appBar: _buildAppBar(cms),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildFilterChips(),
              _buildStatsBar(content.allContent.length, cms.overrideCount),
              Expanded(
                child: content.isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            color: ThemeConfig.primary))
                    : items.isEmpty
                        ? _buildEmpty()
                        : _buildList(items, cms),
              ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(CmsService cms) {
    return AppBar(
      backgroundColor: ThemeConfig.background,
      foregroundColor: Colors.white,
      title: const Text(
        'Content Manager',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        if (cms.overrideCount > 0)
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear all overrides',
            onPressed: () => _confirmClearAll(cms),
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.white.withValues(alpha: 0.06)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: ThemeConfig.primary,
        decoration: InputDecoration(
          hintText: 'Search content…',
          hintStyle:
              TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.35), size: 20),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: Colors.white.withValues(alpha: 0.4), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.06),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: ThemeConfig.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        itemCount: _filters.length,
        itemBuilder: (_, i) {
          final f = _filters[i];
          final selected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? ThemeConfig.primary
                      : Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? ThemeConfig.primary
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsBar(int total, int overridden) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          _stat('Total Items', '$total', Icons.movie_filter_outlined),
          const SizedBox(width: 24),
          _stat(
            'Overridden',
            '$overridden',
            Icons.edit_note_rounded,
            highlight: overridden > 0,
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon,
      {bool highlight = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 16,
            color: highlight
                ? ThemeConfig.primary
                : Colors.white.withValues(alpha: 0.4)),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: highlight ? ThemeConfig.primary : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildList(List<Movie> items, CmsService cms) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: items.length,
      itemBuilder: (_, i) => _CmsListTile(
        movie: items[i],
        cms: cms,
        onTap: () => _openEditor(items[i]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 64, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            _query.isNotEmpty
                ? 'No results for "$_query"'
                : 'No content in this category',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _openEditor(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CmsEditScreen(movie: movie)),
    );
  }

  Future<void> _confirmClearAll(CmsService cms) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeConfig.surface,
        title: const Text('Clear all overrides?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'This will remove all ${cms.overrideCount} custom poster, backdrop, '
          'title and description overrides.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear all',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) cms.clearAll();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// List tile
// ─────────────────────────────────────────────────────────────────────────────

class _CmsListTile extends StatelessWidget {
  final Movie movie;
  final CmsService cms;
  final VoidCallback onTap;

  const _CmsListTile({
    required this.movie,
    required this.cms,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final override = cms.getOverride(movie.id);
    final hasOverride = override?.hasAnyOverride == true;
    final content = Provider.of<ContentProvider>(context, listen: false);

    final posterUrl = cms.effectivePosterUrl(movie.id, content.getImageUrl(movie.id));
    final displayTitle =
        cms.effectiveTitle(movie.id, movie.title);
    final badge = cms.badgeLabel(movie.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: hasOverride ? 0.07 : 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasOverride
                ? ThemeConfig.primary.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          children: [
            // Poster thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: SizedBox(
                  width: 52,
                  child: Image.network(
                    posterUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: ThemeConfig.surface,
                      child: Icon(Icons.movie_outlined,
                          color: Colors.white.withValues(alpha: 0.2),
                          size: 24),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Title + type
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _TypeChip(movie: movie),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        _BadgeChip(label: badge),
                      ],
                    ],
                  ),
                  if (hasOverride) ...[
                    const SizedBox(height: 5),
                    _OverrideSummary(cmsOverride: override!),
                  ],
                ],
              ),
            ),

            // Edit arrow
            Icon(
              Icons.chevron_right_rounded,
              color: hasOverride
                  ? ThemeConfig.primary
                  : Colors.white.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final Movie movie;
  const _TypeChip({required this.movie});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;
    if (movie.isSeries) {
      label = 'TV';
      color = Colors.blue;
    } else if (movie.isMusicVideo) {
      label = 'Music';
      color = Colors.green;
    } else {
      label = 'Movie';
      color = ThemeConfig.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  const _BadgeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.amber, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _OverrideSummary extends StatelessWidget {
  final CmsOverride cmsOverride;
  const _OverrideSummary({required this.cmsOverride});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (cmsOverride.customPosterUrl?.isNotEmpty == true) parts.add('Poster');
    if (cmsOverride.customBackdropUrl?.isNotEmpty == true) parts.add('Backdrop');
    if (cmsOverride.customTitle?.isNotEmpty == true) parts.add('Title');
    if (cmsOverride.customDescription?.isNotEmpty == true) parts.add('Desc');
    if (cmsOverride.badgeLabel?.isNotEmpty == true) parts.add('Badge');

    return Row(
      children: [
        Icon(Icons.edit_rounded,
            size: 11, color: ThemeConfig.primary.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Text(
          parts.join(' · '),
          style: TextStyle(
            color: ThemeConfig.primary.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
