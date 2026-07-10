class MediaItem {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String? overview;
  final String? releaseDate;
  final double? voteAverage;
  final String mediaType; // 'movie' or 'tv'
  final List<int>? genreIds;
  final int? runtime;
  final List<String>? genres;
  final String? status;
  final int? numberOfSeasons;

  MediaItem({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    this.overview,
    this.releaseDate,
    this.voteAverage,
    required this.mediaType,
    this.genreIds,
    this.runtime,
    this.genres,
    this.status,
    this.numberOfSeasons,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, {String? type}) {
    final mediaType = type ?? (json['media_type'] as String? ?? 'movie');
    return MediaItem(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      overview: json['overview'] as String?,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      mediaType: mediaType,
      genreIds: (json['genre_ids'] as List?)?.cast<int>(),
      runtime: json['runtime'] as int?,
      genres: (json['genres'] as List?)?.map((g) => g['name'] as String).toList(),
      status: json['status'] as String?,
      numberOfSeasons: json['number_of_seasons'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'posterPath': posterPath,
      'overview': overview,
      'releaseDate': releaseDate,
      'voteAverage': voteAverage,
      'mediaType': mediaType,
    };
  }

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      id: map['id'] as int,
      title: map['title'] as String,
      posterPath: map['posterPath'] as String?,
      overview: map['overview'] as String?,
      releaseDate: map['releaseDate'] as String?,
      voteAverage: map['voteAverage'] as double?,
      mediaType: map['mediaType'] as String,
    );
  }

  String get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w342$posterPath' : '';

  String get backdropUrl =>
      backdropPath != null ? 'https://image.tmdb.org/t/p/w780$backdropPath' : '';

  String get year => releaseDate?.split('-').first ?? '';
}
