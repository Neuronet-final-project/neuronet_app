import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';
import '../../providers/channels_provider.dart';
import '../../../auth/providers/auth_provider.dart';

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
  String? _errorMessage;
  String? _editingCommentId;
  final TextEditingController _commentEditorController = TextEditingController();
  Map<String, TextEditingController>? _postCommentControllersMap;
  Map<String, TextEditingController> get _postCommentControllers {
    _postCommentControllersMap ??= {};
    return _postCommentControllersMap!;
  }

  TextEditingController _getCommentController(String postId) {
    final controllers = _postCommentControllers;
    if (!controllers.containsKey(postId)) {
      controllers[postId] = TextEditingController();
    }
    return controllers[postId]!;
  }

  @override
  void dispose() {
    _commentEditorController.dispose();
    for (var controller in _postCommentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

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
      _errorMessage = null;
    } else {
      _errorMessage = postsResult.failure.message;
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
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleComment(String postId) async {
    final controller = _getCommentController(postId);
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final service = ref.read(channelServiceProvider);
    final result = await service.commentOnPost(widget.channelId, postId, text);
    if (result.isSuccess) {
      controller.clear();
      await _loadInteractions(postId);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
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

  Future<void> _handleDeleteComment(String postId, String interactionId) async {
    final service = ref.read(channelServiceProvider);
    final result = await service.deleteInteraction(widget.channelId, postId, interactionId);
    if (result.isSuccess) {
      await _loadInteractions(postId);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleUpdateComment(String postId, String interactionId) async {
    final text = _commentEditorController.text.trim();
    if (text.isEmpty) return;

    final service = ref.read(channelServiceProvider);
    final result = await service.updateComment(widget.channelId, postId, interactionId, text);
    if (result.isSuccess) {
      setState(() {
        _editingCommentId = null;
        _commentEditorController.clear();
      });
      await _loadInteractions(postId);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.failure.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final channelsAsync = ref.watch(channelsControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.user?.id;

    final channel = channelsAsync.value?.channels.firstWhere(
      (c) => c.channelId == widget.channelId,
      orElse: () => Channel(
        channelId: widget.channelId,
        channelName: '',
        counselorId: '',
        channelType: ChannelType.educational,
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      backgroundColor: NeuroColors.adolescentSurface,
      appBar: AppBar(
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFF6A1FDB),
        elevation: 0,
        title: Text(
          channel?.channelName ?? l10n.channels,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(channel?.isFollowed == true ? Icons.check_circle : Icons.add_circle_outline),
            onPressed: () => ref
                .read(channelsControllerProvider.notifier)
                .toggleFollow(widget.channelId),
            tooltip: channel?.isFollowed == true ? 'Following' : 'Follow',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: NeuroColors.adolescentPrimary))
          : Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF2ECFF),
                          NeuroColors.adolescentSurface,
                          const Color(0xFFE8DCF9).withValues(alpha: 0.4),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE4D1FF), Color(0xFFDAC0FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
                        boxShadow: [
                          BoxShadow(
                            color: NeuroColors.adolescentPrimary.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_alt_rounded, size: 16, color: NeuroColors.adolescentPrimary),
                              const SizedBox(width: 8),
                              Text(
                                l10n.followerCountLabel(channel?.subscriberCount ?? 0),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: NeuroColors.adolescentPrimaryDark,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  (channel?.channelType.name ?? 'channel').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF6A5C9A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (channel?.description != null && channel!.description!.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              channel.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF53477D),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  if (_errorMessage != null && _posts.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: NeuroErrorWidget(
                          message: _errorMessage!,
                          onRetry: _loadData,
                        ),
                      ),
                    )
                  else
                  
                  if (_posts.isEmpty)
                    SliverFillRemaining(
                      child: Center(
                        child: const Text(
                          'No posts yet\nStay tuned for updates from your counselor.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = _posts[index];
                          return _buildPostCard(post, authState, currentUserId);
                        },
                        childCount: _posts.length,
                      ),
                    ),
                ],
              ),
            ),
              ],
            ),
    );
  }

  Widget _buildPostCard(ChannelPost post, AuthState authState, String? currentUserId) {
    final l10n = context.localizations;
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

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        final safePostId = Uri.encodeComponent(post.id.replaceAll('/', ''));
        context.push('${AdolescentRoutes.channels}/${widget.channelId}/posts/$safePostId');
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7C5EE)),
        boxShadow: [
          BoxShadow(
            color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
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
                  backgroundColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.25),
                  child: Text(
                    (post.counselorName ?? 'C').substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: NeuroColors.adolescentPrimaryDark, fontWeight: FontWeight.bold),
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
                            style: const TextStyle(fontSize: 10, color: NeuroColors.adolescentPrimary, fontWeight: FontWeight.w900),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Color(0xFF2C1C5F),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Color(0xFF4F3F7C),
                    fontWeight: FontWeight.w500,
                  ),
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
                  backgroundColor: const Color(0xFFFFF1D8),
                  borderColor: const Color(0xFFFFDDA5),
                  onTap: () => _handleReaction(post.id, 'like'),
                ),
                const SizedBox(width: 8),
                _ReactionButton(
                  emoji: '💜',
                  count: reactionCounts['support']?.toString(),
                  backgroundColor: const Color(0xFFEEDBFF),
                  borderColor: const Color(0xFFD8B5FF),
                  onTap: () => _handleReaction(post.id, 'support'),
                ),
                const SizedBox(width: 8),
                _ReactionButton(
                  emoji: '✅',
                  count: reactionCounts['helpful']?.toString(),
                  backgroundColor: const Color(0xFFE5F9E7),
                  borderColor: const Color(0xFFBCEAC2),
                  onTap: () => _handleReaction(post.id, 'helpful'),
                ),
                
                const Spacer(),
                
                Text(
                  '${post.reactionCount} Reactions • ${post.commentCount} Comments',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7B6AAB),
                    fontWeight: FontWeight.w700,
                  ),
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
                    isExpanded ? 'Hide Comments' : 'View Comments',
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(l10n.noCommentsYet, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  
                  ...comments.map((c) {
                    final isEditing = _editingCommentId == c.id;
                    final isOwner = currentUserId != null && c.userId == currentUserId;

                    return Padding(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                                          ),
                                          child: isEditing
                                              ? TextField(
                                                  controller: _commentEditorController,
                                                  style: const TextStyle(fontSize: 13),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.zero,
                                                    border: InputBorder.none,
                                                    suffixIcon: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(Icons.check, size: 16, color: Colors.green),
                                                          onPressed: () => _handleUpdateComment(post.id, c.id),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                                          onPressed: () => setState(() => _editingCommentId = null),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Column(
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
                                      if (isOwner && !isEditing) ...[
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _editingCommentId = c.id;
                                              _commentEditorController.text = c.content ?? '';
                                            });
                                          },
                                          child: const Text('Edit', 
                                            style: TextStyle(fontSize: 11, color: NeuroColors.adolescentPrimary, fontWeight: FontWeight.bold)),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => _handleDeleteComment(post.id, c.id),
                                          child: const Text('Delete', 
                                            style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  if (post.allowComments)
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _getCommentController(post.id),
                            decoration: InputDecoration(
                              hintText: l10n.addCommentHint,
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
    ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final String? count;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color borderColor;

  const _ReactionButton({
    required this.emoji,
    this.count,
    required this.onTap,
    this.backgroundColor = const Color(0xFFF0E5FF),
    this.borderColor = const Color(0xFFD7C3F5),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.28),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF523A8E),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
