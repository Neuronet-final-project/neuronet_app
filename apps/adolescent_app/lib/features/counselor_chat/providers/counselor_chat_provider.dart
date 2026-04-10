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
    
    final adolescentId = profile.getEffectiveId();
    print('DEBUG: [CounselorChat] Profile _id: ${profile.id}');
    print('DEBUG: [CounselorChat] Profile adolescent_id: ${profile.adolescentId}');
    print('DEBUG: [CounselorChat] Using effective ID: $adolescentId');

    final conversationResult = await ref
        .read(messagingServiceProvider)
        .getOrCreateConversation(
          type: ConversationType.counselorAdolescent,
          adolescentId: adolescentId,
        );

    if (conversationResult.isFailure) {
      print('DEBUG: [CounselorChat] Failed to create conversation: ${conversationResult.failure.message}');
      throw Exception(conversationResult.failure.message);
    }

    print('DEBUG: [CounselorChat] Created conversation: ${conversationResult.value.id}');
    _conversationId = conversationResult.value.id;

    final messagesResult = await ref.read(messagingServiceProvider).getMessages(_conversationId!);
    return messagesResult.when(
      success: (value) => value,
      failure: (f) {
        print('DEBUG: [CounselorChat] Failed to fetch messages: ${f.message}');
        throw Exception(f.message);
      },
    );
  }

  Future<void> sendMessage(String content) async {
    if (_conversationId == null || content.trim().isEmpty) return;

    final currentState = state.value;
    if (currentState == null) return;

    try {
      final result = await ref.read(messagingServiceProvider).sendMessage(
            conversationId: _conversationId!,
            content: content.trim(),
          );

      if (result.isFailure) {
        state = AsyncValue.error(Exception(result.failure.message), StackTrace.current);
        return;
      }

      state = AsyncValue.data([...currentState, result.value]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    if (_conversationId == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(messagingServiceProvider).getMessages(_conversationId!);
      if (result.isFailure) {
        throw Exception(result.failure.message);
      }
      return result.value;
    });
  }
}
