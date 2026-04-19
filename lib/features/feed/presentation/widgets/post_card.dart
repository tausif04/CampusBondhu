import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import 'action_button.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.shade200,
                child: Text(post.userName[0]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      timeago.format(post.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.orange.shade200,
                child: Text(post.userName[0]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      timeago.format(post.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('❤️ ${post.likes}'),
              const SizedBox(width: 12),
              Text('💬 ${post.comments}'),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_border,
                label: 'Like',
                onTap: () =>
                    ref.read(feedProvider.notifier).toggleLike(post.id),
              ),
              ActionButton(
                icon: Icons.comment_outlined,
                label: 'Comment',
                onTap: () => debugPrint('Comment'),
              ),
              ActionButton(
                icon: Icons.share_outlined,
                label: 'Share',
                onTap: () => debugPrint('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
