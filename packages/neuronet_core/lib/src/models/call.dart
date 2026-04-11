import 'package:freezed_annotation/freezed_annotation.dart';

part 'call.freezed.dart';
part 'call.g.dart';

/// Types of calls supported by the backend.
enum CallType {
  @JsonValue('voice')
  voice,
  @JsonValue('video')
  video;

  String toJson() => name;
  static CallType fromJson(String json) => values.byName(json);

  /// Human-readable label for UI.
  String get label => this == CallType.voice ? 'Voice Call' : 'Video Call';

  /// Icon representation for UI.
  String get icon => this == CallType.voice ? '📞' : '📹';
}

/// Call status reflecting the current state of a call session.
enum CallStatus {
  @JsonValue('initiated')
  initiated,
  @JsonValue('ringing')
  ringing,
  @JsonValue('answered')
  answered,
  @JsonValue('active')
  active,
  @JsonValue('ended')
  ended,
  @JsonValue('missed')
  missed,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled;

  String toJson() => name;
  static CallStatus fromJson(String json) => values.byName(json);

  /// Whether the call is still in progress (not terminal).
  bool get isActive =>
      this == CallStatus.ringing ||
      this == CallStatus.answered ||
      this == CallStatus.active;

  /// Whether the call has ended (terminal state).
  bool get isTerminal =>
      this == CallStatus.ended ||
      this == CallStatus.missed ||
      this == CallStatus.rejected ||
      this == CallStatus.cancelled;
}

/// Represents a voice or video call session.
@freezed
abstract class Call with _$Call {
  const factory Call({
    @JsonKey(name: 'call_id') required String id,
    @JsonKey(name: 'conversation_id') required String conversationId,
    @JsonKey(name: 'caller_id') required String callerId,
    @JsonKey(name: 'caller_email') String? callerEmail,
    @JsonKey(name: 'callee_id') String? calleeId,
    @JsonKey(name: 'callee_email') String? calleeEmail,
    @JsonKey(name: 'call_type') required CallType callType,
    required CallStatus status,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'answered_at') DateTime? answeredAt,
    @JsonKey(name: 'ended_at') DateTime? endedAt,
  }) = _Call;

  factory Call.fromJson(Map<String, dynamic> json) => _$CallFromJson(json);
}

/// WebRTC signaling request exchanged via REST polling.
@freezed
abstract class SignalRequest with _$SignalRequest {
  const factory SignalRequest({
    /// The signaling type: 'offer', 'answer', or 'ice-candidate'.
    required String type,

    /// SDP data or ICE candidate data.
    required Map<String, dynamic> data,
  }) = _SignalRequest;

  factory SignalRequest.fromJson(Map<String, dynamic> json) =>
      _$SignalRequestFromJson(json);
}

/// Helper to create an SDP offer/answer payload.
extension SignalRequestExt on SignalRequest {
  /// Creates an SDP offer request.
  static SignalRequest sdpOffer(String sdp) => SignalRequest(
        type: 'offer',
        data: {'sdp': sdp, 'type': 'offer'},
      );

  /// Creates an SDP answer request.
  static SignalRequest sdpAnswer(String sdp) => SignalRequest(
        type: 'answer',
        data: {'sdp': sdp, 'type': 'answer'},
      );

  /// Creates an ICE candidate request.
  static SignalRequest iceCandidate({
    required String candidate,
    required int sdpMLineIndex,
    required String sdpMid,
  }) =>
      SignalRequest(
        type: 'ice-candidate',
        data: {
          'candidate': candidate,
          'sdpMLineIndex': sdpMLineIndex,
          'sdpMid': sdpMid,
        },
      );
}
