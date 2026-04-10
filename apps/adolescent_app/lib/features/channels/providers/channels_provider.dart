import 'package:flutter/foundation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channels_provider.g.dart';

@riverpod
class ChannelsController extends _$ChannelsController {
  @override
  FutureOr<List<Channel>> build() async {
    debugPrint('[ChannelsController] build() - Fetching all available channels');
    final result = await ref.watch(channelServiceProvider).getAllChannels();
    return result.when(
      success: (value) {
        debugPrint('[ChannelsController] Successfully fetched ${value.length} channels');
        return value;
      },
      failure: (f) {
        debugPrint('[ChannelsController] Failed to fetch channels: ${f.message}');
        throw Exception(f.message);
      },
    );
  }

  Future<void> toggleFollow(String channelId) async {
    final currentState = state.value;
    if (currentState == null) {
      debugPrint('[ChannelsController] toggleFollow() called but state is null');
      return;
    }

    final channel = currentState.firstWhere(
      (c) => c.channelId == channelId,
      orElse: () => throw Exception('Channel $channelId not found'),
    );
    final newFollowed = !channel.isFollowed;
    debugPrint('[ChannelsController] toggleFollow($channelId) - Current: ${channel.isFollowed}, New: $newFollowed');

    // Optimistic update
    state = AsyncValue.data(
      currentState.map((c) {
        if (c.channelId == channelId) {
          return c.copyWith(
            isFollowed: newFollowed,
            subscriberCount: c.subscriberCount + (newFollowed ? 1 : -1),
          );
        }
        return c;
      }).toList(),
    );
    debugPrint('[ChannelsController] Optimistic update applied');

    try {
      final result = await ref.read(channelServiceProvider).subscribeToChannel(channelId);
      if (result.isFailure) {
        debugPrint('[ChannelsController] toggleFollow API failed: ${result.failure.message}');
        // Rollback optimistic update by refetching
        state = AsyncValue.error(Exception(result.failure.message), StackTrace.current);
      } else {
        debugPrint('[ChannelsController] toggleFollow API succeeded');
      }
    } catch (e, st) {
      debugPrint('[ChannelsController] toggleFollow exception: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

// NOTE: Channel posts and comments controllers removed.
// Backend does NOT support channel posts or interactions.
// These endpoints return 404:
// - GET /channels/{id}/posts
// - GET /channels/{id}/posts/{pid}/interactions
// - POST /channels/{id}/posts/{pid}/interact
//
// If channel content features are needed, the backend must be updated first.
