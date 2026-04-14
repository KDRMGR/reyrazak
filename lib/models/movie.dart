class Movie {
  final String id;
  final String title;
  /// Content type as returned by the Emby/Jellyfin API:
  /// 'Movie', 'Series', 'MusicVideo', 'Episode', 'Season', etc.
  final String type;

  Movie({
    required this.id,
    required this.title,
    this.type = '',
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['Id'] ?? '',
      title: json['Name'] ?? '',
      type: json['Type'] ?? '',
    );
  }

  bool get isSeries => type == 'Series';
  bool get isEpisode => type == 'Episode';
  bool get isMovie => type == 'Movie';
  bool get isMusicVideo => type == 'MusicVideo';
}
