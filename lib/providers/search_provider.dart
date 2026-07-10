import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../models/person.dart';
import '../services/tmdb_service.dart';

class SearchProvider extends ChangeNotifier {
  final TmdbService _api = TmdbService();

  List<MediaItem> results = [];
  List<Person> personResults = [];
  bool isLoading = false;
  String? error;
  String selectedType = 'all'; // all, movie, tv, person
  String? selectedYear;

  Future<void> search(String query) async {
    if (query.isEmpty) {
      results = [];
      personResults = [];
      notifyListeners();
      return;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      if (selectedType == 'person') {
        personResults = await _api.searchPeople(query);
        results = [];
      } else {
        results = await _api.search(query,
            year: selectedYear,
            type: selectedType == 'all' ? null : selectedType);
        personResults = [];
      }
    } catch (e) {
      error = 'Suche fehlgeschlagen. Bitte erneut versuchen.';
    }
    isLoading = false;
    notifyListeners();
  }

  void setType(String type) {
    selectedType = type;
    notifyListeners();
  }

  void setYear(String? year) {
    selectedYear = year;
    notifyListeners();
  }
}
