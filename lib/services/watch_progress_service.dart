import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content.dart';

/// Watch Progress Service
///
/// Manages viewing history and playback progress for Continue Watching functionality.
/// Stores data locally using SharedPreferences.
class WatchProgressService {
  static const String _continueWatchingKey = 'continue_watching';
  static const String _watchHistoryKey = 'watch_history';
  static const int _maxContinueWatchingItems = 20;
  static const int _maxHistoryItems = 100;

  /// Get Continue Watching items
  Future<List<WatchProgress>> getContinueWatching() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_continueWatchingKey);

      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList
          .map((json) => WatchProgress.fromJson(json))
          .where((item) =>
              item.progress > 0.05 && item.progress < 0.95) // 5% to 95%
          .toList()
        ..sort((a, b) => b.lastWatched.compareTo(a.lastWatched));
    } catch (e) {
      print('Error loading continue watching: $e');
      return [];
    }
  }

  /// Save or update watch progress
  Future<void> saveWatchProgress({
    required String contentId,
    required String contentTitle,
    required ContentType contentType,
    required int positionTicks,
    required int runtimeTicks,
    String? posterUrl,
    String? seriesName,
    int? seasonNumber,
    int? episodeNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final continueWatching = await getContinueWatching();

      final progress = positionTicks / runtimeTicks;

      // Remove existing entry for this content
      continueWatching.removeWhere((item) => item.contentId == contentId);

      // Add new entry only if progress is between 5% and 95%
      if (progress > 0.05 && progress < 0.95) {
        continueWatching.insert(
          0,
          WatchProgress(
            contentId: contentId,
            contentTitle: contentTitle,
            contentType: contentType,
            positionTicks: positionTicks,
            runtimeTicks: runtimeTicks,
            progress: progress,
            lastWatched: DateTime.now(),
            posterUrl: posterUrl,
            seriesName: seriesName,
            seasonNumber: seasonNumber,
            episodeNumber: episodeNumber,
          ),
        );
      }

      // Keep only recent items
      if (continueWatching.length > _maxContinueWatchingItems) {
        continueWatching.removeRange(
          _maxContinueWatchingItems,
          continueWatching.length,
        );
      }

      // Save to storage
      final jsonList = continueWatching.map((item) => item.toJson()).toList();
      await prefs.setString(_continueWatchingKey, jsonEncode(jsonList));

      // Also save to watch history
      await _saveToHistory(
        contentId: contentId,
        contentTitle: contentTitle,
        contentType: contentType,
        progress: progress,
      );
    } catch (e) {
      print('Error saving watch progress: $e');
    }
  }

  /// Mark content as fully watched
  Future<void> markAsWatched(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final continueWatching = await getContinueWatching();

      // Remove from continue watching
      continueWatching.removeWhere((item) => item.contentId == contentId);

      final jsonList = continueWatching.map((item) => item.toJson()).toList();
      await prefs.setString(_continueWatchingKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error marking as watched: $e');
    }
  }

  /// Get watch progress for specific content
  Future<WatchProgress?> getProgressForContent(String contentId) async {
    final continueWatching = await getContinueWatching();
    try {
      return continueWatching.firstWhere((item) => item.contentId == contentId);
    } catch (e) {
      return null;
    }
  }

  /// Remove item from continue watching
  Future<void> removeFromContinueWatching(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final continueWatching = await getContinueWatching();

      continueWatching.removeWhere((item) => item.contentId == contentId);

      final jsonList = continueWatching.map((item) => item.toJson()).toList();
      await prefs.setString(_continueWatchingKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error removing from continue watching: $e');
    }
  }

  /// Clear all continue watching items
  Future<void> clearContinueWatching() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_continueWatchingKey);
    } catch (e) {
      print('Error clearing continue watching: $e');
    }
  }

  /// Get watch history
  Future<List<WatchHistoryItem>> getWatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_watchHistoryKey);

      if (data == null) return [];

      final List<dynamic> jsonList = jsonDecode(data);
      return jsonList
          .map((json) => WatchHistoryItem.fromJson(json))
          .toList()
        ..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    } catch (e) {
      print('Error loading watch history: $e');
      return [];
    }
  }

  /// Save to watch history
  Future<void> _saveToHistory({
    required String contentId,
    required String contentTitle,
    required ContentType contentType,
    required double progress,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getWatchHistory();

      // Remove existing entry
      history.removeWhere((item) => item.contentId == contentId);

      // Add new entry
      history.insert(
        0,
        WatchHistoryItem(
          contentId: contentId,
          contentTitle: contentTitle,
          contentType: contentType,
          watchedAt: DateTime.now(),
          progress: progress,
        ),
      );

      // Keep only recent items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      final jsonList = history.map((item) => item.toJson()).toList();
      await prefs.setString(_watchHistoryKey, jsonEncode(jsonList));
    } catch (e) {
      print('Error saving to history: $e');
    }
  }

  /// Clear watch history
  Future<void> clearWatchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_watchHistoryKey);
    } catch (e) {
      print('Error clearing watch history: $e');
    }
  }
}

