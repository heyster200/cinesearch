class Season {
  final int seasonNumber;
  final String? name;
  final int episodeCount;
  final String? posterPath;
  final List<Episode> episodes;

  Season({
    required this.seasonNumber,
    this.name,
    required this.episodeCount,
    this.posterPath,
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonNumber: json['season_number'] as int,
      name: json['name'] as String?,
      episodeCount: json['episode_count'] as int? ?? 0,
      posterPath: json['poster_path'] as String?,
      episodes: (json['episodes'] as List?)
              ?.map((e) => Episode.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Episode {
  final int id;
  final int episodeNumber;
  final String name;
  final String? overview;
  final String? airDate;
  final double? voteAverage;
  final String? stillPath;

  Episode({
    required this.id,
    required this.episodeNumber,
    required this.name,
    this.overview,
    this.airDate,
    this.voteAverage,
    this.stillPath,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      episodeNumber: json['episode_number'] as int,
      name: json['name'] as String,
      overview: json['overview'] as String?,
      airDate: json['air_date'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      stillPath: json['still_path'] as String?,
    );
  }
}
