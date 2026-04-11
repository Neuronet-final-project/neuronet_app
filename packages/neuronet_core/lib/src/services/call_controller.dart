import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';

part 'call_controller.g.dart';

/// ICE servers for WebRTC connectivity.
/// Uses Google's public STUN server by default.
const _iceServers = [
  {
    'urls': 'stun:stun.l.google.com:19302',
  },
  {
    'urls': 'stun:stun1.l.google.com:19302',
  },
  // TURN servers would be added here for production use
];

/// Current state of an active call.
class CallState {
  const CallState({
    this.currentCall,
    this.status = CallStatus.initiated,
    this.remotePeerEmail,
    this.isMuted = false,
    this.isCameraOn = false,
    this.duration = Duration.zero,
    this.error,
    this.remoteStream,
    this.localStream,
  });

  final Call? currentCall;
  final CallStatus status;
  final String? remotePeerEmail;
  final bool isMuted;
  final bool isCameraOn;
  final Duration duration;
  final String? error;
  final MediaStream? remoteStream;
  final MediaStream? localStream;

  bool get isInCall => status.isActive;
  bool get isVoiceCall => currentCall?.callType == CallType.voice;
  bool get isVideoCall => currentCall?.callType == CallType.video;

  CallState copyWith({
    Call? currentCall,
    CallStatus? status,
    String? remotePeerEmail,
    bool? isMuted,
    bool? isCameraOn,
    Duration? duration,
    String? error,
    MediaStream? remoteStream,
    MediaStream? localStream,
  }) {
    return CallState(
      currentCall: currentCall ?? this.currentCall,
      status: status ?? this.status,
      remotePeerEmail: remotePeerEmail ?? this.remotePeerEmail,
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      duration: duration ?? this.duration,
      error: error,
      remoteStream: remoteStream ?? this.remoteStream,
      localStream: localStream ?? this.localStream,
    );
  }
}

@riverpod
class CallController extends _$CallController {
  RTCPeerConnection? _peerConnection;
  Timer? _durationTimer;
  Timer? _pollTimer;
  Timer? _incomingCallPollTimer;
  final _signalController = StreamController<SignalRequest>.broadcast();

  @override
  Future<CallState> build() async {
    // Start polling for incoming calls
    _startIncomingCallPolling();
    ref.onDispose(() {
      _stopIncomingCallPolling();
      _cleanupWebRTC();
    });
    return const CallState();
  }

  // ─── Incoming Call Polling ───────────────────────────────────────────────

