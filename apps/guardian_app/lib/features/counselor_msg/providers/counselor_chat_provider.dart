import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'counselor_chat_provider.freezed.dart';
part 'counselor_chat_provider.g.dart';

@freezed
abstract class GuardianChatState with _$GuardianChatState {
  const factory GuardianChatState({
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isLoading,
    String? error,
  }) = _GuardianChatState;
}

@riverpod
class GuardianChatController extends _$GuardianChatController {
  @override
  GuardianChatState build() {
    // Initialize with mock history
    return GuardianChatState(
      messages: MockDataService.getGuardianCounselorMessages(),
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final newMessage = ChatMessage(
      messageId: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'user-456', // Mock Guardian ID
      receiverId: 'counselor-1',
      messageContent: content,
      timestamp: DateTime.now(),
      messageType: MessageType.guardianChat,
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
    );

    // Simulate counselor response
    await Future.delayed(const Duration(seconds: 2));
    
    final response = ChatMessage(
      messageId: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      senderId: 'counselor-1',
      receiverId: 'user-456',
      messageContent: "Thank you for your message. I'm reviewing Alex's recent progress and will get back to you shortly with more details.",
      timestamp: DateTime.now(),
      messageType: MessageType.guardianChat,
      isRead: false,
    );

    state = state.copyWith(
      messages: [...state.messages, response],
    );
  }
}
