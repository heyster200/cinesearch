import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/media_item.dart';
import '../models/person.dart';
import '../services/tmdb_service.dart';
import '../widgets/media_card.dart';
import 'detail_screen.dart';

class PersonScreen extends StatefulWidget {
  final int personId;
  final String name;

  const PersonScreen({super.key, required this.personId, required this.name});

  @override
  State<PersonScreen> createState() => _PersonScreenState();
}

class _PersonScreenState extends State<PersonScreen> {
  final _api = TmdbService();
  Person? _person;
  List<MediaItem> _credits = [];
  bool _loading = true;
  bool _bioExpanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final person = await _api.getPersonDetails(widget.personId);
      final credits = await _api.getPersonCredits(widget.personId);
      setState(() {
        _person = person;
        _credits = credits;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _person == null
              ? const Center(child: Text('Nicht gefunden'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _person!.photoUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _person!.photoUrl,
                                    width: 110,
                                    height: 160,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 110,
                                    height: 160,
                                    color: Colors.grey.shade800,
                                    child: const Icon(Icons.person, size: 48),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_person!.name,
                                    style: const TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                if (_person!.birthday != null)
                                  _infoRow(Icons.cake, _person!.birthday!),
                                if (_person!.placeOfBirth != null)
                                  _infoRow(Icons.location_on, _person!.placeOfBirth!),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Biografie
                      if (_person!.biography != null && _person!.biography!.isNotEmpty) ...[
                        const Text('Biografie',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => setState(() => _bioExpanded = !_bioExpanded),
                          child: Text(
                            _person!.biography!,
                            maxLines: _bioExpanded ? null : 4,
                            overflow: _bioExpanded ? null : TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey.shade300, height: 1.5),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _bioExpanded = !_bioExpanded),
                          child: Text(_bioExpanded ? 'Weniger' : 'Mehr lesen'),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Filmografie
                      if (_credits.isNotEmpty) ...[
                        const Text('Filmografie',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.55,
                          ),
                          itemCount: _credits.length,
                          itemBuilder: (context, i) => MediaCard(
                            item: _credits[i],
                            width: double.infinity,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DetailScreen(item: _credits[i])),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 4),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
          ),
        ],
      ),
    );
  }
}
