import 'package:flutter/foundation.dart';
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
    final profileState = await ref.watch(adolescentProfileControllerProvider.future);
    final user = profileState.user;

    final adolescentId = user?.id ?? '';
    final myEmail = user?.email.toLowerCase() ?? '';
    debugPrint('[CounselorChat] ── Initializing counselor chat session ──');
    debugPrint('[CounselorChat] Profile email: $myEmail');
    debugPrint('[CounselorChat] Using effective adolescent ID: $adolescentId');

    debugPrint('[CounselorChat] Step 1: Getting or creating conversation');
    final conversationResult = await ref
        .read(messagingServiceProvider)
        .getOrCreateConversation(
          type: ConversationType.counselorAdolescent,
          adolescentId: adolescentId,
        );

    if (conversationResult.isFailure) {
      debugPrint('[CounselorChat] ✗ Failed: ${conversationResult.failure.message}');
      throw Exception(conversationResult.failure.message);
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
    return messagesResult.when(
      success: (value) {
        debugPrint('[CounselorChat] ✓ ${value.length} message(s)');
        for (int i = 0; i < value.length; i++) {
          final m = value[i];
          final preview = m.content.substring(0, m.content.length.clamp(0, 60));
          debugPrint('[CounselorChat]   [$i] ${m.senderRole} | ${m.createdAt} | "$preview"');
        }
        return CounselorChatState(
          conversation: conversation,
          counselorEmail: counselorEmail,
          messages: value,
        );
      },
      failure: (f) {
        debugPrint('[CounselorChat] ✗ Failed: ${f.message}');
        throw Exception(f.message);
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

  /// Gets the current conversation ID for use in call initiation.
  String? get conversationId => _conversationId;
}
