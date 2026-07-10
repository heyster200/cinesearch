import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/tmdb_service.dart';

enum LoadState { idle, loading, loaded, error }

class HomeProvider extends ChangeNotifier {
  final TmdbService _api = TmdbService();

  List<MediaItem> trending = [];
  List<MediaItem> popularMovies = [];
  List<MediaItem> popularTv = [];
  LoadState state = LoadState.idle;
  String? errorMessage;

  Future<void> load() async {
    state = LoadState.loading;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.getTrending(),
        _api.getPopularMovies(),
        _api.getPopularTv(),
      ]);
      trending = results[0];
      popularMovies = results[1];
      popularTv = results[2];
      state = LoadState.loaded;
    } catch (e) {
      errorMessage = 'Verbindungsfehler. Bitte erneut versuchen.';
      state = LoadState.error;
    }
    notifyListeners();
  }
}
