import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/search_provider.dart';
import '../models/media_item.dart';
import '../models/person.dart';
import '../widgets/media_card.dart';
import 'detail_screen.dart';
import 'person_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Suchen...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (q) => provider.search(q),
        ),
        backgroundColor: Colors.grey.shade900,
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _chip('Alle', 'all', provider),
                const SizedBox(width: 8),
                _chip('Filme', 'movie', provider),
                const SizedBox(width: 8),
                _chip('Serien', 'tv', provider),
                const SizedBox(width: 8),
                _chip('Personen', 'person', provider),
                const SizedBox(width: 16),
                _yearFilter(provider),
              ],
            ),
          ),

          // Results
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.wifi_off, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(provider.error!, style: const TextStyle(color: Colors.grey)),
                            TextButton(
                              onPressed: () => provider.search(_ctrl.text),
                              child: const Text('Erneut versuchen'),
                            ),
                          ],
                        ),
                      )
                    : provider.selectedType == 'person'
                        ? _personList(provider.personResults)
                        : _mediaGrid(provider.results),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, SearchProvider provider) {
    final selected = provider.selectedType == value;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        provider.setType(value);
        if (_ctrl.text.isNotEmpty) provider.search(_ctrl.text);
      },
      selectedColor: Colors.amber.shade700,
    );
  }

  Widget _yearFilter(SearchProvider provider) {
    return GestureDetector(
      onTap: () async {
        final year = await showDialog<String>(
          context: context,
          builder: (_) => _YearDialog(initial: provider.selectedYear),
        );
        provider.setYear(year);
        if (_ctrl.text.isNotEmpty) provider.search(_ctrl.text);
      },
      child: Chip(
        label: Text(provider.selectedYear ?? 'Jahr'),
        avatar: const Icon(Icons.calendar_today, size: 16),
      ),
    );
  }

  Widget _mediaGrid(List<MediaItem> items) {
    if (items.isEmpty) {
      return const Center(child: Text('Keine Ergebnisse', style: TextStyle(color: Colors.grey)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.55,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => MediaCard(
        item: items[i],
        width: double.infinity,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(item: items[i])),
        ),
      ),
    );
  }

  Widget _personList(List<Person> people) {
    if (people.isEmpty) {
      return const Center(child: Text('Keine Ergebnisse', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: people.length,
      itemBuilder: (context, i) {
        final p = people[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: p.photoUrl.isNotEmpty
                ? NetworkImage(p.photoUrl)
                : null,
            child: p.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(p.name),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PersonScreen(personId: p.id, name: p.name)),
          ),
        );
      },
    );
  }
}

class _YearDialog extends StatefulWidget {
  final String? initial;
  const _YearDialog({this.initial});

  @override
  State<_YearDialog> createState() => _YearDialogState();
}

class _YearDialogState extends State<_YearDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Jahr filtern'),
      content: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        maxLength: 4,
        decoration: const InputDecoration(hintText: 'z.B. 2023'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Löschen')),
        TextButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.isEmpty ? null : _ctrl.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
