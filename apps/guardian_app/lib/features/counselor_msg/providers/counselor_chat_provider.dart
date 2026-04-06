import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counselor_chat_provider.freezed.dart';
part 'counselor_chat_provider.g.dart';

@freezed
abstract class CounselorChatState with _$CounselorChatState {
  const factory CounselorChatState({
    Conversation? conversation,
    @Default([]) List<ConversationMessage> messages,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isNoCounselor,
  }) = _CounselorChatState;
}

@riverpod
class CounselorChatController extends _$CounselorChatController {
  @override
  FutureOr<CounselorChatState> build(String adolescentId) async {
    try {
      final messagingService = ref.watch(messagingServiceProvider);

      debugPrint('CounselorChatController: Building for adolescentId: $adolescentId');

      // Get or create conversation
      final conversationResult = await messagingService.getOrCreateConversation(
        type: ConversationType.counselorGuardian,
        adolescentId: adolescentId,
      );

      if (conversationResult.isFailure) {
        if (conversationResult.failure.message.contains('no_assigned_counselor')) {
          return const CounselorChatState(isNoCounselor: true);
        }
        return CounselorChatState(error: conversationResult.failure.message);
      }

      final conversation = conversationResult.value;

      // Load messages
      final messagesResult = await messagingService.getMessages(conversation.id);
      if (messagesResult.isFailure) {
        return CounselorChatState(
          conversation: conversation,
          error: messagesResult.failure.message,
        );
      }

      return CounselorChatState(
        conversation: conversation,
        messages: messagesResult.value,
      );
    } catch (e) {
      if (e.toString().contains('no_assigned_counselor')) {
        return const CounselorChatState(isNoCounselor: true);
      }
      return CounselorChatState(error: e.toString());
    }
  }

  Future<void> sendMessage(String content) async {
    final currentConversation = state.value?.conversation;
    if (currentConversation == null || content.trim().isEmpty) return;

    // Optimistic update
    final tempMsg = ConversationMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: currentConversation.id,
      senderEmail: '', // Will be filled by backend
      senderRole: 'guardian',
      content: content,
      createdAt: DateTime.now(),
    );

    final previousState = state.value!;
    state = AsyncData(previousState.copyWith(
      messages: [...previousState.messages, tempMsg],
    ));

    try {
      final messagingService = ref.read(messagingServiceProvider);
      final sendResult = await messagingService.sendMessage(
        conversationId: currentConversation.id,
        content: content,
      );

      if (sendResult.isFailure) {
        state = AsyncData(previousState.copyWith(error: sendResult.failure.message));
        return;
      }

      // Refresh messages to get the real one from backend
      final messagesResult = await messagingService.getMessages(currentConversation.id);
      if (messagesResult.isSuccess) {
        state = AsyncData(previousState.copyWith(messages: messagesResult.value));
      }
    } catch (e) {
      state = AsyncData(previousState.copyWith(error: 'Failed to send message: $e'));
    }
  }
}
