import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../screens/detail_screen.dart';
import 'media_card.dart';

class SectionRow extends StatelessWidget {
  final String title;
  final List<MediaItem> items;

  const SectionRow({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return MediaCard(
                item: item,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailScreen(item: item)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
