import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/media_item.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final double width;

  const MediaCard({
    super.key,
    required this.item,
    required this.onTap,
    this.width = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.posterUrl,
                      width: width,
                      height: width * 1.5,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _shimmer(width),
                      errorWidget: (_, __, ___) => _placeholder(width),
                    )
                  : _placeholder(width),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            if (item.voteAverage != null && item.voteAverage! > 0)
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 12, color: Colors.amber.shade400),
                  const SizedBox(width: 2),
                  Text(
                    item.voteAverage!.toStringAsFixed(1),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _shimmer(double width) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade600,
      child: Container(
        width: width,
        height: width * 1.5,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _placeholder(double width) {
    return Container(
      width: width,
      height: width * 1.5,
      color: Colors.grey.shade800,
      child: const Icon(Icons.movie, color: Colors.white30),
    );
  }
}
