import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/local_db.dart';

class ListsProvider extends ChangeNotifier {
  List<MediaItem> watchlist = [];
  List<MediaItem> favorites = [];

  Future<void> load() async {
    watchlist = await LocalDb.getWatchlist();
    favorites = await LocalDb.getFavorites();
    notifyListeners();
  }

  Future<void> toggleWatchlist(MediaItem item) async {
    if (await LocalDb.isInWatchlist(item.id)) {
      await LocalDb.removeFromWatchlist(item.id);
      watchlist.removeWhere((e) => e.id == item.id);
    } else {
      await LocalDb.addToWatchlist(item);
      watchlist.add(item);
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(MediaItem item) async {
    if (await LocalDb.isInFavorites(item.id)) {
      await LocalDb.removeFromFavorites(item.id);
      favorites.removeWhere((e) => e.id == item.id);
    } else {
      await LocalDb.addToFavorites(item);
      favorites.add(item);
    }
    notifyListeners();
  }

  Future<bool> isInWatchlist(int id) => LocalDb.isInWatchlist(id);
  Future<bool> isInFavorites(int id) => LocalDb.isInFavorites(id);
}
