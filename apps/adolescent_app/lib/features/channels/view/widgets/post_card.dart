import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neuronet_core/neuronet_core.dart';

class PostCard extends StatelessWidget {
  final ChannelPost post;
  final VoidCallback onReact;

  const PostCard({
    super.key,
    required this.post,
    required this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (post.isPinned) ...[
                  const Icon(Icons.push_pin, size: 14, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'Pinned',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                ],
                Text(
                  DateFormat.yMMMd().format(post.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              post.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              post.content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                InkWell(
                  onTap: onReact,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: post.isReacted
                          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.isReacted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: post.isReacted ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.reactionCount}',
                          style: TextStyle(
                            color: post.isReacted ? Colors.red : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${post.viewCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
