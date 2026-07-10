import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/media_item.dart';

class LocalDb {
  static Database? _db;

  static Future<Database> get db async {
    _db ??= await _init();
    return _db!;
  }

  static Future<Database> _init() async {
    final path = join(await getDatabasesPath(), 'imdb_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE watchlist (
            id INTEGER PRIMARY KEY,
            title TEXT,
            posterPath TEXT,
            overview TEXT,
            releaseDate TEXT,
            voteAverage REAL,
            mediaType TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE favorites (
            id INTEGER PRIMARY KEY,
            title TEXT,
            posterPath TEXT,
            overview TEXT,
            releaseDate TEXT,
            voteAverage REAL,
            mediaType TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE cache (
            key TEXT PRIMARY KEY,
            data TEXT,
            timestamp INTEGER
          )
        ''');
      },
    );
  }

  // Watchlist
  static Future<void> addToWatchlist(MediaItem item) async {
    final database = await db;
    await database.insert('watchlist', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> removeFromWatchlist(int id) async {
    final database = await db;
    await database.delete('watchlist', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<MediaItem>> getWatchlist() async {
    final database = await db;
    final maps = await database.query('watchlist');
    return maps.map((m) => MediaItem.fromMap(m)).toList();
  }

  static Future<bool> isInWatchlist(int id) async {
    final database = await db;
    final res = await database.query('watchlist', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty;
  }

  // Favorites
  static Future<void> addToFavorites(MediaItem item) async {
    final database = await db;
    await database.insert('favorites', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> removeFromFavorites(int id) async {
    final database = await db;
    await database.delete('favorites', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<MediaItem>> getFavorites() async {
    final database = await db;
    final maps = await database.query('favorites');
    return maps.map((m) => MediaItem.fromMap(m)).toList();
  }

  static Future<bool> isInFavorites(int id) async {
    final database = await db;
    final res = await database.query('favorites', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty;
  }

  // Cache
  static Future<void> setCache(String key, String data) async {
    final database = await db;
    await database.insert(
      'cache',
      {'key': key, 'data': data, 'timestamp': DateTime.now().millisecondsSinceEpoch},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getCache(String key, {int maxAgeMinutes = 60}) async {
    final database = await db;
    final res = await database.query('cache', where: 'key = ?', whereArgs: [key]);
    if (res.isEmpty) return null;
    final timestamp = res.first['timestamp'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    if (age > maxAgeMinutes * 60 * 1000) return null;
    return res.first['data'] as String;
  }
}
