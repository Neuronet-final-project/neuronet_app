import 'package:flutter/foundation.dart';
import '../errors/failures.dart';
import '../models/ai_chat_session.dart';
import '../models/chat_message.dart';
import '../models/enums.dart';
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
      debugPrint('[AiChatService] GET /ai-chat/sessions/me — status: ${response.statusCode}');
      debugPrint('[AiChatService] Response body: ${response.data}');
      final data = response.data as List;
      final sessions = data
          .map((e) => AiChatSession.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(sessions);
    } catch (e) {
      debugPrint('[AiChatService] getMySessions error: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Sends a message to an AI chat session and returns the AI's response.
  Future<Result<List<ChatMessage>>> sendMessage({
    required String sessionId,
    required String content,
  }) async {
    try {
      debugPrint('[AiChatService] POST ${ApiEndpoints.aiChatMessages(sessionId)} with content: "$content"');
      final response = await _apiClient.post(
        ApiEndpoints.aiChatMessages(sessionId),
        data: {'content': content},
      );
      debugPrint('[AiChatService] Response status: ${response.statusCode}');
      debugPrint('[AiChatService] Response body: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      final messagesRaw = data['messages'] as List?;
      if (messagesRaw == null) {
        return Result.failure(
          const UnknownFailure(message: 'No messages in response'),
        );
      }

      final messages = messagesRaw
          .map((e) => _chatMessageFromBackend(e as Map<String, dynamic>))
          .where((m) => m != null)
          .cast<ChatMessage>()
          .toList();

      return Result.success(messages);
    } catch (e) {
      debugPrint('[AiChatService] Error: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Maps backend message format to our ChatMessage model.
  /// Backend: {role: "user"|"ai", content: "...", created_at: "..."}
  /// App: ChatMessage with senderId, messageContent, timestamp
  ChatMessage? _chatMessageFromBackend(Map<String, dynamic> json) {
    try {
      final role = json['role'] as String? ?? 'ai';
      final senderId = role == 'user' ? 'user' : 'ai-assistant';
      final content = json['content'] as String? ?? '';
      final createdAtRaw = json['created_at'] as String?;
      final timestamp = createdAtRaw != null
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
          : DateTime.now();

      return ChatMessage(
        messageId: 'msg-${timestamp.millisecondsSinceEpoch}-$role',
        senderId: senderId,
        receiverId: role == 'user' ? 'ai-assistant' : 'user',
        messageContent: content,
        timestamp: timestamp,
        messageType: MessageType.aiChat,
      );
    } catch (e) {
      debugPrint('[AiChatService] Failed to parse message: $e — $json');
      return null;
    }
  }

  /// Gets all messages from a specific AI chat session.
  Future<Result<List<ChatMessage>>> getSessionMessages(
    String sessionId,
  ) async {
    try {
      debugPrint('[AiChatService] GET ${ApiEndpoints.aiChatMessages(sessionId)}');
      final response = await _apiClient.get(
        ApiEndpoints.aiChatMessages(sessionId),
      );
      debugPrint('[AiChatService] GET messages status: ${response.statusCode}');
      debugPrint('[AiChatService] GET messages body: ${response.data}');

      final data = response.data;

      if (data is List) {
        // GET returns a flat list directly
        final messages = data
            .map((e) => _chatMessageFromBackend(e as Map<String, dynamic>))
            .where((m) => m != null)
            .cast<ChatMessage>()
            .toList();
        debugPrint('[AiChatService] Parsed ${messages.length} messages');
        return Result.success(messages);
      }

      // Fallback: might be wrapped in {"messages": [...]} in some versions
      final mapData = data as Map<String, dynamic>?;
      if (mapData != null) {
        final messagesRaw = mapData['messages'] as List?;
        if (messagesRaw != null) {
          final messages = messagesRaw
              .map((e) => _chatMessageFromBackend(e as Map<String, dynamic>))
              .where((m) => m != null)
              .cast<ChatMessage>()
              .toList();
          return Result.success(messages);
        }
      }

      return Result.success([]);
    } catch (e) {
      debugPrint('[AiChatService] getSessionMessages error: $e');
      return Result.failure(failureFromException(e));
    }
  }
}
