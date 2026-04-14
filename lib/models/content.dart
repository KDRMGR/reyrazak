/// Content Model - Supports Movies, Series, Anime, Music Videos, and Collections
///
/// This enhanced model replaces the simple Movie model and includes
/// all metadata needed for a modern OTT platform.
class Content {
  // Basic Information
  final String id;
  final String title;
  final String? overview;
  final ContentType type;

  // Media URLs
  final String? posterUrl;
  final String? backdropUrl;
  final String? logoUrl;
  final String? trailerUrl;

  // Metadata
  final int? productionYear;
  final String? premiereDate;
  final double? communityRating;
  final String? officialRating; // PG, PG-13, R, etc.
  final List<String> genres;
  final List<String> tags;
  final int? runTimeTicks;

  // Series/Season Information
  final int? seasonCount;
  final int? episodeCount;
  final int? indexNumber; // Episode or Season number
  final String? seriesId;
  final String? seasonId;
  final String? seriesName;

  // Collection Information
  final String? collectionType;
  final int? childCount;

  // People
  final List<Person> people;

  // Media Info
  final String? container; // mkv, mp4, etc.
  final int? bitrate;
  final List<MediaStream> mediaStreams;

  // User Data
  final UserData? userData;

  // Additional Properties
  final String? sortName;
  final DateTime? dateCreated;
  final bool canDelete;
  final bool canDownload;

  Content({
    required this.id,
    required this.title,
    required this.type,
    this.overview,
    this.posterUrl,
    this.backdropUrl,
    this.logoUrl,
    this.trailerUrl,
    this.productionYear,
    this.premiereDate,
    this.communityRating,
    this.officialRating,
    this.genres = const [],
    this.tags = const [],
    this.runTimeTicks,
    this.seasonCount,
    this.episodeCount,
    this.indexNumber,
    this.seriesId,
    this.seasonId,
    this.seriesName,
    this.collectionType,
    this.childCount,
    this.people = const [],
    this.container,
    this.bitrate,
    this.mediaStreams = const [],
    this.userData,
    this.sortName,
    this.dateCreated,
    this.canDelete = false,
    this.canDownload = true,
  });

  /// Get runtime in minutes
  int? get runtimeMinutes {
    if (runTimeTicks == null) return null;
    return (runTimeTicks! / 10000000 / 60).round();
  }

  /// Get runtime as formatted string (e.g., "2h 15m")
  String? get runtimeFormatted {
    final minutes = runtimeMinutes;
    if (minutes == null) return null;

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${mins}m';
  }

  /// Check if content is a movie
  bool get isMovie => type == ContentType.movie;

  /// Check if content is a series
  bool get isSeries => type == ContentType.series;

  /// Check if content is an episode
  bool get isEpisode => type == ContentType.episode;

  /// Check if content is anime
  bool get isAnime =>
      genres.any((g) => g.toLowerCase().contains('anime')) ||
      tags.any((t) => t.toLowerCase().contains('anime'));

  /// Check if content is a music video
  bool get isMusicVideo => type == ContentType.musicVideo;

  /// Check if content is a collection
  bool get isCollection => type == ContentType.collection;

  /// Get watch progress percentage (0.0 to 1.0)
  double get watchProgress {
    if (userData?.playbackPositionTicks == null || runTimeTicks == null) {
      return 0.0;
    }
    return (userData!.playbackPositionTicks! / runTimeTicks!).clamp(0.0, 1.0);
  }

  /// Check if content has been watched
  bool get isWatched => userData?.played ?? false;

