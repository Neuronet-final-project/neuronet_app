import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/providers/profile_provider.dart';

part 'counselor_chat_provider.freezed.dart';
part 'counselor_chat_provider.g.dart';

@freezed
abstract class CounselorChatState with _$CounselorChatState {
  const factory CounselorChatState({
    Conversation? conversation,
    /// Counselor email extracted from conversation participants.
    String? counselorEmail,
    @Default([]) List<ConversationMessage> messages,
  }) = _CounselorChatState;
}

@riverpod
class CounselorChatController extends _$CounselorChatController {
  String? _conversationId;
  bool _isSending = false;

  /// Whether a message is currently being sent to the backend.
  bool get isSending => _isSending;

  @override
  FutureOr<CounselorChatState> build() async {
    // Clean up FCM subscription when provider is disposed
    ref.onDispose(() {
    });

    // Listen to FCM chat events for instant refresh
    final notifService = ref.read(notificationServiceProvider.notifier);
    final fcmSub = notifService.onChatMessage.listen((_) {
      debugPrint('[CounselorChat] 📨 FCM chat event received — refreshing immediately');
      _silentRefresh();
    });
    ref.onDispose(fcmSub.cancel);

    final profileState = await ref.watch(adolescentProfileControllerProvider.future);
    final user = profileState.user;

    final adolescentId = user?.id ?? '';
    final myEmail = user?.email.toLowerCase() ?? '';
    debugPrint('[CounselorChat] ── Initializing counselor chat session ──');
    debugPrint('[CounselorChat] Profile email: $myEmail');
    debugPrint('[CounselorChat] Using effective adolescent ID: $adolescentId');

    String? counselorEmail;
    Conversation? existingConversation;

    // First, try to get existing conversation (for adolescents who were chatting before)
    if (adolescentId.isNotEmpty) {
      debugPrint('[CounselorChat] Step 1: Checking for existing conversation');
      final conversationResult = await ref
          .read(messagingServiceProvider)
          .getOrCreateConversation(
            type: ConversationType.counselorAdolescent,
            adolescentId: adolescentId,
          );

      if (conversationResult.isSuccess) {
        existingConversation = conversationResult.value;
        _conversationId = existingConversation.id;
        
        // Extract counselor email from participants
        counselorEmail = existingConversation.participants
            .where((p) => p.toLowerCase() != myEmail)
            .firstOrNull;
        
        debugPrint('[CounselorChat] ✓ Found existing conversation: ${existingConversation.id}');
        debugPrint('[CounselorChat]   Counselor: $counselorEmail');
        
        // Load messages for existing conversation
        final messagesResult = await ref.read(messagingServiceProvider).getMessages(_conversationId!);
        
        if (messagesResult.isSuccess) {
          debugPrint('[CounselorChat] ✓ Loaded ${messagesResult.value.length} message(s)');
          
          return CounselorChatState(
            conversation: existingConversation,
            counselorEmail: counselorEmail,
            messages: messagesResult.value,
          );
        }
      } else {
        debugPrint('[CounselorChat] ⚠ No existing conversation (${conversationResult.failure.message})');
        
        // No existing conversation - check for counselor assignment
        final authService = ref.read(authServiceProvider);
        final counselorsResult = await authService.getAssignedCounselors(adolescentId);
        
        counselorsResult.when(
          success: (counselors) {
            if (counselors.isNotEmpty) {
              counselorEmail = counselors.first['counselor_email'] as String?;
              debugPrint('[CounselorChat] ✓ Assigned counselor: $counselorEmail');
            } else {
              debugPrint('[CounselorChat] ⚠ No counselor assigned yet');
            }
          },
          failure: (f) {
            debugPrint('[CounselorChat] ✗ Failed to fetch assigned counselor: ${f.message}');
          },
        );
      }
    }

    return CounselorChatState(
      conversation: existingConversation,
      counselorEmail: counselorEmail,
    );
  }

  /// Silently refreshes messages without showing loading state
  Future<void> _silentRefresh() async {
    if (_conversationId == null) return;
    
    try {
      final result = await ref.read(messagingServiceProvider).getMessages(_conversationId!);
      if (result.isSuccess) {
        final currentState = state.value;
        if (currentState != null) {
          final newMessageCount = result.value.length;
          final oldMessageCount = currentState.messages.length;
          
          if (newMessageCount != oldMessageCount) {
            debugPrint('[CounselorChat] 🔄 Silent refresh: $oldMessageCount → $newMessageCount messages');
            state = AsyncValue.data(currentState.copyWith(messages: result.value));
          }
        }
      }
    } catch (e) {
      debugPrint('[CounselorChat] ⚠ Silent refresh failed: $e');
    }
  }

