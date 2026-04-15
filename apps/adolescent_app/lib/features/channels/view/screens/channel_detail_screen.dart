import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/channels_provider.dart';

class ChannelDetailScreen extends ConsumerStatefulWidget {
  final String channelId;

  const ChannelDetailScreen({super.key, required this.channelId});

  @override
  ConsumerState<ChannelDetailScreen> createState() => _ChannelDetailScreenState();
}

class _ChannelDetailScreenState extends ConsumerState<ChannelDetailScreen> {
  bool _isLoading = true;
  List<ChannelPost> _posts = [];
  final Map<String, List<ChannelInteraction>> _interactions = {};
  final Map<String, String> _commentInputs = {};
  String? _expandedPostId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final service = ref.read(channelServiceProvider);
    
    // Fetch posts
    final postsResult = await service.getChannelPosts(widget.channelId);
    if (postsResult.isSuccess) {
      _posts = postsResult.value;
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadInteractions(String postId) async {
    final service = ref.read(channelServiceProvider);
    final result = await service.getPostInteractions(widget.channelId, postId);
    if (result.isSuccess) {
      setState(() {
        _interactions[postId] = result.value;
      });
    }
  }

  Future<void> _handleReaction(String postId, String emojiType) async {
    final service = ref.read(channelServiceProvider);
    final result = await service.reactToPost(widget.channelId, postId, emojiType);
    if (result.isSuccess) {
      await _loadInteractions(postId);
    }
  }

  Future<void> _handleComment(String postId) async {
    final text = _commentInputs[postId]?.trim();
    if (text == null || text.isEmpty) return;

    final service = ref.read(channelServiceProvider);
    final result = await service.commentOnPost(widget.channelId, postId, text);
    if (result.isSuccess) {
      setState(() {
        _commentInputs[postId] = '';
      });
      await _loadInteractions(postId);
    }
  }

  void _toggleExpand(String postId) {
    setState(() {
      if (_expandedPostId == postId) {
        _expandedPostId = null;
      } else {
        _expandedPostId = postId;
        if (!_interactions.containsKey(postId)) {
          _loadInteractions(postId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelsControllerProvider);

    final channel = channelsAsync.value?.firstWhere(
      (c) => c.channelId == widget.channelId,
      orElse: () => Channel(
        channelId: widget.channelId,
        channelName: 'Loading Channel...',
        counselorId: '',
        channelType: ChannelType.educational,
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(channel?.channelName ?? 'Channel'),
        actions: [
          IconButton(
            icon: Icon(channel?.isFollowed == true ? Icons.check_circle : Icons.add_circle_outline),
            onPressed: () => ref
                .read(channelsControllerProvider.notifier)
                .toggleFollow(widget.channelId),
            tooltip: channel?.isFollowed == true ? 'Following' : 'Follow',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  if (channel?.description != null && channel!.description!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        color: NeuroColors.adolescentPrimary.withValues(alpha: 0.05),
                        child: Text(
                          channel.description!,
                          style: const TextStyle(fontSize: 14, color: NeuroColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  
                  if (_posts.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No posts yet.\nCounselors will post updates here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = _posts[index];
                          return _buildPostCard(post);
                        },
                        childCount: _posts.length,
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildPostCard(ChannelPost post) {
    final isExpanded = _expandedPostId == post.id;
    final postInteractions = _interactions[post.id] ?? [];
    
    final comments = postInteractions.where((i) => i.interactionType == 'comment').toList();
    
    // Calculate grouped reactions from array (backend provides count, but mobile groups locally if expanded)
    final reactions = postInteractions.where((i) => i.interactionType == 'reaction').toList();
    final Map<String, int> reactionCounts = {};
    for (var r in reactions) {
      if (r.reactionType != null) {
        reactionCounts[r.reactionType!] = (reactionCounts[r.reactionType!] ?? 0) + 1;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: NeuroColors.adolescentPrimary,
                  child: Text(
                    (post.counselorName ?? 'C').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.counselorName ?? 'Counselor',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            post.postType.toUpperCase(),
                            style: const TextStyle(fontSize: 10, color: NeuroColors.adolescentPrimary, fontWeight: FontWeight.bold),
                          ),
                          const Text(' • ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(
                            post.createdAt.toLocal().toString().split(' ')[0],
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (post.isPinned)
                  const Icon(Icons.push_pin, color: Colors.amber, size: 20),
              ],
            ),
          ),
          
          // Post Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
              ],
            ),
          ),
          
          // Reaction Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _ReactionButton(
                  emoji: '👍',
                  count: reactionCounts['like']?.toString(),
                  onTap: () => _handleReaction(post.id, 'like'),
                ),
                const SizedBox(width: 8),
                _ReactionButton(
                  emoji: '💜',
                  count: reactionCounts['support']?.toString(),
                  onTap: () => _handleReaction(post.id, 'support'),
                ),
                const SizedBox(width: 8),
                _ReactionButton(
                  emoji: '✅',
                  count: reactionCounts['helpful']?.toString(),
                  onTap: () => _handleReaction(post.id, 'helpful'),
                ),
                
                const Spacer(),
                
                Text(
                  '${post.reactionCount} reactions • ${post.commentCount} comments',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Comment Toggle
          InkWell(
            onTap: () => _toggleExpand(post.id),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isExpanded ? 'Hide comments' : 'View comments',
                    style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Comments Area
          if (isExpanded)
            Container(
              color: Colors.grey.withValues(alpha: 0.05),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Text('No comments yet.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  
                  ...comments.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.grey[300],
                          child: Text(
                            (c.userName ?? 'U')[0].toUpperCase(),
                            style: const TextStyle(fontSize: 10, color: Colors.black54),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.userName ?? 'User',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(c.content ?? '', style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  
                  if (post.allowComments)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: const TextStyle(fontSize: 13),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                              ),
                            ),
                            onChanged: (val) {
                              _commentInputs[post.id] = val;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: NeuroColors.adolescentPrimary),
                          onPressed: () => _handleComment(post.id),
                        ),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String? count;
  final VoidCallback onTap;

  const _ReactionButton({required this.emoji, this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(count!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}
