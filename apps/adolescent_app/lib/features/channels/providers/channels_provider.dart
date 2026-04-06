import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channels_provider.g.dart';

@riverpod
class ChannelsController extends _$ChannelsController {
  @override
  FutureOr<List<Channel>> build() async {
    return ref.watch(channelServiceProvider).getMyChannels();
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
      await ref.read(channelServiceProvider).subscribeToChannel(channelId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class ChannelPostsController extends _$ChannelPostsController {
  @override
  FutureOr<List<ChannelPost>> build(String channelId) async {
    return ref.watch(channelServiceProvider).getChannelPosts(channelId);
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
      await ref.read(channelServiceProvider).interactWithPost(
            channelId: channelId,
            postId: postId,
            type: InteractionType.reaction,
          );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class ChannelCommentsController extends _$ChannelCommentsController {
  @override
  FutureOr<List<ChannelInteraction>> build(String channelId, String postId) async {
    return ref.watch(channelServiceProvider).getChannelInteractions(
          channelId: channelId,
          postId: postId,
        );
  }

  Future<void> addComment(String content) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final newComment = await ref.read(channelServiceProvider).interactWithPost(
            channelId: channelId,
            postId: postId,
            type: InteractionType.comment,
            content: content,
          );

      state = AsyncValue.data([...currentState, newComment]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
