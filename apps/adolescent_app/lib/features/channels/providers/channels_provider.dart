import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channels_provider.g.dart';

@riverpod
class ChannelsController extends _$ChannelsController {
  @override
  FutureOr<List<Channel>> build() async {
    // In a real app, this would call a repository
    // For now, we use the expanded MockDataService
    return MockDataService.getMockChannels();
  }

  Future<void> toggleFollow(String channelId) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      currentState.map((c) {
        if (c.channelId == channelId) {
          final newFollowed = !c.isFollowed;
          return c.copyWith(
            isFollowed: newFollowed,
            subscriberCount: c.subscriberCount + (newFollowed ? 1 : -1),
          );
        }
        return c;
      }).toList(),
    );

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      // In real implementation: await ref.read(channelRepositoryProvider).toggleFollow(channelId);
    } catch (e, st) {
      // Rollback on error if necessary, or just refresh
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class ChannelPostsController extends _$ChannelPostsController {
  @override
  FutureOr<List<ChannelPost>> build(String channelId) async {
    return MockDataService.getMockPosts(channelId);
  }

  Future<void> toggleReaction(String postId) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic update
    state = AsyncValue.data(
      currentState.map((p) {
        if (p.postId == postId) {
          final newReacted = !p.isReacted;
          return p.copyWith(
            isReacted: newReacted,
            reactionCount: p.reactionCount + (newReacted ? 1 : -1),
          );
        }
        return p;
      }).toList(),
    );

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class ChannelCommentsController extends _$ChannelCommentsController {
  @override
  FutureOr<List<ChannelInteraction>> build(String postId) async {
    return MockDataService.getMockComments(postId);
  }

  Future<void> addComment(String content) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newComment = ChannelInteraction(
      interactionId: 'new-${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      adolescentId: 'user-123',
      interactionType: InteractionType.comment,
      content: content,
      createdAt: DateTime.now(),
    );

    // Optimistic update
    state = AsyncValue.data([...currentState, newComment]);

    try {
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
