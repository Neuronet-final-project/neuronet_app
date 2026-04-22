import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'call_controller.g.dart';

/// ICE servers for WebRTC connectivity.
/// Uses Google's public STUN server by default.
const _iceServers = [
  {'urls': 'stun:stun.relay.metered.ca:80'},
  {
    'urls': 'turn:global.relay.metered.ca:80',
    'username': '0fbb88fb5cc9b42eb1553257',
    'credential': 'RG9sDGNSqV1fbAs9',
  },
  {
    'urls': 'turn:global.relay.metered.ca:80?transport=tcp',
    'username': '0fbb88fb5cc9b42eb1553257',
    'credential': 'RG9sDGNSqV1fbAs9',
  },
  {
    'urls': 'turn:global.relay.metered.ca:443',
    'username': '0fbb88fb5cc9b42eb1553257',
    'credential': 'RG9sDGNSqV1fbAs9',
  },
  {
    'urls': 'turns:global.relay.metered.ca:443?transport=tcp',
    'username': '0fbb88fb5cc9b42eb1553257',
    'credential': 'RG9sDGNSqV1fbAs9',
  },
];

@riverpod
FlutterLocalNotificationsPlugin notificationPlugin(Ref ref) {
  return FlutterLocalNotificationsPlugin();
}

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
    this.connectionState = RTCPeerConnectionState.RTCPeerConnectionStateNew,
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
  final RTCPeerConnectionState connectionState;

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
    RTCPeerConnectionState? connectionState,
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
      connectionState: connectionState ?? this.connectionState,
    );
  }
}

@riverpod
class CallController extends _$CallController {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  Timer? _durationTimer;
  Timer? _pollTimer;
  Timer? _incomingCallPollTimer;
  bool _notificationsInitialized = false;
  bool _isOutgoingCaller = false; // True when user initiated startCall()

  FlutterLocalNotificationsPlugin get _notificationsPlugin =>
      ref.read(notificationPluginProvider);

  // ICE candidate queue: candidates that arrive before remote description is set
  final List<RTCIceCandidate> _iceCandidateQueue = [];

  // Track whether remote description has been set (for ICE candidate queueing)
  bool _remoteDescriptionSet = false;

  // Track whether we've already shown a notification for the current incoming call
  String? _lastNotifiedCallId;

