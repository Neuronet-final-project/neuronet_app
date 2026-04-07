import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';

part 'ai_chat_provider.g.dart';

/// State of the AI Chat.
class AiChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;
  final AiChatSession? session;

  const AiChatState({
    required this.messages,
    this.isTyping = false,
    this.error,
    this.session,
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
    AiChatSession? session,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      session: session ?? this.session,
    );
  }
}

@riverpod
class AiChat extends _$AiChat {
  @override
  Future<AiChatState> build() async {
    final authState = ref.watch(authControllerProvider);
    final userId = authState.user?.id;
    if (userId == null) {
      return AiChatState(messages: []);
    }

    final aiChatService = ref.watch(aiChatServiceProvider);

    // Try to get existing sessions
    final sessionsResult = await aiChatService.getMySessions();
    if (sessionsResult.isFailure) {
      // Fall back to mock data if backend is unavailable
      return AiChatState(
        messages: MockDataService.getMockChatMessages(),
      );
    }

    final sessions = sessionsResult.value;

    // Get or create the active session
    AiChatSession session;
    final activeSessions = sessions.where((s) => s.isActive).toList();
    if (activeSessions.isNotEmpty) {
      session = activeSessions.first;
    } else if (sessions.isNotEmpty) {
      session = sessions.first;
    } else {
      final createResult = await aiChatService.createSession();
      if (createResult.isFailure) {
        return AiChatState(
          messages: MockDataService.getMockChatMessages(),
        );
      }
      session = createResult.value;
    }

    // Load messages for the session
    final messagesResult = await aiChatService.getSessionMessages(session.id);
    if (messagesResult.isSuccess) {
      return AiChatState(
        messages: messagesResult.value,
        session: session,
      );
    }

    // Fall back to mock data
    return AiChatState(
      messages: MockDataService.getMockChatMessages(),
      session: session,
    );
  }

  Future<void> sendMessage(String content) async {
    final currentSession = state.value?.session;
    if (currentSession == null || content.trim().isEmpty) return;

    final authState = ref.read(authControllerProvider);
    final userId = authState.user?.id ?? 'user';
    final aiChatService = ref.read(aiChatServiceProvider);

    // Build user message for local state immediately
    final userMessage = ChatMessage(
      messageId: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: userId,
      receiverId: 'ai-assistant',
      messageContent: content,
      timestamp: DateTime.now(),
      messageType: MessageType.aiChat,
    );

    // Add user message to state immediately
    state = AsyncData(
      state.value!.copyWith(
        messages: [...state.value!.messages, userMessage],
        isTyping: true,
      ),
    );

    // Send to backend — the AI response comes back directly
    final result = await aiChatService.sendMessage(
      sessionId: currentSession.id,
      content: content,
    );

    if (result.isSuccess) {
      state = AsyncData(
        state.value!.copyWith(
          messages: [...state.value!.messages, result.value],
          isTyping: false,
        ),
      );
    } else {
      // If backend failed, generate a mock response so the UX doesn't break
      final fallbackMessage = ChatMessage(
        messageId: 'msg-${DateTime.now().millisecondsSinceEpoch + 1}',
        senderId: 'ai-assistant',
        receiverId: userId,
        messageContent: MockDataService.getMockAiResponse(content),
        timestamp: DateTime.now(),
        messageType: MessageType.aiChat,
      );
      state = AsyncData(
        state.value!.copyWith(
          messages: [...state.value!.messages, fallbackMessage],
          isTyping: false,
          error: result.failure.message,
        ),
      );
    }
  }
}
