class Movie {
  final String id;
  final String title;

  Movie({
    required this.id,
    required this.title,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['Id'] ?? '',
      title: json['Name'] ?? '',
    );
  }
}
