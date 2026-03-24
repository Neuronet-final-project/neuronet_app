import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String messageId,
    required String senderId,
    required String receiverId,
    required String messageContent,
    required DateTime timestamp,
    required MessageType messageType,
    String? conversationId,
    @Default(false) bool isRead,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
abstract class SendMessageRequest with _$SendMessageRequest {
  const factory SendMessageRequest({
    required String receiverId,
    required String content,
    required MessageType messageType,
    String? conversationId,
  }) = _SendMessageRequest;

  factory SendMessageRequest.fromJson(Map<String, dynamic> json) =>
      _$SendMessageRequestFromJson(json);
}
