import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reyrazak/config/app_config.dart';
import '../models/movie.dart';
import '../services/cms_service.dart';
import '../providers/content_provider.dart';

class CmsEditScreen extends StatefulWidget {
  final Movie movie;

  const CmsEditScreen({super.key, required this.movie});

  @override
  State<CmsEditScreen> createState() => _CmsEditScreenState();
}

class _CmsEditScreenState extends State<CmsEditScreen> {
  late final TextEditingController _posterCtrl;
  late final TextEditingController _backdropCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _badgeCtrl;

  // Live-preview URLs (updated as user types)
  String _previewPoster = '';
  String _previewBackdrop = '';

  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    final cms = context.read<CmsService>();
    final content = context.read<ContentProvider>();
    final override = cms.getOverride(widget.movie.id);

    _posterCtrl = TextEditingController(text: override?.customPosterUrl ?? '');
    _backdropCtrl =
        TextEditingController(text: override?.customBackdropUrl ?? '');
    _titleCtrl = TextEditingController(text: override?.customTitle ?? '');
    _descCtrl =
        TextEditingController(text: override?.customDescription ?? '');
    _badgeCtrl = TextEditingController(text: override?.badgeLabel ?? '');

    // Seed previews — fall back to what ContentProvider resolves
    _previewPoster = override?.customPosterUrl?.isNotEmpty == true
        ? override!.customPosterUrl!
        : content.getImageUrl(widget.movie.id);
    _previewBackdrop = override?.customBackdropUrl?.isNotEmpty == true
        ? override!.customBackdropUrl!
        : content.getBackdropUrl(widget.movie.id);

    _posterCtrl.addListener(_onChanged);
    _backdropCtrl.addListener(_onChanged);
    _titleCtrl.addListener(_onChanged);
    _descCtrl.addListener(_onChanged);
    _badgeCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    setState(() {
      _dirty = true;
      if (_posterCtrl.text.trim().isNotEmpty) {
        _previewPoster = _posterCtrl.text.trim();
      }
      if (_backdropCtrl.text.trim().isNotEmpty) {
        _previewBackdrop = _backdropCtrl.text.trim();
      }
    });
  }

  @override
  void dispose() {
    _posterCtrl.dispose();
    _backdropCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final cms = context.read<CmsService>();
    final existing = cms.getOverride(widget.movie.id);

    final updated = CmsOverride(
      contentId: widget.movie.id,
      contentTitle: widget.movie.title,
      customPosterUrl: _posterCtrl.text.trim().isEmpty
          ? null
          : _posterCtrl.text.trim(),
      customBackdropUrl: _backdropCtrl.text.trim().isEmpty
          ? null
          : _backdropCtrl.text.trim(),
      customTitle: _titleCtrl.text.trim().isEmpty
          ? null
          : _titleCtrl.text.trim(),
      customDescription: _descCtrl.text.trim().isEmpty
          ? null
          : _descCtrl.text.trim(),
      badgeLabel: _badgeCtrl.text.trim().isEmpty
          ? null
          : _badgeCtrl.text.trim(),
      updatedAt: existing?.updatedAt ?? DateTime.now(),
    );

    await cms.saveOverride(updated);
    if (mounted) {
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Saved'),
          backgroundColor: ThemeConfig.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ThemeConfig.surface,
        title: const Text('Reset overrides?',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'All custom metadata for "${widget.movie.title}" will be removed.',
          style:
              TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
            child: const Text('Reset',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final cms = context.read<CmsService>();
    final content = context.read<ContentProvider>();
    await cms.clearOverride(widget.movie.id);

    if (mounted) {
      _posterCtrl.text = '';
      _backdropCtrl.text = '';
      _titleCtrl.text = '';
      _descCtrl.text = '';
      _badgeCtrl.text = '';
      setState(() {
        _dirty = false;
        _previewPoster = content.getImageUrl(widget.movie.id);
        _previewBackdrop = content.getBackdropUrl(widget.movie.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Overrides cleared'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewSection(),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Images',
              children: [
                _buildField(
                  controller: _posterCtrl,
                  label: 'Custom Poster URL',
                  hint: 'https://…',
                  icon: Icons.image_outlined,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _backdropCtrl,
                  label: 'Custom Backdrop URL',
                  hint: 'https://…',
                  icon: Icons.wallpaper_rounded,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Text',
              children: [
                _buildField(
                  controller: _titleCtrl,
                  label: 'Custom Title',
                  hint: widget.movie.title,
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _descCtrl,
                  label: 'Custom Description',
                  hint: 'Enter an alternate synopsis…',
                  icon: Icons.notes_rounded,
                  maxLines: 4,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              title: 'Badge',
              children: [
                _buildField(
                  controller: _badgeCtrl,
                  label: 'Badge Label',
                  hint: 'e.g. NEW · 4K · EXCLUSIVE',
                  icon: Icons.label_rounded,
                ),
                const SizedBox(height: 8),
                _buildBadgePresets(),
              ],
            ),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    final cms = context.read<CmsService>();
    final hasOverride =
        cms.getOverride(widget.movie.id)?.hasAnyOverride == true;

    return AppBar(
      backgroundColor: ThemeConfig.background,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Edit Metadata',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          Text(
            widget.movie.title,
            style: TextStyle(
                fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        if (hasOverride)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Reset overrides',
            onPressed: _reset,
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

  Widget _buildPreviewSection() {
    final displayTitle = _titleCtrl.text.trim().isNotEmpty
        ? _titleCtrl.text.trim()
        : widget.movie.title;
    final badge =
        _badgeCtrl.text.trim().isNotEmpty ? _badgeCtrl.text.trim() : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Backdrop preview
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: Image.network(
                _previewBackdrop,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: ThemeConfig.surface,
                  child: Icon(Icons.wallpaper_rounded,
                      color: Colors.white.withValues(alpha: 0.15), size: 48),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    child: AspectRatio(
                      aspectRatio: 2 / 3,
                      child: Image.network(
                        _previewPoster,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.5)),
                              ),
                              child: Text(badge,
                                  style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live Preview',
                        style: TextStyle(
                          color: ThemeConfig.primary.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      cursorColor: ThemeConfig.primary,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 13),
        prefixIcon: Icon(icon,
            color: Colors.white.withValues(alpha: 0.3), size: 18),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ThemeConfig.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBadgePresets() {
    const presets = ['NEW', '4K', 'EXCLUSIVE', 'LIVE', 'PREMIERE', 'HD'];
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: presets.map((p) {
        final selected = _badgeCtrl.text.trim() == p;
        return GestureDetector(
          onTap: () {
            setState(() {
              _badgeCtrl.text = selected ? '' : p;
              _dirty = true;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.amber.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: selected
                    ? Colors.amber.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              p,
              style: TextStyle(
                color: selected ? Colors.amber : Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _reset,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: BorderSide(
                  color: Colors.redAccent.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _dirty ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primary,
              disabledBackgroundColor:
                  ThemeConfig.primary.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Save Changes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
