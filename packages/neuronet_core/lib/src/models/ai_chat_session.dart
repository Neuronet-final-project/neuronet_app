import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_session.freezed.dart';
part 'ai_chat_session.g.dart';

/// Represents an AI chat session between an adolescent and the AI assistant.
@freezed
abstract class AiChatSession with _$AiChatSession {
  const factory AiChatSession({
    required String id,
    required String adolescentId,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? lastMessageContent,
    @Default(false) bool isActive,
  }) = _AiChatSession;

  factory AiChatSession.fromJson(Map<String, dynamic> json) =>
      _$AiChatSessionFromJson(json);
}