  /// Initialize conversation after approval is granted
  Future<void> initializeConversation() async {
    // If conversation already exists, don't recreate it
    if (_conversationId != null && state.value?.conversation != null) {
      debugPrint('[CounselorChat] Conversation already initialized: $_conversationId');
      return;
    }

    final profileState = await ref.read(adolescentProfileControllerProvider.future);
    final user = profileState.user;

    final adolescentId = user?.id ?? '';
    final myEmail = user?.email.toLowerCase() ?? '';

    debugPrint('[CounselorChat] Step 1: Getting or creating conversation');
    final conversationResult = await ref
        .read(messagingServiceProvider)
        .getOrCreateConversation(
          type: ConversationType.counselorAdolescent,
          adolescentId: adolescentId,
        );

    if (conversationResult.isFailure) {
      debugPrint('[CounselorChat] ✗ Failed: ${conversationResult.failure.message}');
      state = AsyncValue.error(Exception(conversationResult.failure.message), StackTrace.current);
      return;
    }

    final conversation = conversationResult.value;
    debugPrint('[CounselorChat] ✓ Conversation: ${conversation.id}');
    debugPrint('[CounselorChat]   Participants: ${conversation.participants}');
    _conversationId = conversation.id;

    // Extract counselor email: participants minus the adolescent's own email
    final counselorEmail = conversation.participants
        .where((p) => p.toLowerCase() != myEmail)
        .firstOrNull;
    debugPrint('[CounselorChat]   Counselor: $counselorEmail');

    debugPrint('[CounselorChat] Step 2: Fetching messages');
    final messagesResult = await ref.read(messagingServiceProvider).getMessages(_conversationId!);
    
    messagesResult.when(
      success: (value) {
        debugPrint('[CounselorChat] ✓ ${value.length} message(s)');
        for (int i = 0; i < value.length; i++) {
          final m = value[i];
          final preview = m.content.substring(0, m.content.length.clamp(0, 60));
          debugPrint('[CounselorChat]   [$i] ${m.senderRole} | ${m.createdAt} | "$preview"');
        }
        
        state = AsyncValue.data(CounselorChatState(
          conversation: conversation,
          counselorEmail: counselorEmail,
          messages: value,
        ));
      },
      failure: (f) {
        debugPrint('[CounselorChat] ✗ Failed: ${f.message}');
        state = AsyncValue.error(Exception(f.message), StackTrace.current);
      },
    );
  }

  Future<void> sendMessage(String content) async {
    if (_conversationId == null || content.trim().isEmpty || _isSending) return;

    final currentState = state.value;
    if (currentState == null) return;

    _isSending = true;
    state = AsyncValue.data(currentState);

    debugPrint('[CounselorChat] ── Sending: "$content" ──');

    try {
      final result = await ref.read(messagingServiceProvider).sendMessage(
            conversationId: _conversationId!,
            content: content.trim(),
          );

      if (result.isFailure) {
        debugPrint('[CounselorChat] ✗ Send failed: ${result.failure.message}');
        state = AsyncValue.error(Exception(result.failure.message), StackTrace.current);
        return;
      }

      final sentMessage = result.value;
      debugPrint('[CounselorChat] ✓ Sent: id=${sentMessage.id} role=${sentMessage.senderRole}');

      state = AsyncValue.data(currentState.copyWith(
        messages: [...currentState.messages, sentMessage],
      ));
    } catch (e, st) {
      debugPrint('[CounselorChat] ✗ Exception: $e');
      state = AsyncValue.error(e, st);
    } finally {
      _isSending = false;
      state = AsyncValue.data(state.value ?? currentState);
    }
  }

  Future<void> sendVoiceMessage(String attachmentUrl) async {
    if (_conversationId == null || _isSending) return;

    final currentState = state.value;
    if (currentState == null) return;

    _isSending = true;
    state = AsyncValue.data(currentState);

    debugPrint('[CounselorChat] ── Sending voice message ──');

    try {
      final result = await ref.read(messagingServiceProvider).sendMessage(
            conversationId: _conversationId!,
            content: '',
            messageType: MessageContentType.audio,
            attachmentUrl: attachmentUrl,
          );

      if (result.isFailure) {
        debugPrint('[CounselorChat] ✗ Send failed: ${result.failure.message}');
        state = AsyncValue.error(Exception(result.failure.message), StackTrace.current);
        return;
      }

      final sentMessage = result.value;
      debugPrint('[CounselorChat] ✓ Sent voice message: id=${sentMessage.id}');

      state = AsyncValue.data(currentState.copyWith(
        messages: [...currentState.messages, sentMessage],
      ));
    } catch (e, st) {
      debugPrint('[CounselorChat] ✗ Exception: $e');
      state = AsyncValue.error(e, st);
    } finally {
      _isSending = false;
      state = AsyncValue.data(state.value ?? currentState);
    }
  }

