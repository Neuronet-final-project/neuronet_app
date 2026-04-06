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
      final channels = list
          .map((json) => Channel.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(channels);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches posts for a specific channel.
  Future<Result<List<ChannelPost>>> getChannelPosts(String channelId) async {
    try {
      final response = await _client.get(ApiEndpoints.channelPosts(channelId));
      final list = response.data as List<dynamic>;
      final posts = list
          .map((json) => ChannelPost.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(posts);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches interactions (comments/reactions) for a specific post.
  Future<Result<List<ChannelInteraction>>> getChannelInteractions({
    required String channelId,
    required String postId,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.channelInteractions(channelId, postId),
      );
      final list = response.data as List<dynamic>;
      final interactions = list
          .map((json) => ChannelInteraction.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(interactions);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Subscribes/unsubscribes the user to a channel.
  Future<Result<void>> subscribeToChannel(String channelId) async {
    try {
      await _client.post(ApiEndpoints.channelSubscribe(channelId));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Interacts with a post (like, comment, etc.).
  Future<Result<ChannelInteraction>> interactWithPost({
    required String channelId,
    required String postId,
    required InteractionType type,
    String? content,
  }) async {
    try {
      final response = await _client.post(
        ApiEndpoints.channelInteract(channelId, postId),
        data: {
          'interaction_type': type.name,
          if (content != null) 'content': content,
        },
      );
      final interaction = ChannelInteraction.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(interaction);
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