  /// Check if content is in user's favorites
  bool get isFavorite => userData?.isFavorite ?? false;

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['Id'] ?? '',
      title: json['Name'] ?? '',
      overview: json['Overview'],
      type: _parseContentType(json['Type']),
      posterUrl: json['ImageTags']?['Primary'] != null
          ? '/Items/${json['Id']}/Images/Primary'
          : null,
      backdropUrl: json['BackdropImageTags']?.isNotEmpty == true
          ? '/Items/${json['Id']}/Images/Backdrop/0'
          : json['ParentBackdropImageTags']?.isNotEmpty == true
              ? '/Items/${json['ParentBackdropItemId']}/Images/Backdrop/0'
              : null,
      logoUrl: json['ImageTags']?['Logo'] != null
          ? '/Items/${json['Id']}/Images/Logo'
          : null,
      productionYear: json['ProductionYear'],
      premiereDate: json['PremiereDate'],
      communityRating: json['CommunityRating']?.toDouble(),
      officialRating: json['OfficialRating'],
      genres: (json['Genres'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['Tags'] as List<dynamic>?)?.cast<String>() ?? [],
      runTimeTicks: json['RunTimeTicks'],
      seasonCount: json['ChildCount'], // For series
      episodeCount: json['RecursiveItemCount'],
      indexNumber: json['IndexNumber'],
      seriesId: json['SeriesId'],
      seasonId: json['SeasonId'],
      seriesName: json['SeriesName'],
      collectionType: json['CollectionType'],
      childCount: json['ChildCount'],
      people: (json['People'] as List<dynamic>?)
          ?.map((p) => Person.fromJson(p))
          .toList() ?? [],
      container: json['Container'],
      bitrate: json['Bitrate'],
      mediaStreams: (json['MediaStreams'] as List<dynamic>?)
          ?.map((s) => MediaStream.fromJson(s))
          .toList() ?? [],
      userData: json['UserData'] != null
          ? UserData.fromJson(json['UserData'])
          : null,
      sortName: json['SortName'],
      dateCreated: json['DateCreated'] != null
          ? DateTime.tryParse(json['DateCreated'])
          : null,
      canDelete: json['CanDelete'] ?? false,
      canDownload: json['CanDownload'] ?? true,
    );
  }

  static ContentType _parseContentType(String? type) {
    switch (type?.toLowerCase()) {
      case 'movie':
        return ContentType.movie;
      case 'series':
        return ContentType.series;
      case 'season':
        return ContentType.season;
      case 'episode':
        return ContentType.episode;
      case 'musicvideo':
        return ContentType.musicVideo;
      case 'boxset':
      case 'collection':
        return ContentType.collection;
      default:
        return ContentType.unknown;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': title,
      'Overview': overview,
      'Type': type.name,
      'ProductionYear': productionYear,
      'CommunityRating': communityRating,
      'Genres': genres,
      'RunTimeTicks': runTimeTicks,
    };
  }
}

/// Content Type Enumeration
enum ContentType {
  movie,
  series,
  season,
  episode,
  musicVideo,
  collection,
  unknown,
}

/// Person Information (Cast, Director, etc.)
class Person {
  final String name;
  final String id;
  final String role;
  final String type; // Actor, Director, Writer, etc.
  final String? primaryImageTag;

  Person({
    required this.name,
    required this.id,
    required this.role,
    required this.type,
    this.primaryImageTag,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['Name'] ?? '',
      id: json['Id'] ?? '',
      role: json['Role'] ?? '',
      type: json['Type'] ?? '',
      primaryImageTag: json['PrimaryImageTag'],
    );
  }
}

/// Media Stream Information (Video, Audio, Subtitle tracks)
class MediaStream {
  final int index;
  final String type; // Video, Audio, Subtitle
  final String? codec;
  final String? language;
  final String? displayTitle;
  final bool isDefault;
  final int? bitrate;
  final int? width;
  final int? height;

  MediaStream({
    required this.index,
    required this.type,
    this.codec,
    this.language,
    this.displayTitle,
    this.isDefault = false,
    this.bitrate,
    this.width,
    this.height,
  });

  factory MediaStream.fromJson(Map<String, dynamic> json) {
    return MediaStream(
      index: json['Index'] ?? 0,
      type: json['Type'] ?? '',
      codec: json['Codec'],
      language: json['Language'],
      displayTitle: json['DisplayTitle'],
      isDefault: json['IsDefault'] ?? false,
      bitrate: json['BitRate'],
      width: json['Width'],
      height: json['Height'],
    );
  }
}

/// User-specific data (watch progress, favorites, etc.)
class UserData {
  final double? playbackPositionTicks;
  final int? playCount;
  final bool played;
  final bool isFavorite;
  final String? lastPlayedDate;
  final double? rating;

  UserData({
    this.playbackPositionTicks,
    this.playCount,
    this.played = false,
    this.isFavorite = false,
    this.lastPlayedDate,
    this.rating,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      playbackPositionTicks: json['PlaybackPositionTicks']?.toDouble(),
      playCount: json['PlayCount'],
      played: json['Played'] ?? false,
      isFavorite: json['IsFavorite'] ?? false,
      lastPlayedDate: json['LastPlayedDate'],
      rating: json['Rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PlaybackPositionTicks': playbackPositionTicks,
      'PlayCount': playCount,
      'Played': played,
      'IsFavorite': isFavorite,
      'LastPlayedDate': lastPlayedDate,
      'Rating': rating,
    };
  }
}

// Keep Movie class for backward compatibility
class Movie extends Content {
  Movie({
    required super.id,
    required super.title,
  }) : super(type: ContentType.movie);

  factory Movie.fromJson(Map<String, dynamic> json) {
    final content = Content.fromJson(json);
    return Movie(
      id: content.id,
      title: content.title,
    );
  }
}
