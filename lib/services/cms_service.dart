import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class CmsOverride {
  final String contentId;
  final String contentTitle; // snapshot for display in the CMS list
  final String? customPosterUrl;
  final String? customBackdropUrl;
  final String? customTitle;
  final String? customDescription;
  final String? badgeLabel; // e.g. "NEW", "4K", "EXCLUSIVE"
  final DateTime updatedAt;

  const CmsOverride({
    required this.contentId,
    required this.contentTitle,
    this.customPosterUrl,
    this.customBackdropUrl,
    this.customTitle,
    this.customDescription,
    this.badgeLabel,
    required this.updatedAt,
  });

  /// True if at least one field carries a real override value.
  bool get hasAnyOverride =>
      (customPosterUrl?.isNotEmpty ?? false) ||
      (customBackdropUrl?.isNotEmpty ?? false) ||
      (customTitle?.isNotEmpty ?? false) ||
      (customDescription?.isNotEmpty ?? false) ||
      (badgeLabel?.isNotEmpty ?? false);

  CmsOverride copyWith({
    String? contentTitle,
    String? customPosterUrl,
    String? customBackdropUrl,
    String? customTitle,
    String? customDescription,
    String? badgeLabel,
  }) {
    return CmsOverride(
      contentId: contentId,
      contentTitle: contentTitle ?? this.contentTitle,
      customPosterUrl: customPosterUrl ?? this.customPosterUrl,
      customBackdropUrl: customBackdropUrl ?? this.customBackdropUrl,
      customTitle: customTitle ?? this.customTitle,
      customDescription: customDescription ?? this.customDescription,
      badgeLabel: badgeLabel ?? this.badgeLabel,
      updatedAt: DateTime.now(),
    );
  }

  factory CmsOverride.fromJson(Map<String, dynamic> j) => CmsOverride(
        contentId: j['contentId'] as String,
        contentTitle: j['contentTitle'] as String? ?? '',
        customPosterUrl: j['customPosterUrl'] as String?,
        customBackdropUrl: j['customBackdropUrl'] as String?,
        customTitle: j['customTitle'] as String?,
        customDescription: j['customDescription'] as String?,
        badgeLabel: j['badgeLabel'] as String?,
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'contentId': contentId,
        'contentTitle': contentTitle,
        'customPosterUrl': customPosterUrl,
        'customBackdropUrl': customBackdropUrl,
        'customTitle': customTitle,
        'customDescription': customDescription,
        'badgeLabel': badgeLabel,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────

class CmsService extends ChangeNotifier {
  static const String _storageKey = 'cms_overrides_v1';

  // In-memory map loaded once at startup — lookups are O(1) and synchronous.
  final Map<String, CmsOverride> _overrides = {};

  List<CmsOverride> get allOverrides =>
      _overrides.values.toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  int get overrideCount => _overrides.length;

  // ── Initialise ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        for (final item in list) {
          final o = CmsOverride.fromJson(item as Map<String, dynamic>);
          _overrides[o.contentId] = o;
        }
        debugPrint('✅ CmsService: loaded ${_overrides.length} overrides');
      }
    } catch (e) {
      debugPrint('CmsService init error: $e');
    }
  }

  // ── Synchronous resolution (used by ContentProvider) ──────────────────────

  /// Returns the custom poster URL if one has been set, otherwise [fallback].
  String effectivePosterUrl(String contentId, String fallback) {
    final url = _overrides[contentId]?.customPosterUrl;
    return (url != null && url.isNotEmpty) ? url : fallback;
  }

  /// Returns the custom backdrop URL if one has been set, otherwise [fallback].
  String effectiveBackdropUrl(String contentId, String fallback) {
    final url = _overrides[contentId]?.customBackdropUrl;
    return (url != null && url.isNotEmpty) ? url : fallback;
  }

  /// Returns the custom title if one has been set, otherwise [fallback].
  String effectiveTitle(String contentId, String fallback) {
    final title = _overrides[contentId]?.customTitle;
    return (title != null && title.isNotEmpty) ? title : fallback;
  }

  /// Returns the badge label for this item (or null if none).
  String? badgeLabel(String contentId) =>
      _overrides[contentId]?.badgeLabel?.isNotEmpty == true
          ? _overrides[contentId]!.badgeLabel
          : null;

  CmsOverride? getOverride(String contentId) => _overrides[contentId];

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> saveOverride(CmsOverride override) async {
    _overrides[override.contentId] = override;
    notifyListeners();
    await _persist();
  }

  Future<void> clearOverride(String contentId) async {
    _overrides.remove(contentId);
    notifyListeners();
    await _persist();
  }

  Future<void> clearAll() async {
    _overrides.clear();
    notifyListeners();
    await _persist();
  }

  // ── Persistence ───────────────────────────────────────────────────────────

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _overrides.values.map((o) => o.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (e) {
      debugPrint('CmsService persist error: $e');
    }
  }
}
