import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

enum ConversationType {
  @JsonValue('counselor_adolescent')
  counselorAdolescent,
  @JsonValue('counselor_guardian')
  counselorGuardian,
}

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    @JsonKey(name: 'conversation_id') required String id,
    @JsonKey(name: 'conversation_type') required ConversationType type,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    required List<String> participants,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
abstract class ConversationMessage with _$ConversationMessage {
  const factory ConversationMessage({
    @JsonKey(name: 'message_id') required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_email') required String senderEmail,
    @JsonKey(name: 'sender_role') required String senderRole,
    required String content,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _ConversationMessage;

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageFromJson(json);
}
