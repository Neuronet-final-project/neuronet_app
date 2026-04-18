import 'package:flutter/foundation.dart';
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
      return const AiChatState(messages: []);
    }

    final aiChatService = ref.watch(aiChatServiceProvider);

    // Try to get existing sessions
    final sessionsResult = await aiChatService.getMySessions();
    if (sessionsResult.isFailure) {
      return const AiChatState(messages: []);
    }

    final sessions = sessionsResult.value;

    // Get or create the active session
    AiChatSession session;
    final activeSessions = sessions.where((s) => s.isActive).toList();
    if (activeSessions.isNotEmpty && sessionEffectiveId(activeSessions.first).isNotEmpty) {
      session = activeSessions.first;
    } else if (sessions.isNotEmpty && sessionEffectiveId(sessions.first).isNotEmpty) {
      session = sessions.first;
    } else {
      final createResult = await aiChatService.createSession();
      if (createResult.isFailure) {
        return const AiChatState(messages: []);
      }
      session = createResult.value;
    }

    // Load messages for the session
    final messagesResult = await aiChatService.getSessionMessages(sessionEffectiveId(session));
    if (messagesResult.isSuccess) {
      // Patch "user" senderId to the real user ID so the screen aligns bubbles correctly
      final patched = messagesResult.value.map((m) {
        if (m.senderId == 'user') return m.copyWith(senderId: userId);
        return m;
      }).toList();
      return AiChatState(
        messages: patched,
        session: session,
      );
    }

    return AiChatState(
      messages: [],
      session: session,
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final authState = ref.read(authControllerProvider);
    final userId = authState.user?.id ?? 'user';
    var currentSession = state.value?.session;

    // Create a session if none exists
    if (currentSession == null) {
      final aiChatService = ref.read(aiChatServiceProvider);
      final result = await aiChatService.createSession();
      if (result.isSuccess) {
        currentSession = result.value;
        debugPrint('[AiChat] Created session: ${sessionEffectiveId(currentSession)}');
      } else {
        debugPrint('[AiChat] Failed to create session: ${result.failure.message}');
        return;
      }
    }

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

    debugPrint('[AiChat] Sending message: "$content" to session ${sessionEffectiveId(currentSession)}');

    // Add user message to state immediately
    state = AsyncData(
      state.value!.copyWith(
        messages: [...state.value!.messages, userMessage],
        session: currentSession,
        isTyping: true,
        error: null,
      ),
    );

    // Send to backend — returns user message + AI response for this exchange
    // We keep all previous messages and append the AI response
    final result = await aiChatService.sendMessage(
      sessionId: sessionEffectiveId(currentSession),
      content: content,
    );

    if (result.isSuccess) {
      final aiMessages = result.value;
      debugPrint('[AiChat] ${aiMessages.length} message(s) from backend');

      if (aiMessages.isEmpty) {
        state = AsyncData(state.value!.copyWith(isTyping: false));
        return;
      }

      // Find the AI response (the last message with role=ai/senderId=ai-assistant)
      // We already added the user message locally, so only append the AI part
      final aiResponse = aiMessages.reversed.firstWhere(
        (m) => m.senderId == 'ai-assistant',
        orElse: () => aiMessages.last,
      );

      // Replace the locally-added user message with the backend version
      // (which has the correct timestamp from the server)
      // Also patch senderId to match the real user ID so the screen aligns it correctly
      final backendUserMessage = aiMessages.firstWhere(
        (m) => m.senderId == 'user' || m.senderId == userId,
        orElse: () => userMessage,
      ).copyWith(senderId: userId);

      // Replace the last entry (local user message) with the backend version + append AI response
      final updatedMessages = List<ChatMessage>.from(state.value!.messages);
      if (updatedMessages.isNotEmpty &&
          updatedMessages.last.senderId == userId) {
        // Replace the local user message with the backend version
        updatedMessages[updatedMessages.length - 1] = backendUserMessage;
        updatedMessages.add(aiResponse);
      } else {
        // Fallback: just append the AI response
        updatedMessages.add(aiResponse);
      }

      state = AsyncData(
        state.value!.copyWith(
          messages: updatedMessages,
          isTyping: false,
        ),
      );
    } else {
      // Backend failed — show error but keep the user message
      debugPrint('[AiChat] Backend failed: ${result.failure.message}');
      state = AsyncData(
        state.value!.copyWith(
          isTyping: false,
          error: result.failure.message,
        ),
      );
    }
  }
}
