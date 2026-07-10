class Person {
  final int id;
  final String name;
  final String? profilePath;
  final String? biography;
  final String? birthday;
  final String? placeOfBirth;
  final String? character;
  final String? job;
  final List<dynamic>? knownFor;

  Person({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.birthday,
    this.placeOfBirth,
    this.character,
    this.job,
    this.knownFor,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      name: json['name'] as String,
      profilePath: json['profile_path'] as String?,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      character: json['character'] as String?,
      job: json['job'] as String?,
      knownFor: json['known_for'] as List?,
    );
  }

  String get photoUrl =>
      profilePath != null ? 'https://image.tmdb.org/t/p/w185$profilePath' : '';
}
