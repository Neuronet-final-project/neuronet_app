import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/providers/profile_provider.dart';

part 'counselor_chat_provider.g.dart';

@riverpod
class CounselorChatController extends _$CounselorChatController {
  String? _conversationId;

  @override
  FutureOr<List<ConversationMessage>> build() async {
    final profile = await ref.watch(adolescentProfileControllerProvider.future);
    
    final conversation = await ref
        .read(messagingServiceProvider)
        .getOrCreateConversation(
          type: ConversationType.counselorAdolescent,
          adolescentId: profile.id,
        );
    
    _conversationId = conversation.id;
    
    return ref.read(messagingServiceProvider).getMessages(conversation.id);
  }

  Future<void> sendMessage(String content) async {
    if (_conversationId == null || content.trim().isEmpty) return;
    
    final currentState = state.value;
    if (currentState == null) return;

    try {
      final newMessage = await ref.read(messagingServiceProvider).sendMessage(
            conversationId: _conversationId!,
            content: content.trim(),
          );
      
      state = AsyncValue.data([...currentState, newMessage]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    if (_conversationId == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => 
      ref.read(messagingServiceProvider).getMessages(_conversationId!)
    );
  }
}
