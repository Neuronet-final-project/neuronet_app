import 'package:flutter/foundation.dart';
import 'dart:async';
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

    // Call appropriate endpoint based on desired state
    final service = ref.read(channelServiceProvider);
    final result = newFollowed
        ? await service.subscribeToChannel(channelId)
        : await service.unsubscribeFromChannel(channelId);
    
    if (result.isFailure) {
      // For web/CORS-like network-layer failures, backend may still process the request.
      // Keep optimistic UI and reconcile from server in background.
      debugPrint('[ChannelsController] toggleFollow() uncertain result: ${result.failure.message}');
    }

    unawaited(_reconcileChannels());
  }

  Future<void> _reconcileChannels() async {
    final currentState = state.value;
    if (currentState == null) return;

    final result = await ref.read(channelServiceProvider).getAllChannels();
    if (!ref.mounted) return;
    result.when(
      success: (value) {
        state = AsyncValue.data(currentState.copyWith(channels: value, error: null));
      },
      failure: (_) {
        // Keep current optimistic state if reconciliation fails.
      },
    );
  }
}