/// Watch Progress Model
class WatchProgress {
  final String contentId;
  final String contentTitle;
  final ContentType contentType;
  final int positionTicks; // Current playback position
  final int runtimeTicks; // Total runtime
  final double progress; // 0.0 to 1.0
  final DateTime lastWatched;
  final String? posterUrl;

  // Episode-specific fields
  final String? seriesName;
  final int? seasonNumber;
  final int? episodeNumber;

  WatchProgress({
    required this.contentId,
    required this.contentTitle,
    required this.contentType,
    required this.positionTicks,
    required this.runtimeTicks,
    required this.progress,
    required this.lastWatched,
    this.posterUrl,
    this.seriesName,
    this.seasonNumber,
    this.episodeNumber,
  });

  /// Get position in minutes
  int get positionMinutes => (positionTicks / 10000000 / 60).round();

  /// Get runtime in minutes
  int get runtimeMinutes => (runtimeTicks / 10000000 / 60).round();

  /// Get remaining time in minutes
  int get remainingMinutes => runtimeMinutes - positionMinutes;

  /// Get formatted time remaining (e.g., "45 min left")
  String get timeRemainingFormatted {
    if (remainingMinutes < 1) return 'Almost done';
    if (remainingMinutes < 60) return '$remainingMinutes min left';

    final hours = remainingMinutes ~/ 60;
    final mins = remainingMinutes % 60;
    if (mins == 0) return '${hours}h left';
    return '${hours}h ${mins}m left';
  }

  /// Get display title (includes episode info for series)
  String get displayTitle {
    if (contentType == ContentType.episode && seriesName != null) {
      final episodeInfo = seasonNumber != null && episodeNumber != null
          ? 'S$seasonNumber:E$episodeNumber'
          : '';
      return '$seriesName ${episodeInfo.isNotEmpty ? '- $episodeInfo' : ''}';
    }
    return contentTitle;
  }

  factory WatchProgress.fromJson(Map<String, dynamic> json) {
    return WatchProgress(
      contentId: json['contentId'],
      contentTitle: json['contentTitle'],
      contentType: ContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => ContentType.unknown,
      ),
      positionTicks: json['positionTicks'],
      runtimeTicks: json['runtimeTicks'],
      progress: json['progress'],
      lastWatched: DateTime.parse(json['lastWatched']),
      posterUrl: json['posterUrl'],
      seriesName: json['seriesName'],
      seasonNumber: json['seasonNumber'],
      episodeNumber: json['episodeNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'contentTitle': contentTitle,
      'contentType': contentType.name,
      'positionTicks': positionTicks,
      'runtimeTicks': runtimeTicks,
      'progress': progress,
      'lastWatched': lastWatched.toIso8601String(),
      'posterUrl': posterUrl,
      'seriesName': seriesName,
      'seasonNumber': seasonNumber,
      'episodeNumber': episodeNumber,
    };
  }
}

/// Watch History Item
class WatchHistoryItem {
  final String contentId;
  final String contentTitle;
  final ContentType contentType;
  final DateTime watchedAt;
  final double progress;

  WatchHistoryItem({
    required this.contentId,
    required this.contentTitle,
    required this.contentType,
    required this.watchedAt,
    required this.progress,
  });

  factory WatchHistoryItem.fromJson(Map<String, dynamic> json) {
    return WatchHistoryItem(
      contentId: json['contentId'],
      contentTitle: json['contentTitle'],
      contentType: ContentType.values.firstWhere(
        (e) => e.name == json['contentType'],
        orElse: () => ContentType.unknown,
      ),
      watchedAt: DateTime.parse(json['watchedAt']),
      progress: json['progress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentId': contentId,
      'contentTitle': contentTitle,
      'contentType': contentType.name,
      'watchedAt': watchedAt.toIso8601String(),
      'progress': progress,
    };
  }
}
