import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/post.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(post.createdAt);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: (post.authorAvatar != null && post.authorAvatar!.isNotEmpty)
                      ? CachedNetworkImageProvider(post.authorAvatar!)
                      : null,
                  child: (post.authorAvatar == null || post.authorAvatar!.isEmpty)
                      ? Text(post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?')
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (post.title != null && post.title!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(post.title!, style: Theme.of(context).textTheme.titleMedium),
            ],
            if (post.text.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(post.text),
            ],
            if (post.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(imageUrl: post.images.first, fit: BoxFit.cover),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
