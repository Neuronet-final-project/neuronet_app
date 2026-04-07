import '../errors/failures.dart';
import '../models/ai_chat_session.dart';
import '../models/chat_message.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_chat_service.g.dart';

@riverpod
AiChatService aiChatService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiChatService(apiClient);
}

/// Service for managing AI chat sessions and messages.
class AiChatService {
  AiChatService(this._apiClient);
  final ApiClient _apiClient;

  /// Creates a new AI chat session.
  Future<Result<AiChatSession>> createSession() async {
    try {
      final response = await _apiClient.post(ApiEndpoints.aiChatSessions);
      final session = AiChatSession.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(session);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Gets all AI chat sessions for the current user.
  Future<Result<List<AiChatSession>>> getMySessions() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.myAiSessions);
      final data = response.data as List;
      final sessions = data
          .map((e) => AiChatSession.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(sessions);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Sends a message to an AI chat session and returns the AI's response.
  Future<Result<ChatMessage>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.aiChatMessages(sessionId),
        data: {'content': content},
      );
      final message = ChatMessage.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(message);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Gets all messages from a specific AI chat session.
  Future<Result<List<ChatMessage>>> getSessionMessages(
    String sessionId,
  ) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.aiChatMessages(sessionId),
      );
      final data = response.data as List;
      final messages = data
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(messages);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}
