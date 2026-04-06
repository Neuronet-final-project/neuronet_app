import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channels_provider.g.dart';

@riverpod
class ChannelsController extends _$ChannelsController {
  @override
  FutureOr<List<Channel>> build() async {
    final result = await ref.watch(channelServiceProvider).getMyChannels();
    return result.when(
      success: (value) => value,
      failure: (f) => throw Exception(f.message),
    );
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
      final result = await ref.read(channelServiceProvider).subscribeToChannel(channelId);
      if (result.isFailure) {
        // Rollback optimistic update by refetching
        state = AsyncValue.error(Exception(result.failure.message), StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class ChannelPostsController extends _$ChannelPostsController {
  @override
  FutureOr<List<ChannelPost>> build(String channelId) async {
    final result = await ref.watch(channelServiceProvider).getChannelPosts(channelId);
    return result.when(
      success: (value) => value,
      failure: (f) => throw Exception(f.message),
    );
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
      final result = await ref.read(channelServiceProvider).interactWithPost(
            channelId: channelId,
            postId: postId,
            type: InteractionType.reaction,
          );
      if (result.isFailure) {
        state = AsyncValue.error(Exception(result.failure.message), StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

@riverpod
class ChannelCommentsController extends _$ChannelCommentsController {
  @override
  FutureOr<List<ChannelInteraction>> build(String channelId, String postId) async {
    final result = await ref.watch(channelServiceProvider).getChannelInteractions(
          channelId: channelId,
          postId: postId,
        );
    return result.when(
      success: (value) => value,
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> addComment(String content) async {
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await ref.read(channelServiceProvider).interactWithPost(
            channelId: channelId,
            postId: postId,
            type: InteractionType.comment,
            content: content,
          );

      if (result.isFailure) {
        state = AsyncValue.error(Exception(result.failure.message), StackTrace.current);
        return;
      }

      state = AsyncValue.data([...currentState, result.value]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
