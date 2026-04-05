import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  Future<Conversation> getOrCreateConversation({
    required ConversationType type,
    required String adolescentId,
  }) async {
    final url = ApiEndpoints.conversations;
    final payload = {
      'conversation_type': type == ConversationType.counselorAdolescent 
          ? 'counselor_adolescent' 
          : 'counselor_guardian',
      'adolescent_id': adolescentId,
    };
    
    print('MessagingService: Starting conversation at $url');
    print('MessagingService: Payload: $payload');

    try {
      final response = await _apiClient.post(
        url,
        data: payload,
      );
      print('MessagingService: Response received: ${response.data}');
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      print('MessagingService Error: $e');
      rethrow;
    }
  }

  /// Lists messages for a specific conversation.
  Future<List<ConversationMessage>> getMessages(String conversationId) async {
    final response = await _apiClient.get(
      ApiEndpoints.conversationMessages(conversationId),
    );
    final data = response.data as List;
    return data
        .map((e) => ConversationMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Sends a message in a conversation.
  Future<ConversationMessage> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.conversationMessages(conversationId),
      data: {'content': content},
    );
    return ConversationMessage.fromJson(response.data as Map<String, dynamic>);
  }
}
