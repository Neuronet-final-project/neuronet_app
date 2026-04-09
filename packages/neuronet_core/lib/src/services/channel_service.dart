import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'channel_service.g.dart';

class ChannelService {
  ChannelService(this._client);
  final ApiClient _client;

  /// Fetches channels followed by the current user.
  Future<Result<List<Channel>>> getMyChannels() async {
    try {
      final response = await _client.get(ApiEndpoints.myChannels);
      final list = response.data as List<dynamic>;
      final channels = list
          .map((json) => Channel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(channels);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches all available channels for discovery.
  Future<Result<List<Channel>>> getAllChannels() async {
    try {
      final response = await _client.get(ApiEndpoints.channels);
      final list = response.data as List<dynamic>;
      print('DEBUG: [ChannelService] getAllChannels() - Raw response: ${list.length} items');
      if (list.isNotEmpty) {
        print('DEBUG: [ChannelService] First channel JSON: ${list[0]}');
      }
      final channels = list
          .map((json) {
            try {
              return Channel.fromJson(json as Map<String, dynamic>);
            } catch (e, st) {
              print('DEBUG: [ChannelService] Failed to parse channel: $e\nJSON: $json\nStack: $st');
              rethrow;
            }
          })
          .toList();
      return Result.success(channels);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  // NOTE: Channel posts and interactions endpoints do NOT exist in backend.
  // These methods have been removed to prevent 404 errors at runtime.
  // Backend only supports channel subscription, not channel content management.
  //
  // Removed methods:
  // - getChannelPosts() — endpoint /channels/{id}/posts doesn't exist
  // - getChannelInteractions() — endpoint /channels/{id}/posts/{pid}/interactions doesn't exist
  // - interactWithPost() — endpoint /channels/{id}/posts/{pid}/interact doesn't exist

  /// Subscribes/unsubscribes the user to a channel.
  Future<Result<void>> subscribeToChannel(String channelId) async {
    try {
      await _client.post(ApiEndpoints.channelSubscribe(channelId));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
ChannelService channelService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return ChannelService(client);
}
