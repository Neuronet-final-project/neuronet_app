import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'channel_service.g.dart';

class ChannelService {
  ChannelService(this._client);
  final ApiClient _client;

  /// Fetches channels followed by the current user.
  Future<List<Channel>> getMyChannels() async {
    final response = await _client.get(ApiEndpoints.myChannels);
    final list = response.data as List<dynamic>;
    return list.map((json) => Channel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetches all available channels for discovery.
  Future<List<Channel>> getAllChannels() async {
    final response = await _client.get(ApiEndpoints.channels);
    final list = response.data as List<dynamic>;
    return list.map((json) => Channel.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetches posts for a specific channel.
  Future<List<ChannelPost>> getChannelPosts(String channelId) async {
    final response = await _client.get(ApiEndpoints.channelPosts(channelId));
    final list = response.data as List<dynamic>;
    return list.map((json) => ChannelPost.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetches interactions (comments/reactions) for a specific post.
  Future<List<ChannelInteraction>> getChannelInteractions({
    required String channelId,
    required String postId,
  }) async {
    final response = await _client.get(ApiEndpoints.channelInteractions(channelId, postId));
    final list = response.data as List<dynamic>;
    return list.map((json) => ChannelInteraction.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Subscribes/unsubscribes the user to a channel.
  Future<void> subscribeToChannel(String channelId) async {
    await _client.post(ApiEndpoints.channelSubscribe(channelId));
  }

  /// Interacts with a post (like, comment, etc.).
  Future<ChannelInteraction> interactWithPost({
    required String channelId,
    required String postId,
    required InteractionType type,
    String? content,
  }) async {
    final response = await _client.post(
      ApiEndpoints.channelInteract(channelId, postId),
      data: {
        'interaction_type': type.name,
        if (content != null) 'content': content,
      },
    );
    return ChannelInteraction.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
ChannelService channelService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return ChannelService(client);
}