  void _startIncomingCallPolling() {
    _incomingCallPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final state = this.state.value;
      // Only check if not already in a call
      if (state != null && !state.isInCall) {
        await checkIncomingCalls();
      }
    });
  }

  void _stopIncomingCallPolling() {
    _incomingCallPollTimer?.cancel();
    _incomingCallPollTimer = null;
  }

  /// Checks for incoming calls and notifies UI.
  Future<void> checkIncomingCalls() async {
    final callService = ref.read(callServiceProvider);
    final result = await callService.getIncomingCalls();

    if (result.isSuccess && result.value.isNotEmpty) {
      final incomingCall = result.value.first;
      final currentState = state.value;

      if (currentState?.isInCall != true) {
        debugPrint('[CallController] 📞 Incoming call: ${incomingCall.id}');
        state = AsyncData(
          CallState(
            currentCall: incomingCall,
            status: incomingCall.status,
            remotePeerEmail: incomingCall.callerEmail,
          ),
        );
      }
    }
  }

  // ─── Outgoing Call ───────────────────────────────────────────────────────

  /// Starts an outgoing call (voice or video).
  Future<void> startCall({
    required String conversationId,
    CallType callType = CallType.voice,
    String? remotePeerEmail,
  }) async {
    debugPrint('[CallController] Starting ${callType.name} call...');

    final callService = ref.read(callServiceProvider);
    final initiateResult = await callService.initiateCall(
      conversationId: conversationId,
      callType: callType,
    );

    if (initiateResult.isFailure) {
      debugPrint('[CallController] ✗ Failed to initiate call: ${initiateResult.failure.message}');
      state = AsyncData(CallState(error: initiateResult.failure.message));
      return;
    }

    final call = initiateResult.value;
    debugPrint('[CallController] Call initiated: ${call.id}');

    state = AsyncData(CallState(
      currentCall: call,
      status: call.status,
      remotePeerEmail: remotePeerEmail,
    ));

    // Setup WebRTC connection
    await _setupWebRTC(call.id, callType);

    // Answer the call (mark as answered)
    await callService.answerCall(call.id);

    // Start polling for signals
    _startSignalPolling(call.id);
  }

  // ─── Answer Incoming Call ────────────────────────────────────────────────

  /// Answers an incoming call.
  Future<void> answerCall() async {
    final currentState = state.value;
    if (currentState?.currentCall == null) return;

    final call = currentState!.currentCall!;
    debugPrint('[CallController] Answering call: ${call.id}');

    final callService = ref.read(callServiceProvider);
    final result = await callService.answerCall(call.id);

    if (result.isFailure) {
      state = AsyncData(currentState.copyWith(error: result.failure.message));
      return;
    }

    // Setup WebRTC for incoming
    await _setupWebRTC(call.id, call.callType);

    state = AsyncData(currentState.copyWith(status: CallStatus.answered));

    // Start signal polling
    _startSignalPolling(call.id);
  }

  /// Rejects/declines an incoming call.
  Future<void> rejectCall() async {
    final currentState = state.value;
    if (currentState?.currentCall == null) return;

    final call = currentState!.currentCall!;
    debugPrint('[CallController] Rejecting call: ${call.id}');

    final callService = ref.read(callServiceProvider);
    await callService.endCall(call.id);

    state = AsyncData(CallState(status: CallStatus.rejected));
  }

  // ─── End Call ────────────────────────────────────────────────────────────

  /// Ends the current call.
  Future<void> endCall() async {
    final currentState = state.value;
    if (currentState?.currentCall == null) return;

    final call = currentState!.currentCall!;
    debugPrint('[CallController] Ending call: ${call.id}');

    final callService = ref.read(callServiceProvider);
    await callService.endCall(call.id);

    _cleanupWebRTC();
    _durationTimer?.cancel();

    state = AsyncData(CallState(status: CallStatus.ended, duration: currentState.duration));
  }

  // ─── Mute / Camera Controls ──────────────────────────────────────────────

  /// Toggles the local audio mute state.
  Future<void> toggleMute() async {
    final currentState = state.value;
    if (currentState == null || currentState.localStream == null) return;

    final newMuted = !currentState.isMuted;
    final audioTracks = currentState.localStream!.getAudioTracks();

    for (final track in audioTracks) {
      track.enabled = !newMuted;
    }

    state = AsyncData(currentState.copyWith(isMuted: newMuted));
    debugPrint('[CallController] Audio muted: $newMuted');
  }

  /// Toggles the camera on/off (video calls only).
  Future<void> toggleCamera() async {
    final currentState = state.value;
    if (currentState == null || currentState.localStream == null) return;
    if (!currentState.isVideoCall) return;

    final newCameraOn = !currentState.isCameraOn;
    final videoTracks = currentState.localStream!.getVideoTracks();

    for (final track in videoTracks) {
      track.enabled = newCameraOn;
    }

    state = AsyncData(currentState.copyWith(isCameraOn: newCameraOn));
    debugPrint('[CallController] Camera on: $newCameraOn');
  }

  // ─── Switch Camera (front/back) ──────────────────────────────────────────

  /// Switches between front and back camera (video calls).
  Future<void> switchCamera() async {
    final currentState = state.value;
    if (currentState == null || currentState.localStream == null) return;
    if (!currentState.isVideoCall) return;

    final videoTracks = currentState.localStream!.getVideoTracks();
    if (videoTracks.isNotEmpty) {
      await Helper.switchCamera(videoTracks.first);
      debugPrint('[CallController] Camera switched');
    }
  }

  // ─── WebRTC Setup ────────────────────────────────────────────────────────

  Future<void> _setupWebRTC(String callId, CallType callType) async {
    try {
      // Create peer connection
      _peerConnection = await createPeerConnection({
        'iceServers': _iceServers,
      });

      // Listen for remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (event.streams.isNotEmpty) {
          debugPrint('[CallController] Remote stream received');
          final remoteStream = event.streams.first;
          final currentState = state.value;
          if (currentState != null) {
            state = AsyncData(currentState.copyWith(remoteStream: remoteStream));
          }
        }
      };

      // Listen for ICE candidates and send them to the peer
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        debugPrint('[CallController] ICE candidate generated');
        final signal = SignalRequestExt.iceCandidate(
          candidate: candidate.candidate!,
          sdpMLineIndex: candidate.sdpMLineIndex!,
          sdpMid: candidate.sdpMid!,
        );
        _sendSignal(callId, signal);
      };

      // Create local media stream
      MediaStream localStream;
      if (callType == CallType.video) {
        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
          'video': {
            'facingMode': 'user',
          },
        });
      } else {
        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
        });
      }

      // Add local tracks to peer connection
      localStream.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, localStream);
      });

      // Create and send SDP offer
      final rtcSessionDescription = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(rtcSessionDescription);

      final offerSignal = SignalRequestExt.sdpOffer(rtcSessionDescription.sdp!);
      await _sendSignal(callId, offerSignal);

      // Set call as active
      final callService = ref.read(callServiceProvider);
      await callService.setCallActive(callId);

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(currentState.copyWith(
          localStream: localStream,
          status: CallStatus.active,
        ));
      }

      // Start duration timer
      _startDurationTimer();

      debugPrint('[CallController] WebRTC setup complete');
    } catch (e) {
      debugPrint('[CallController] ✗ WebRTC setup failed: $e');
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(currentState.copyWith(error: 'Failed to establish call connection: $e'));
      }
    }
  }

  // ─── Signal Polling ──────────────────────────────────────────────────────

  void _startSignalPolling(String callId) {
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _pollSignals(callId);
    });
  }

  Future<void> _pollSignals(String callId) async {
    final callService = ref.read(callServiceProvider);
    final result = await callService.getSignals(callId);

    if (result.isSuccess && result.value.isNotEmpty) {
      for (final signal in result.value) {
        await _handleSignal(callId, signal);
      }
    }
  }

  Future<void> _handleSignal(String callId, SignalRequest signal) async {
    if (_peerConnection == null) return;

    try {
      switch (signal.type) {
        case 'answer':
          debugPrint('[CallController] Received SDP answer');
          final sdp = RTCSessionDescription(
            signal.data['sdp'] as String,
            signal.data['type'] as String,
          );
          await _peerConnection!.setRemoteDescription(sdp);
          break;

        case 'ice-candidate':
          debugPrint('[CallController] Received ICE candidate');
          final candidate = RTCIceCandidate(
            signal.data['candidate'] as String,
            signal.data['sdpMid'] as String,
            signal.data['sdpMLineIndex'] as int,
          );
          await _peerConnection!.addCandidate(candidate);
          break;

        default:
          debugPrint('[CallController] Unknown signal type: ${signal.type}');
      }
    } catch (e) {
      debugPrint('[CallController] Error handling signal: $e');
    }
  }

  Future<void> _sendSignal(String callId, SignalRequest signal) async {
    final callService = ref.read(callServiceProvider);
    final result = await callService.sendSignal(callId: callId, signal: signal);
    if (result.isFailure) {
      debugPrint('[CallController] ✗ Failed to send signal: ${result.failure.message}');
    }
  }

  // ─── Duration Timer ──────────────────────────────────────────────────────

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(currentState.copyWith(
          duration: currentState.duration + const Duration(seconds: 1),
        ));
      }
    });
  }

  // ─── Cleanup ─────────────────────────────────────────────────────────────

  Future<void> _cleanupWebRTC() async {
    debugPrint('[CallController] Cleaning up WebRTC resources');

    _pollTimer?.cancel();
    _pollTimer = null;

    // Stop and dispose local stream
    final currentState = state.value;
    currentState?.localStream?.getTracks().forEach((track) {
      track.stop();
    });
    currentState?.remoteStream?.getTracks().forEach((track) {
      track.stop();
    });

    // Close peer connection
    await _peerConnection?.close();
    _peerConnection = null;

    debugPrint('[CallController] WebRTC cleanup complete');
  }
}
