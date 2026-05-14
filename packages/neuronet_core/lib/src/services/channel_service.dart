import 'package:flutter/foundation.dart';
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
      debugPrint('[ChannelService] getAllChannels() - Raw response: ${list.length} items');
      final channels = list
          .map((json) {
            try {
              return Channel.fromJson(json as Map<String, dynamic>);
            } catch (e, st) {
              debugPrint('[ChannelService] Failed to parse channel: $e\nJSON: $json\nStack: $st');
              rethrow;
            }
          })
          .toList();
      return Result.success(channels);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Subscribes the user to a channel.
  Future<Result<void>> subscribeToChannel(String channelId) async {
    try {
      await _client.post(ApiEndpoints.channelSubscribe(channelId));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Unsubscribes the user from a channel.
  Future<Result<void>> unsubscribeFromChannel(String channelId) async {
    try {
      await _client.post(ApiEndpoints.channelUnsubscribe(channelId));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  // ─── Channel Posts ─────────────────────────────────────────────

  /// Fetches posts for a channel, newest first.
  Future<Result<List<ChannelPost>>> getChannelPosts(
    String channelId, {
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiEndpoints.channelPosts(channelId),
        queryParameters: {'skip': skip, 'limit': limit},
      );
      final list = response.data as List<dynamic>;
      final posts = list
          .map((json) => ChannelPost.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(posts);
    } catch (e) {
      debugPrint('[ChannelService] getChannelPosts failed: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches a single post by ID.
  Future<Result<ChannelPost>> getPost(String channelId, String postId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.channelPost(channelId, postId),
      );
      return Result.success(
        ChannelPost.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  // ─── Interactions ──────────────────────────────────────────────

  /// Fetches interactions (reactions/comments) for a post.
  Future<Result<List<ChannelInteraction>>> getPostInteractions(
    String channelId,
    String postId, {
    String? interactionType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (interactionType != null) {
        queryParams['interaction_type'] = interactionType;
      }
      final response = await _client.get(
        ApiEndpoints.channelInteractions(channelId, postId),
        queryParameters: queryParams,
      );
      final list = response.data as List<dynamic>;
      final interactions = list
          .map((json) => ChannelInteraction.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(interactions);
    } catch (e) {
      debugPrint('[ChannelService] getPostInteractions failed: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Adds a reaction to a post.
  Future<Result<ChannelInteraction>> reactToPost(
    String channelId,
    String postId,
    String reactionType,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.channelInteract(channelId, postId),
        data: {
          'interaction_type': 'reaction',
          'reaction_type': reactionType,
        },
      );
      return Result.success(
        ChannelInteraction.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Adds a comment to a post.
  Future<Result<ChannelInteraction>> commentOnPost(
    String channelId,
    String postId,
    String content,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.channelInteract(channelId, postId),
        data: {
          'interaction_type': 'comment',
          'content': content,
        },
      );
      return Result.success(
        ChannelInteraction.fromJson(response.data as Map<String, dynamic>),
      );
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
