import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/channels_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/comments_bottom_sheet.dart';

class ChannelDetailScreen extends ConsumerWidget {
  final String channelId;

  const ChannelDetailScreen({super.key, required this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(channelPostsControllerProvider(channelId));
    final channelsAsync = ref.watch(channelsControllerProvider);
    
    // Find channel info to show in the header
    final channel = channelsAsync.value?.firstWhere(
      (c) => c.channelId == channelId,
      orElse: () => Channel(
        channelId: channelId,
        counselorId: '',
        channelName: 'Channel',
        description: '',
        channelType: ChannelType.educational,
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(channel?.channelName ?? 'Channel'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.forum,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
            actions: [
              if (channel != null)
                IconButton(
                  icon: Icon(channel.isFollowed ? Icons.check_circle : Icons.add_circle_outline),
                  onPressed: () => ref
                      .read(channelsControllerProvider.notifier)
                      .toggleFollow(channelId),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel?.description ?? '',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${channel?.subscriberCount ?? 0} members',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(height: 32),
                ],
              ),
            ),
          ),
          postsAsync.when(
            data: (posts) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return PostCard(
                    post: post,
                    onReact: () => ref
                        .read(channelPostsControllerProvider(channelId).notifier)
                        .toggleReaction(post.postId),
                    onComment: () =>
                        _showCommentsBottomSheet(context, post.postId),
                  );
                },
                childCount: posts.length,
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error loading posts: $err')),
            ),
          ),
        ],
      ),
    );
  }
    
  void _showCommentsBottomSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        postId: postId,
        channelId: channelId,
      ),
    );
  }
}
