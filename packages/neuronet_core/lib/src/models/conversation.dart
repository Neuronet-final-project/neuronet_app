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
  const ConversationMessage._();

  const factory ConversationMessage({
    @JsonKey(name: 'message_id') required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'sender_email') required String senderEmail,
    @JsonKey(name: 'sender_role') required String senderRole,
    @Default('') String content,
    @JsonKey(name: 'message_type') @Default(MessageContentType.text) MessageContentType messageType,
    @JsonKey(name: 'attachment_url') String? attachmentUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_edited') @Default(false) bool isEdited,
    @JsonKey(name: 'is_read') @Default(false) bool isRead,
  }) = _ConversationMessage;

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageFromJson(json);

  /// Returns true if this message is a voice/audio message.
  bool get isVoiceMessage =>
      messageType == MessageContentType.audio ||
      messageType == MessageContentType.video;

  /// Returns true if this message has an attachment URL.
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  /// Returns a human-readable description of the message type for UI.
  String get typeDescription => switch (messageType) {
        MessageContentType.text => content.isEmpty ? '(empty message)' : content,
        MessageContentType.image => '📷 Image',
        MessageContentType.audio => '🎤 Voice message',
        MessageContentType.video => '🎥 Video',
        MessageContentType.file => '📎 File',
        MessageContentType.callLog => '📞 Call Log',
      };
}

/// Message content types matching backend API enum.
enum MessageContentType {
  @JsonValue('text')
  text,
  @JsonValue('image')
  image,
  @JsonValue('audio')
  audio,
  @JsonValue('video')
  video,
  @JsonValue('file')
  file,
  @JsonValue('call_log')
  callLog;

  String toJson() => name;
  static MessageContentType fromJson(String json) => values.byName(json);
}
