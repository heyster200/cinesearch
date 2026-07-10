import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../models/person.dart';
import '../models/episode.dart';
import '../services/tmdb_service.dart';
import '../providers/lists_provider.dart';
import 'person_screen.dart';

class DetailScreen extends StatefulWidget {
  final MediaItem item;
  const DetailScreen({super.key, required this.item});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _api = TmdbService();
  MediaItem? _details;
  List<Person> _cast = [];
  List<Season> _seasons = [];
  bool _loading = true;
  String? _error;
  int? _expandedSeason;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final details = widget.item.mediaType == 'movie'
          ? await _api.getMovieDetails(widget.item.id)
          : await _api.getTvDetails(widget.item.id);
      final cast = await _api.getCredits(widget.item.id, widget.item.mediaType);
      setState(() {
        _details = details;
        _cast = cast;
        _loading = false;
        if (details.mediaType == 'tv' && details.numberOfSeasons != null) {
          _seasons = List.generate(
            details.numberOfSeasons!,
            (i) => Season(seasonNumber: i + 1, episodeCount: 0, name: 'Staffel ${i + 1}'),
          );
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Fehler beim Laden. Bitte erneut versuchen.';
        _loading = false;
      });
    }
  }

  Future<void> _loadSeason(int seasonNumber) async {
    try {
      final season = await _api.getSeason(widget.item.id, seasonNumber);
      setState(() {
        final idx = _seasons.indexWhere((s) => s.seasonNumber == seasonNumber);
        if (idx >= 0) _seasons[idx] = season;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final item = _details ?? widget.item;
    final lists = context.watch<ListsProvider>();

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.grey)),
                      TextButton(onPressed: _load, child: const Text('Erneut versuchen')),
                    ],
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Backdrop + titel
                    SliverAppBar(
                      expandedHeight: 260,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          item.title,
                          style: const TextStyle(fontSize: 14, shadows: [Shadow(blurRadius: 8)]),
                        ),
                        background: item.backdropUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: item.backdropUrl,
                                fit: BoxFit.cover,
                                color: Colors.black.withOpacity(0.4),
                                colorBlendMode: BlendMode.darken,
                              )
                            : Container(color: Colors.grey.shade900),
                      ),
                      actions: [
                        // Watchlist
                        FutureBuilder<bool>(
                          future: lists.isInWatchlist(item.id),
                          builder: (_, snap) => IconButton(
                            icon: Icon(
                              snap.data == true ? Icons.bookmark : Icons.bookmark_border,
                              color: snap.data == true ? Colors.amber : Colors.white,
                            ),
                            onPressed: () => lists.toggleWatchlist(item),
                          ),
                        ),
                        // Favorite
                        FutureBuilder<bool>(
                          future: lists.isInFavorites(item.id),
                          builder: (_, snap) => IconButton(
                            icon: Icon(
                              snap.data == true ? Icons.favorite : Icons.favorite_border,
                              color: snap.data == true ? Colors.red : Colors.white,
                            ),
                            onPressed: () => lists.toggleFavorite(item),
                          ),
                        ),
                      ],
                    ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Meta info
                            Wrap(
                              spacing: 8,
                              children: [
                                if (item.year.isNotEmpty)
                                  _chip(item.year),
                                if (item.runtime != null && item.runtime! > 0)
                                  _chip('${item.runtime} Min'),
                                if (item.voteAverage != null && item.voteAverage! > 0)
                                  _chip('⭐ ${item.voteAverage!.toStringAsFixed(1)}'),
                                if (item.status != null)
                                  _chip(item.status!),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Genres
                            if (item.genres != null && item.genres!.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                children: item.genres!
                                    .map((g) => Chip(
                                          label: Text(g, style: const TextStyle(fontSize: 11)),
                                          padding: EdgeInsets.zero,
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ))
                                    .toList(),
                              ),
                            const SizedBox(height: 16),

                            // Synopsis
                            if (item.overview != null && item.overview!.isNotEmpty) ...[
                              const Text('Handlung',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(item.overview!,
                                  style: TextStyle(color: Colors.grey.shade300, height: 1.5)),
                              const SizedBox(height: 20),
                            ],

                            // Cast
                            if (_cast.isNotEmpty) ...[
                              const Text('Besetzung',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 130,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _cast.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, i) => _castCard(_cast[i], context),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Seasons (TV only)
                            if (_seasons.isNotEmpty) ...[
                              const Text('Staffeln',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ..._seasons.map((s) => _seasonTile(s)),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _castCard(Person person, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PersonScreen(personId: person.id, name: person.name)),
      ),
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: person.photoUrl.isNotEmpty ? NetworkImage(person.photoUrl) : null,
              child: person.photoUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(height: 4),
            Text(person.name, maxLines: 2, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10)),
            if (person.character != null)
              Text(person.character!, maxLines: 1,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _seasonTile(Season season) {
    final isExpanded = _expandedSeason == season.seasonNumber;
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(season.name ?? 'Staffel ${season.seasonNumber}'),
          subtitle: Text('${season.episodeCount} Folgen'),
          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
          onTap: () async {
            if (!isExpanded) await _loadSeason(season.seasonNumber);
            setState(() => _expandedSeason = isExpanded ? null : season.seasonNumber);
          },
        ),
        if (isExpanded && season.episodes.isNotEmpty)
          ...season.episodes.map((e) => _episodeTile(e)),
        const Divider(height: 1),
      ],
    );
  }

  Widget _episodeTile(Episode ep) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('${ep.episodeNumber}', style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ep.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (ep.airDate != null)
                  Text(ep.airDate!, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                if (ep.voteAverage != null && ep.voteAverage! > 0)
                  Text('⭐ ${ep.voteAverage!.toStringAsFixed(1)}',
                      style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
