import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channels_provider.freezed.dart';
part 'channels_provider.g.dart';

@freezed
abstract class ChannelsState with _$ChannelsState {
  const factory ChannelsState({
    @Default([]) List<Channel> channels,
    @Default(false) bool isLoading,
    String? error,
  }) = _ChannelsState;
}

@riverpod
class ChannelsController extends _$ChannelsController {
  @override
  FutureOr<ChannelsState> build() async {
    debugPrint('[ChannelsController] build() - Fetching all available channels');
    final service = ref.watch(channelServiceProvider);
    final result = await service.getAllChannels();
    
    return result.when(
      success: (value) {
        debugPrint('[ChannelsController] Successfully fetched ${value.length} channels');
        return ChannelsState(channels: value, isLoading: false);
      },
      failure: (f) {
        debugPrint('[ChannelsController] Failed to fetch channels: ${f.message}');
        return ChannelsState(isLoading: false, error: f.message);
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(channelServiceProvider);
      final result = await service.getAllChannels();
      return result.when(
        success: (value) => ChannelsState(channels: value, isLoading: false),
        failure: (f) => ChannelsState(isLoading: false, error: f.message),
      );
    });
  }

  Future<void> toggleFollow(String channelId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final channels = currentState.channels;
    final index = channels.indexWhere((c) => c.channelId == channelId);
    if (index == -1) return;

    final channel = channels[index];
    final newFollowed = !channel.isFollowed;

    // Optimistic update
    final updatedChannels = List<Channel>.from(channels);
    updatedChannels[index] = channel.copyWith(
      isFollowed: newFollowed,
      subscriberCount: channel.subscriberCount + (newFollowed ? 1 : -1),
    );
    
    state = AsyncValue.data(currentState.copyWith(channels: updatedChannels));

    try {
      final result = await ref.read(channelServiceProvider).subscribeToChannel(channelId);
      if (result.isFailure) {
        // Rollback on failure
        state = AsyncValue.data(currentState.copyWith(error: result.failure.message));
      }
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(error: e.toString()));
    }
  }
}
