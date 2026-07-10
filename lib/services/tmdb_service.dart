import 'package:dio/dio.dart';
import '../core/constants.dart';
import '../models/media_item.dart';
import '../models/person.dart';
import '../models/episode.dart';

class TmdbService {
  late final Dio _dio;

  TmdbService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: AppConstants.timeoutSeconds),
      receiveTimeout: const Duration(seconds: AppConstants.timeoutSeconds),
      queryParameters: {
        'api_key': AppConstants.apiKey,
        'language': 'de-DE',
      },
    ));
  }

  Future<List<MediaItem>> getTrending() async {
    final res = await _dio.get('/trending/all/week');
    return (res.data['results'] as List)
        .map((e) => MediaItem.fromJson(e))
        .toList();
  }

  Future<List<MediaItem>> getPopularMovies() async {
    final res = await _dio.get('/movie/popular');
    return (res.data['results'] as List)
        .map((e) => MediaItem.fromJson(e, type: 'movie'))
        .toList();
  }

  Future<List<MediaItem>> getPopularTv() async {
    final res = await _dio.get('/tv/popular');
    return (res.data['results'] as List)
        .map((e) => MediaItem.fromJson(e, type: 'tv'))
        .toList();
  }

  Future<List<MediaItem>> search(String query, {String? year, String? type}) async {
    final endpoint = type == 'movie'
        ? '/search/movie'
        : type == 'tv'
            ? '/search/tv'
            : '/search/multi';
    final res = await _dio.get(endpoint, queryParameters: {
      'query': query,
      if (year != null) 'year': year,
    });
    return (res.data['results'] as List)
        .where((e) => e['media_type'] != 'person' || type == null)
        .map((e) => MediaItem.fromJson(e, type: type))
        .toList();
  }

  Future<List<Person>> searchPeople(String query) async {
    final res = await _dio.get('/search/person', queryParameters: {'query': query});
    return (res.data['results'] as List)
        .map((e) => Person.fromJson(e))
        .toList();
  }

  Future<MediaItem> getMovieDetails(int id) async {
    final res = await _dio.get('/movie/$id');
    return MediaItem.fromJson(res.data, type: 'movie');
  }

  Future<MediaItem> getTvDetails(int id) async {
    final res = await _dio.get('/tv/$id');
    return MediaItem.fromJson(res.data, type: 'tv');
  }

  Future<Person> getPersonDetails(int id) async {
    final res = await _dio.get('/person/$id');
    return Person.fromJson(res.data);
  }

  Future<List<Person>> getCredits(int id, String type) async {
    final res = await _dio.get('/$type/$id/credits');
    final cast = (res.data['cast'] as List?)
            ?.take(20)
            .map((e) => Person.fromJson(e))
            .toList() ??
        [];
    return cast;
  }

  Future<List<MediaItem>> getPersonCredits(int id) async {
    final res = await _dio.get('/person/$id/combined_credits');
    final credits = (res.data['cast'] as List?)
            ?.map((e) => MediaItem.fromJson(e))
            .where((e) => e.posterPath != null)
            .toList() ??
        [];
    credits.sort((a, b) => (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0));
    return credits.take(20).toList();
  }

  Future<Season> getSeason(int tvId, int seasonNumber) async {
    final res = await _dio.get('/tv/$tvId/season/$seasonNumber');
    return Season.fromJson(res.data);
  }

  Future<List<Map<String, dynamic>>> getGenres(String type) async {
    final res = await _dio.get('/genre/$type/list');
    return (res.data['genres'] as List).cast<Map<String, dynamic>>();
  }
}