  @override
  Future<CallState> build() async {
    await _initNotifications();
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
    _incomingCallPollTimer?.cancel();
    _incomingCallPollTimer = Timer.periodic(const Duration(seconds: 10), (
      _,
    ) async {
      if (!ref.mounted) return;
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

    if (!ref.mounted) return;

    if (result.isSuccess && result.value.isNotEmpty) {
      final incomingCall = result.value.first;

      // Avoid duplicate notifications for the same call
      if (incomingCall.id == _lastNotifiedCallId) return;

      // ─── BUG FIX: Caller should never see their own call as incoming ───
      // When the user initiates an outgoing call via startCall(), they are
      // the ORIGINATOR, not the receiver. The backend returns the call in
      // getIncomingCalls() for BOTH parties. Without this check, the caller
      // sees accept/decline buttons for their OWN call.
      if (_isOutgoingCaller) return;

      final currentState = state.value;

      // Also skip if we already have this exact call in our state
      if (currentState != null &&
          currentState.currentCall != null &&
          currentState.currentCall!.id == incomingCall.id) {
        return; // Already tracking this call
      }

      // Skip if user is in a terminal state (ended/rejected) but still has
      // the same call — they need to clear state first
      if (currentState != null &&
          currentState.status.isTerminal &&
          currentState.currentCall != null) {
        return;
      }

      // Ignore stale calls: ringing for more than 5 minutes means the session
      // was likely abandoned but the backend never cleaned it up.
      // DONE: Implement unlink logic
      final createdAt = incomingCall.createdAt;
      if (createdAt != null) {
        final createdAtUtc = createdAt.isUtc
            ? createdAt
            : DateTime.utc(
                createdAt.year,
                createdAt.month,
                createdAt.day,
                createdAt.hour,
                createdAt.minute,
                createdAt.second,
                createdAt.millisecond,
              );
        final age = DateTime.now().toUtc().difference(createdAtUtc);
        if (age.inMinutes > 5) {
          debugPrint(
            '[CallController] Ignoring stale call ${incomingCall.id} '
            '(ringing for ${age.inMinutes}m, threshold: 5m, created_at=$createdAtUtc UTC, now=${DateTime.now().toUtc()} UTC)',
          );
          return;
        }
      }

      debugPrint(
        '[CallController] 📞 Incoming call: ${incomingCall.id} from ${incomingCall.callerEmail}',
      );
      _lastNotifiedCallId = incomingCall.id;

      // Show system notification
      await _showIncomingCallNotification(incomingCall);

      state = AsyncData(
        CallState(
          currentCall: incomingCall,
          status: incomingCall.status,
          remotePeerEmail: incomingCall.callerEmail,
        ),
      );
    }
  }

  /// Shows a system-level notification for an incoming call.
  Future<void> _showIncomingCallNotification(Call call) async {
    if (!_notificationsInitialized) return;

    try {
      final callerDisplay =
          call.callerEmail?.split('@').first ?? 'Unknown Caller';
      final callTypeLabel = call.callType.label;

      await _notificationsPlugin.show(
        call.id.hashCode,
        'Incoming $callTypeLabel',
        '$callerDisplay is calling you',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'neuronet_calls',
            'NEURONET Calls',
            channelDescription: 'Incoming voice and video call notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[CallController] Failed to show notification: $e');
    }
  }

  /// Initializes the local notifications plugin.
  Future<void> _initNotifications() async {
    if (_notificationsInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _notificationsPlugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      // Request permission on Android 13+
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();

      _notificationsInitialized = true;
      debugPrint('[CallController] Notifications initialized');
    } catch (e) {
      debugPrint('[CallController] Failed to initialize notifications: $e');
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

    // Mark as outgoing caller — prevents incoming poll from overwriting state
    _isOutgoingCaller = true;

    final callService = ref.read(callServiceProvider);
    final initiateResult = await callService.initiateCall(
      conversationId: conversationId,
      callType: callType,
    );

    if (initiateResult.isFailure) {
      debugPrint(
        '[CallController] ✗ Failed to initiate call: ${initiateResult.failure.message}',
      );
      state = AsyncData(CallState(error: initiateResult.failure.message));
      return;
    }

    final call = initiateResult.value;
    debugPrint('[CallController] Call initiated: ${call.id}');

    // Set state as 'initiated' but DON'T mark as active yet.
    // The call screen should show a "connecting..." state until
    // _setupWebRTC finishes and provides the localStream.
    state = AsyncData(
      CallState(
        currentCall: call,
        status: CallStatus.initiated,
        remotePeerEmail: remotePeerEmail,
      ),
    );

    // Setup WebRTC connection (caller creates and sends SDP offer).
    // This will update state with localStream when ready.
    await _setupWebRTC(call.id, callType);

    // Start polling for signals to receive callee's answer
    if (ref.mounted) {
      _startSignalPolling(call.id);
    }
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

    // Setup WebRTC for the callee: create media + peer connection but DON'T
    // send an offer — wait for the caller's offer via signal polling.
    // _setupCalleeWebRTC will set localStream and status internally.
    await _setupCalleeWebRTC(call.id, call.callType);

    // Start signal polling to receive the caller's offer
    if (ref.mounted) {
      _startSignalPolling(call.id);
    }
  }

  /// Rejects/declines an incoming call.
  Future<void> rejectCall() async {
    final currentState = state.value;
    if (currentState?.currentCall == null) return;

    final call = currentState!.currentCall!;
    debugPrint('[CallController] Rejecting call: ${call.id}');

    final callService = ref.read(callServiceProvider);
    await callService.endCall(call.id);

    _isOutgoingCaller = false;
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
    _isOutgoingCaller =
        false; // Reset so user can receive future incoming calls

    state = AsyncData(
      CallState(status: CallStatus.ended, duration: currentState.duration),
    );
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
      _peerConnection = await createPeerConnection({'iceServers': _iceServers});

      // Listen for remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (!ref.mounted) return;
        if (event.streams.isNotEmpty) {
          final remoteStream = event.streams.first;
          _remoteStream = remoteStream;
          final currentState = state.value;
          if (currentState != null) {
            state = AsyncData(
              currentState.copyWith(remoteStream: remoteStream),
            );
          }
        }
      };

      // ─── Connection state change listener ─────────────────────────────
      // Only log meaningful state transitions: connected/disconnected/failed
      _peerConnection!.onConnectionState = (RTCPeerConnectionState peerState) {
        if (!ref.mounted) return;
        final current = this.state.value;
        if (current == null) return;

        this.state = AsyncData(current.copyWith(connectionState: peerState));

        if (peerState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          debugPrint('[CallController] ✅ Peer connected');
          _startDurationTimer();

          // Transition to active state now that connection is established
          this.state = AsyncData(current.copyWith(status: CallStatus.active));

          // Notify backend the call is fully connected.
          // This may fail with 400 if the status was already set to "active"
          // by the callee's answerCall — that's expected and safe to ignore.
          if (ref.mounted) {
            final callService = ref.read(callServiceProvider);
            callService.setCallActive(callId).catchError((e) {
              debugPrint('[CallController] setCallActive error: $e');
              return const Result<void>.success(null);
            });
          }
        } else if (peerState ==
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
            peerState == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            peerState == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          debugPrint('[CallController] ❌ Peer disconnected/failed/closed');
          _cleanupWebRTC();
          _durationTimer?.cancel();
          if (ref.mounted) {
            this.state = AsyncData(
              CallState(
                status: CallStatus.ended,
                duration: current.duration,
                error: 'Call connection lost',
              ),
            );
          }
        }
      };

      // Listen for ICE candidates and send them to the peer
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (!ref.mounted) return;
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
          'video': {'facingMode': 'user'},
        });
      } else {
        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
        });
      }

      // Add local tracks to peer connection
      _localStream = localStream;
      localStream.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, localStream);
      });

      // Create and send SDP offer
      final rtcSessionDescription = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(rtcSessionDescription);

      final offerSignal = SignalRequestExt.sdpOffer(rtcSessionDescription.sdp!);
      await _sendSignal(callId, offerSignal);

      // DO NOT call setCallActive here — the caller sets it to active
      // only when WebRTC connectionState === "connected" (handled by
      // onConnectionState listener below). If we set it now, the backend
      // transitions to "active" and the callee's answerCall will fail
      // with "call_not_ringing" because the status is no longer "ringing".

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(
          currentState.copyWith(
            localStream: localStream,
            // Keep status as initiated/connecting until fully connected
          ),
        );
      }

      // Duration timer starts when onConnectionState fires "connected"

      debugPrint('[CallController] WebRTC setup complete');
    } catch (e) {
      debugPrint('[CallController] ✗ WebRTC setup failed: $e');
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(
          currentState.copyWith(
            error: 'Failed to establish call connection: $e',
          ),
        );
      }
    }
  }

  /// WebRTC setup for the callee (incoming call answerer).
  /// Creates local media and peer connection, then waits for the caller's
  /// SDP offer via signal polling. Does NOT send an offer.
  Future<void> _setupCalleeWebRTC(String callId, CallType callType) async {
    try {
      _peerConnection = await createPeerConnection({'iceServers': _iceServers});

      // Listen for remote stream
      _peerConnection!.onTrack = (RTCTrackEvent event) {
        if (!ref.mounted) return;
        if (event.streams.isNotEmpty) {
          final remoteStream = event.streams.first;
          _remoteStream = remoteStream;
          final currentState = state.value;
          if (currentState != null) {
            state = AsyncData(
              currentState.copyWith(remoteStream: remoteStream),
            );
          }
        }
      };

      // Connection state change listener
      _peerConnection!.onConnectionState = (RTCPeerConnectionState peerState) {
        if (!ref.mounted) return;
        final current = this.state.value;
        if (current == null) return;

        this.state = AsyncData(current.copyWith(connectionState: peerState));

        if (peerState == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          debugPrint('[CallController] ✅ Peer connected');
          _startDurationTimer();

          // Transition to active state now that connection is established
          this.state = AsyncData(current.copyWith(status: CallStatus.active));

          // Notify backend the call is fully connected.
          // This may fail with 400 if the status was already set to "active"
          // by the callee's answerCall — that's expected and safe to ignore.
          if (ref.mounted) {
            final callService = ref.read(callServiceProvider);
            callService.setCallActive(callId).catchError((e) {
              debugPrint('[CallController] setCallActive error: $e');
              return const Result<void>.success(null);
            });
          }
        } else if (peerState ==
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
            peerState == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            peerState == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
          debugPrint('[CallController] ❌ Peer disconnected/failed/closed');
          _cleanupWebRTC();
          _durationTimer?.cancel();
          if (ref.mounted) {
            this.state = AsyncData(
              CallState(
                status: CallStatus.ended,
                duration: current.duration,
                error: 'Call connection lost',
              ),
            );
          }
        }
      };

      // Listen for ICE candidates and send them
      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (!ref.mounted) return;
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
          'video': {'facingMode': 'user'},
        });
      } else {
        localStream = await navigator.mediaDevices.getUserMedia({
          'audio': true,
        });
      }

      _localStream = localStream;
      localStream.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, localStream);
      });

      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(
          currentState.copyWith(
            localStream: localStream,
            status: CallStatus.answered,
          ),
        );
      }

      // Don't start duration timer yet — start it when connection is established
      debugPrint(
        '[CallController] Callee WebRTC setup complete, waiting for caller offer',
      );
    } catch (e) {
      debugPrint('[CallController] ✗ Callee WebRTC setup failed: $e');
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(
          currentState.copyWith(
            error: 'Failed to establish call connection: $e',
          ),
        );
      }
    }
  }

  // ─── Signal Polling ──────────────────────────────────────────────────────

  void _startSignalPolling(String callId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!ref.mounted) {
        _pollTimer?.cancel();
        return;
      }
      await _pollSignals(callId);
    });
  }

  Future<void> _pollSignals(String callId) async {
    final callService = ref.read(callServiceProvider);
    final result = await callService.getSignals(callId);

    if (!ref.mounted) return;

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
        case 'offer':
          debugPrint('[CallController] Received SDP offer (callee side)');
          // Extract SDP — may be nested as {sdp: {type: "offer", sdp: "..."}} or flat
          final sdpField = signal.data['sdp'];
          final String? sdpString;
          if (sdpField is Map) {
            sdpString =
                sdpField['sdp'] as String? ?? sdpField['sdpString'] as String?;
          } else {
            sdpString = sdpField as String?;
          }
          if (sdpString != null) {
            final sdp = RTCSessionDescription(sdpString, 'offer');
            await _peerConnection!.setRemoteDescription(sdp);
            _remoteDescriptionSet = true;
            await _flushIceCandidates();

            // Create and send answer
            final answer = await _peerConnection!.createAnswer();
            await _peerConnection!.setLocalDescription(answer);
            final answerSignal = SignalRequestExt.sdpAnswer(answer.sdp!);
            await _sendSignal(callId, answerSignal);

            // DO NOT call setCallActive here — both caller and callee
            // should only call it when WebRTC connectionState === "connected"
            // (handled by onConnectionState listener below).
          }
          break;

        case 'answer':
          debugPrint('[CallController] Received SDP answer');
          // Extract SDP — may be nested or flat
          final sdpField = signal.data['sdp'];
          final String? sdpString;
          final String? sdpType;
          if (sdpField is Map) {
            sdpString =
                sdpField['sdp'] as String? ?? sdpField['sdpString'] as String?;
            sdpType = sdpField['type'] as String?;
          } else {
            sdpString = sdpField as String?;
            sdpType = 'answer';
          }
          if (sdpString != null) {
            final sdp = RTCSessionDescription(sdpString, sdpType ?? 'answer');
            await _peerConnection!.setRemoteDescription(sdp);
            _remoteDescriptionSet = true;
            // Flush any queued ICE candidates that arrived before remote description
            await _flushIceCandidates();
          }
          break;

        case 'ice-candidate':
          // Extract candidate fields — may be nested as a Map
          final candidateField = signal.data['candidate'];
          late final String candidateStr;
          late final String sdpMid;
          late final int sdpMLineIndex;

          if (candidateField is Map) {
            // Web sends the full RTCIceCandidate.toJSON() object
            candidateStr = candidateField['candidate'] as String;
            sdpMid = (candidateField['sdpMid'] as String?) ?? '0';
            sdpMLineIndex =
                (candidateField['sdpMLineIndex'] as num?)?.toInt() ?? 0;
          } else {
            candidateStr = candidateField as String;
            sdpMid = signal.data['sdpMid'] as String? ?? '0';
            sdpMLineIndex =
                (signal.data['sdpMLineIndex'] as num?)?.toInt() ?? 0;
          }

          if (!_remoteDescriptionSet) {
            final candidate = RTCIceCandidate(
              candidateStr,
              sdpMid,
              sdpMLineIndex,
            );
            _iceCandidateQueue.add(candidate);
          } else {
            final candidate = RTCIceCandidate(
              candidateStr,
              sdpMid,
              sdpMLineIndex,
            );
            await _peerConnection!.addCandidate(candidate);
          }
          break;

        default:
          debugPrint('[CallController] Unknown signal type: ${signal.type}');
      }
    } catch (e) {
      debugPrint('[CallController] Error handling signal: $e');
    }
  }

  /// Flushes any queued ICE candidates to the peer connection.
  Future<void> _flushIceCandidates() async {
    if (_iceCandidateQueue.isEmpty || _peerConnection == null) return;

    debugPrint(
      '[CallController] Flushing ${_iceCandidateQueue.length} queued ICE candidates',
    );
    for (final candidate in _iceCandidateQueue) {
      try {
        await _peerConnection!.addCandidate(candidate);
      } catch (e) {
        debugPrint('[CallController] Failed to add queued ICE candidate: $e');
      }
    }
    _iceCandidateQueue.clear();
  }

  Future<void> _sendSignal(String callId, SignalRequest signal) async {
    if (!ref.mounted) return;
    final callService = ref.read(callServiceProvider);
    final result = await callService.sendSignal(callId: callId, signal: signal);
    if (result.isFailure) {
      debugPrint(
        '[CallController] ✗ Failed to send signal: ${result.failure.message}',
      );
    }
  }

  // ─── Duration Timer ──────────────────────────────────────────────────────

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ref.mounted) {
        _durationTimer?.cancel();
        return;
      }
      final currentState = state.value;
      if (currentState != null) {
        state = AsyncData(
          currentState.copyWith(
            duration: currentState.duration + const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  // ─── Cleanup ─────────────────────────────────────────────────────────────

  Future<void> _cleanupWebRTC() async {
    if (_peerConnection == null &&
        _localStream == null &&
        _remoteStream == null &&
        _iceCandidateQueue.isEmpty) {
      return;
    }

    _pollTimer?.cancel();
    _pollTimer = null;

    // Clear ICE candidate queue
    _iceCandidateQueue.clear();
    _remoteDescriptionSet = false;

    // Reset notification tracking
    _lastNotifiedCallId = null;

    // Stop and dispose local stream
    if (_localStream != null) {
      _localStream?.getTracks().forEach((track) {
        track.stop();
      });
      _localStream?.dispose();
      _localStream = null;
    }

    // Stop and dispose remote stream
    if (_remoteStream != null) {
      _remoteStream?.getTracks().forEach((track) {
        track.stop();
      });
      _remoteStream?.dispose();
      _remoteStream = null;
    }

    // Close peer connection
    if (_peerConnection != null) {
      await _peerConnection?.close();
      _peerConnection = null;
    }
  }
}
