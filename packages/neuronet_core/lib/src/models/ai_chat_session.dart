import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_session.freezed.dart';
part 'ai_chat_session.g.dart';

/// Represents an AI chat session between an adolescent and the AI assistant.
@freezed
abstract class AiChatSession with _$AiChatSession {
  const factory AiChatSession({
    @JsonKey(name: 'session_id') String? sessionId,
    String? id,
    @JsonKey(name: 'adolescent_id') String? adolescentId,
    String? adolescentIdAlt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessageContent,
    @Default(false) bool isActive,
  }) = _AiChatSession;

  factory AiChatSession.fromJson(Map<String, dynamic> json) =>
      _$AiChatSessionFromJson(json);
}

/// Returns the canonical session ID from the session, regardless of field name.
String sessionEffectiveId(AiChatSession session) =>
    session.sessionId ?? session.id ?? '';
