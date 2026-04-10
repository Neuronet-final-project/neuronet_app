import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'messaging_service.g.dart';

@riverpod
MessagingService messagingService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MessagingService(apiClient);
}

class MessagingService {
  MessagingService(this._apiClient);
  final ApiClient _apiClient;

  Future<Result<Conversation>> getOrCreateConversation({
    required ConversationType type,
    required String adolescentId,
  }) async {
    if (adolescentId.isEmpty) {
      return Result.failure(
        const UnknownFailure(message: 'Adolescent ID is missing. Please re-login to refresh your profile.'),
      );
    }

    final url = ApiEndpoints.conversations;
    final payload = {
      'conversation_type': type == ConversationType.counselorAdolescent
          ? 'counselor_adolescent'
          : 'counselor_guardian',
      'adolescent_id': adolescentId,
    };

    print('DEBUG: [MessagingService] POST $url with payload: $payload');

    try {
      final response = await _apiClient.post(url, data: payload);
      final conversation = Conversation.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(conversation);
    } catch (e) {
      print('DEBUG: [MessagingService] Failed to create conversation: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Lists messages for a specific conversation.
  Future<Result<List<ConversationMessage>>> getMessages(
    String conversationId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.conversationMessages(conversationId),
      );
      final data = response.data as List;
      final messages = data
          .map((e) => ConversationMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(messages);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Sends a message in a conversation.
  Future<Result<ConversationMessage>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.conversationMessages(conversationId),
        data: {'content': content},
      );
      final message = ConversationMessage.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(message);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}
