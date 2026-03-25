import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_chat_provider.g.dart';

/// State of the AI Chat.
class AiChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;

  AiChatState({
    required this.messages,
    this.isTyping = false,
    this.error,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }
}

@riverpod
class AiChat extends _$AiChat {
  @override
  AiChatState build() {
    return AiChatState(
      messages: MockDataService.getMockChatMessages(),
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user-123',
      receiverId: 'ai-counselor',
      messageContent: content,
      timestamp: DateTime.now(),
      messageType: MessageType.aiChat,
    );

    // Add user message to state
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
    );

    // Simulate AI thinking and response
    await Future.delayed(const Duration(seconds: 2));
    
    final aiResponseContent = MockDataService.getMockAiResponse(content);
    final aiMessage = ChatMessage(
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
      senderId: 'ai-counselor',
      receiverId: 'user-123',
      messageContent: aiResponseContent,
      timestamp: DateTime.now(),
      messageType: MessageType.aiChat,
    );

    state = state.copyWith(
      messages: [...state.messages, aiMessage],
      isTyping: false,
    );
  }
}