  /// Sends a media message (image or video) by uploading the file first,
  /// then sending a message with attachment URL.
  Future<void> sendMediaMessage(String attachmentUrl, MessageContentType messageType) async {
    if (_conversationId == null || _isSending) return;

    final currentState = state.value;
    if (currentState == null) return;

    _isSending = true;
    state = AsyncValue.data(currentState);

    debugPrint('[CounselorChat] ── Sending ${messageType.name} message ──');

    try {
      final result = await ref.read(messagingServiceProvider).sendMessage(
            conversationId: _conversationId!,
            content: '',
            messageType: messageType,
            attachmentUrl: attachmentUrl,
          );

      if (result.isFailure) {
        debugPrint('[CounselorChat] ✗ Send failed: ${result.failure.message}');
        state = AsyncValue.error(Exception(result.failure.message), StackTrace.current);
        return;
      }

      final sentMessage = result.value;
      debugPrint('[CounselorChat] ✓ Sent ${messageType.name} message: id=${sentMessage.id}');

      state = AsyncValue.data(currentState.copyWith(
        messages: [...currentState.messages, sentMessage],
      ));
    } catch (e, st) {
      debugPrint('[CounselorChat] ✗ Exception: $e');
      state = AsyncValue.error(e, st);
    } finally {
      _isSending = false;
      state = AsyncValue.data(state.value ?? currentState);
    }
  }

  Future<void> refresh() async {
    if (_conversationId == null) return;
    debugPrint('[CounselorChat] ── Refreshing ──');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(messagingServiceProvider).getMessages(_conversationId!);
      if (result.isFailure) {
        debugPrint('[CounselorChat] ✗ Refresh failed: ${result.failure.message}');
        throw Exception(result.failure.message);
      }
      final currentConv = state.value?.conversation;
      final currentCounselorEmail = state.value?.counselorEmail;
      debugPrint('[CounselorChat] ✓ Refreshed ${result.value.length} message(s)');
      return CounselorChatState(
        conversation: currentConv,
        counselorEmail: currentCounselorEmail,
        messages: result.value,
      );
    });
  }

  /// Marks all messages in the conversation as read by calling the backend
  Future<void> markMessagesAsRead() async {
    if (_conversationId == null) return;
    
    debugPrint('[CounselorChat] ── Marking messages as read ──');
    
    try {
      final result = await ref.read(messagingServiceProvider).markConversationAsRead(_conversationId!);
      
      if (result.isSuccess) {
        debugPrint('[CounselorChat] ✓ Messages marked as read');
        // Refresh to get updated isRead status
        await _silentRefresh();
      } else {
        debugPrint('[CounselorChat] ⚠ Failed to mark as read: ${result.failure.message}');
      }
    } catch (e) {
      debugPrint('[CounselorChat] ✗ Error marking as read: $e');
    }
  }

  /// Gets the current conversation ID for use in call initiation.
  String? get conversationId => _conversationId;

  /// Deletes a message optimistically from the UI, then calls the backend.
  Future<void> deleteMessage(String messageId) async {
    if (_conversationId == null) return;

    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic remove
    state = AsyncValue.data(currentState.copyWith(
      messages: currentState.messages.where((m) => m.id != messageId).toList(),
    ));

    try {
      final result = await ref.read(messagingServiceProvider).deleteMessage(
            conversationId: _conversationId!,
            messageId: messageId,
          );

      if (result.isFailure) {
        // Revert on failure
        debugPrint('[CounselorChat] ✗ Delete failed: ${result.failure.message}');
        state = AsyncValue.data(currentState);
      }
    } catch (e, st) {
      debugPrint('[CounselorChat] ✗ Delete exception: $e');
      state = AsyncValue.data(currentState);
    }
  }
}

/// Simple provider for total unread message count
final totalUnreadMessageCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final messagingService = ref.watch(messagingServiceProvider);
  final result = await messagingService.getTotalUnreadCount();
  
  return result.when(
    success: (count) => count,
    failure: (f) {
      debugPrint('[TotalUnreadCount] Failed to fetch: ${f.message}');
      return 0;
    },
  );
});

/// Provider that auto-refreshes unread count every 5 seconds
final autoRefreshUnreadCountProvider = StreamProvider.autoDispose<int>((ref) {
  return Stream.periodic(const Duration(seconds: 5), (_) {
    // Trigger a refresh by invalidating the future provider
    ref.invalidate(totalUnreadMessageCountProvider);
  }).asyncMap((_) async {
    // Wait for the future provider to complete
    return await ref.watch(totalUnreadMessageCountProvider.future);
  });
});
