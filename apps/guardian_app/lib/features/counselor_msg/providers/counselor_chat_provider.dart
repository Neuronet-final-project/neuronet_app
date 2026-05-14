import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/providers/auth_provider.dart';

part 'counselor_chat_provider.freezed.dart';
part 'counselor_chat_provider.g.dart';

@freezed
abstract class CounselorChatState with _$CounselorChatState {
  const factory CounselorChatState({
    Conversation? conversation,
    /// Counselor email extracted from conversation participants.
    String? counselorEmail,
    @Default([]) List<ConversationMessage> messages,
    @Default(false) bool isLoading,
    String? error,
    @Default(false) bool isNoCounselor,
  }) = _CounselorChatState;
}

@riverpod
class CounselorChatController extends _$CounselorChatController {
  bool _isRefreshing = false;
  bool _isSending = false;

  @override
  FutureOr<CounselorChatState> build(String adolescentId) async {
    // Listen to FCM chat events for instant refresh
    final notifService = ref.read(notificationServiceProvider.notifier);
    final fcmSub = notifService.onChatMessage.listen((_) {
      debugPrint('[GuardianCounselorChat] 📨 FCM chat event received — refreshing immediately');
      _silentRefresh();
    });

    // Add aggressive periodic polling every 2 seconds as a fallback and to match web dashboard behavior
    final pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _silentRefresh();
    });

    ref.onDispose(() {
      fcmSub.cancel();
      pollTimer.cancel();
    });

    try {
      final messagingService = ref.watch(messagingServiceProvider);

      // Get guardian email from auth to filter out from participants
      final authState = ref.watch(authControllerProvider);
      final guardianEmail = (authState.user?.email ?? '').toLowerCase();
      debugPrint('[GuardianCounselorChat] Guardian email: $guardianEmail');

      debugPrint('[GuardianCounselorChat] ── Initializing guardian counselor chat ──');
      debugPrint('[GuardianCounselorChat]   - Adolescent ID: $adolescentId');
      debugPrint('[GuardianCounselorChat] Step 1: Getting or creating conversation (type=counselor_guardian)');

      final conversationResult = await messagingService.getOrCreateConversation(
        type: ConversationType.counselorGuardian,
        adolescentId: adolescentId,
      );

      if (conversationResult.isFailure) {
        if (conversationResult.failure.message.contains('no_assigned_counselor')) {
          debugPrint('[GuardianCounselorChat] ✗ No counselor assigned to this adolescent');
          return const CounselorChatState(isNoCounselor: true);
        }
        debugPrint('[GuardianCounselorChat] ✗ Failed to create conversation: ${conversationResult.failure.message}');
        return CounselorChatState(error: conversationResult.failure.message);
      }

      final conversation = conversationResult.value;
      debugPrint('[GuardianCounselorChat] ✓ Conversation: ${conversation.id}');
      debugPrint('[GuardianCounselorChat]   Participants: ${conversation.participants}');

      // Extract counselor email: filter out the guardian's own email
      final counselorEmail = conversation.participants
          .where((p) => p.toLowerCase() != guardianEmail)
          .firstOrNull;
      debugPrint('[GuardianCounselorChat]   Counselor: $counselorEmail');

      debugPrint('[GuardianCounselorChat] Step 2: Fetching messages');
      final messagesResult = await messagingService.getMessages(conversation.id);
      if (messagesResult.isFailure) {
        debugPrint('[GuardianCounselorChat] ✗ Failed to fetch: ${messagesResult.failure.message}');
        return CounselorChatState(
          conversation: conversation,
          counselorEmail: counselorEmail,
          error: messagesResult.failure.message,
        );
      }

      debugPrint('[GuardianCounselorChat] ✓ ${messagesResult.value.length} message(s)');
      for (int i = 0; i < messagesResult.value.length; i++) {
        final m = messagesResult.value[i];
        final preview = m.content.substring(0, m.content.length.clamp(0, 60));
        debugPrint('[GuardianCounselorChat]   [$i] ${m.senderRole} | ${m.createdAt} | "$preview"');
      }

      return CounselorChatState(
        conversation: conversation,
        counselorEmail: counselorEmail,
        messages: messagesResult.value,
      );
    } catch (e) {
      if (e.toString().contains('no_assigned_counselor')) {
        debugPrint('[GuardianCounselorChat] ✗ No counselor assigned (exception path)');
        return const CounselorChatState(isNoCounselor: true);
      }
      debugPrint('[GuardianCounselorChat] ✗ Unexpected error: $e');
      return CounselorChatState(error: e.toString());
    }
  }

  // ── Silent refresh triggered by FCM ──────────────────────────────────────────

  Future<void> _silentRefresh() async {
    final currentConversation = state.value?.conversation;
    if (currentConversation == null || _isRefreshing || _isSending) return;

    _isRefreshing = true;
    try {
      final result = await ref.read(messagingServiceProvider).getMessages(currentConversation.id);
      if (result.isSuccess) {
        final currentState = state.value;
        if (currentState != null) {
          final newMsgs = result.value;
          final oldMsgs = currentState.messages;
          final latestNewId = newMsgs.isNotEmpty ? newMsgs.last.id : null;
          final latestOldId = oldMsgs.isNotEmpty ? oldMsgs.last.id : null;
          if (true) { // Force update whenever new data arrives for real-time feel
            debugPrint('[GuardianCounselorChat] 🔄 Aggressive refresh: ${oldMsgs.length} → ${newMsgs.length} messages');
            state = AsyncValue.data(currentState.copyWith(
              messages: _mergeAndSortMessages(oldMsgs, newMsgs),
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('[GuardianCounselorChat] ⚠ Silent refresh failed: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  List<ConversationMessage> _mergeAndSortMessages(
    List<ConversationMessage> existing,
    List<ConversationMessage> incoming,
  ) {
    final Map<String, ConversationMessage> messageMap = {
      for (var m in existing) m.id: m,
    };

    // Incoming messages from server always win
    for (var m in incoming) {
      messageMap[m.id] = m;
    }

    final sortedList = messageMap.values.toList();
    sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return sortedList;
  }

  Future<void> sendMessage(String content) async {
    final currentConversation = state.value?.conversation;
    if (currentConversation == null || content.trim().isEmpty || _isSending) return;

    _isSending = true;

    debugPrint('[GuardianCounselorChat] ── Sending message ──');
    debugPrint('[GuardianCounselorChat]   - Conversation ID: ${currentConversation.id}');
    debugPrint('[GuardianCounselorChat]   - Content: "$content"');

    // Optimistic update
    final tempMsg = ConversationMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: currentConversation.id,
      senderEmail: '',
      senderRole: AppConstants.guardianRole,
      content: content,
      createdAt: DateTime.now(),
    );

    final previousState = state.value!;
    state = AsyncData(previousState.copyWith(
      messages: [...previousState.messages, tempMsg],
    ));
    debugPrint('[GuardianCounselorChat]   - Optimistic update applied');

    try {
      final messagingService = ref.read(messagingServiceProvider);
      final sendResult = await messagingService.sendMessage(
        conversationId: currentConversation.id,
        content: content,
      );

      if (sendResult.isFailure) {
        debugPrint('[GuardianCounselorChat] ✗ Send failed: ${sendResult.failure.message}');
        state = AsyncData(previousState.copyWith(error: sendResult.failure.message));
        return;
      }

      final sentMessage = sendResult.value;
      debugPrint('[GuardianCounselorChat] ✓ Message sent successfully');
      debugPrint('[GuardianCounselorChat]   - Message ID: ${sentMessage.id}');

      state = AsyncData(previousState.copyWith(
        messages: _mergeAndSortMessages(previousState.messages, [sentMessage]),
      ));
      debugPrint('[GuardianCounselorChat] ── Guardian message send complete ──');
    } catch (e) {
      debugPrint('[GuardianCounselorChat] ✗ Send exception: $e');
      state = AsyncData(previousState.copyWith(error: 'Failed to send message: $e'));
    } finally {
      _isSending = false;
    }
  }

  Future<void> sendVoiceMessage(String attachmentUrl) async {
    final currentConversation = state.value?.conversation;
    if (currentConversation == null) return;

    debugPrint('[GuardianCounselorChat] ── Sending voice message ──');

    try {
      final messagingService = ref.read(messagingServiceProvider);
      final sendResult = await messagingService.sendMessage(
        conversationId: currentConversation.id,
        content: '',
        messageType: MessageContentType.audio,
        attachmentUrl: attachmentUrl,
      );

      if (sendResult.isFailure) {
        debugPrint('[GuardianCounselorChat] ✗ Send failed: ${sendResult.failure.message}');
        final previousState = state.value!;
        state = AsyncData(previousState.copyWith(error: sendResult.failure.message));
        return;
      }

      final sentMessage = sendResult.value;
      debugPrint('[GuardianCounselorChat] ✓ Voice message sent successfully');

      final previousState = state.value!;
      state = AsyncData(previousState.copyWith(
        messages: _mergeAndSortMessages(previousState.messages, [sentMessage]),
      ));
    } catch (e) {
      debugPrint('[GuardianCounselorChat] ✗ Send exception: $e');
      final previousState = state.value!;
      state = AsyncData(previousState.copyWith(error: 'Failed to send voice message: $e'));
    }
  }

  Future<void> sendMediaMessage(String attachmentUrl, MessageContentType messageType) async {
    final currentConversation = state.value?.conversation;
    if (currentConversation == null) return;

    debugPrint('[GuardianCounselorChat] ── Sending ${messageType.name} message ──');

    try {
      final messagingService = ref.read(messagingServiceProvider);
      final sendResult = await messagingService.sendMessage(
        conversationId: currentConversation.id,
        content: '',
        messageType: messageType,
        attachmentUrl: attachmentUrl,
      );

      if (sendResult.isFailure) {
        debugPrint('[GuardianCounselorChat] ✗ Send failed: ${sendResult.failure.message}');
        final previousState = state.value!;
        state = AsyncData(previousState.copyWith(error: sendResult.failure.message));
        return;
      }

      final sentMessage = sendResult.value;
      debugPrint('[GuardianCounselorChat] ✓ ${messageType.name} message sent successfully');

      final previousState = state.value!;
      state = AsyncData(previousState.copyWith(
        messages: _mergeAndSortMessages(previousState.messages, [sentMessage]),
      ));
    } catch (e) {
      debugPrint('[GuardianCounselorChat] ✗ Send exception: $e');
      final previousState = state.value!;
      state = AsyncData(previousState.copyWith(error: 'Failed to send ${messageType.name} message: $e'));
    }
  }

  /// Gets the current conversation ID for use in call initiation.
  String? get conversationId => state.value?.conversation?.id;
}
