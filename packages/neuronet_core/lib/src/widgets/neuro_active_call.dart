import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';

/// Active call screen showing call duration, controls, and video (if video call).
class NeuroActiveCallScreen extends ConsumerStatefulWidget {
  final Call call;
  final String? remotePeerEmail;
  final Color accentColor;

  const NeuroActiveCallScreen({
    super.key,
    required this.call,
    this.remotePeerEmail,
    this.accentColor = Colors.green,
  });

  @override
  ConsumerState<NeuroActiveCallScreen> createState() =>
      _NeuroActiveCallScreenState();
}

class _NeuroActiveCallScreenState extends ConsumerState<NeuroActiveCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _renderersInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    try {
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();
      if (mounted) {
        setState(() {
          _renderersInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('[NeuroActiveCallScreen] Error initializing renderers: $e');
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  String get _remoteName {
    // Use callerName from the Call model if available (from backend)
    if (widget.call.callerName != null && widget.call.callerName!.isNotEmpty) {
      return widget.call.callerName!;
    }
    final email = widget.remotePeerEmail;
    if (email == null) return context.localizations.unknownCaller;
    return email.split('@').first[0].toUpperCase() +
        email.split('@').first.substring(1);
  }

  String get _formattedDuration {
    final state = ref.read(callControllerProvider).value;
    if (state?.status == CallStatus.initiated) {
      return context.localizations.calling;
    }
    return VoiceRecorderService.formatDuration(
      state?.duration ?? Duration.zero,
    );
  }

  bool get _isCallerWaiting {
    final state = ref.read(callControllerProvider).value;
    return state?.status == CallStatus.initiated;
  }

  String get _endButtonLabel {
    return _isCallerWaiting
        ? context.localizations.cancel
        : context.localizations.endCall;
  }

  Future<void> _endCall() async {
    await ref.read(callControllerProvider.notifier).endCall();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callControllerProvider);

    // Safely execute the side effect of updating WebRTC sources when state changes
    ref.listen<AsyncValue<CallState?>>(callControllerProvider, (
      previous,
      next,
    ) {
      final state = next.value;
      if (state != null && _renderersInitialized) {
        if (state.remoteStream != null &&
            _remoteRenderer.srcObject != state.remoteStream) {
          _remoteRenderer.srcObject = state.remoteStream;
        }
        if (state.localStream != null &&
            _localRenderer.srcObject != state.localStream) {
          _localRenderer.srcObject = state.localStream;
        }
      }
    });

    // Ensure renderers are initialized before showing any WebRTC UI
    if (!_renderersInitialized) {
      return Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      color: const Color(0xFF1A1A2E),
      child: callState.when(
        data: (state) => _buildCallUI(state),
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (err, _) => _buildErrorState(err),
      ),
    );
  }

  Widget _buildCallUI(CallState state) {
    if (state.isVideoCall) {
      return _buildVideoCallUI(state);
    }
    return _buildVoiceCallUI(state);
  }

  Widget _buildVideoCallUI(CallState state) {
    final isConnected = state.remoteStream != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── BACKGROUND ────────────────────────────────────────────────────
        isConnected
            ? RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            : _buildCallingBackground(state),

        // ── TOP HEADER BAR ────────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Name + timer
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _remoteName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formattedDuration,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Status pill
                  _StatusPill(isConnected: isConnected),
                ],
              ),
            ),
          ),
        ),

        // ── LOCAL PiP ─────────────────────────────────────────────────────
        _DraggablePiP(
          localRenderer: _localRenderer,
          localStream: state.localStream,
        ),

        // ── BOTTOM CONTROLS ───────────────────────────────────────────────
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.80),
                  Colors.black.withValues(alpha: 0.40),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(12, 28, 12, 36),
            child: _buildControlsRow(state),
          ),
        ),
      ],
    );
  }

  /// Dark navy gradient shown while waiting for the remote stream.
  Widget _buildCallingBackground(CallState state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.2,
          colors: [Color(0xFF1E2A5E), Color(0xFF0D1B3E), Color(0xFF060D1F)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar ring
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withValues(alpha: 0.6),
                    const Color(0xFF3D5AF1).withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                  width: 2.5,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white70,
                size: 56,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              _remoteName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    color: Color(0xFF6C63FF),
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  _isCallerWaiting
                      ? context.localizations.calling
                      : context.localizations.connecting,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Row of call control buttons — always visible, even while calling.
  Widget _buildControlsRow(CallState state) {
    final l10n = context.localizations;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Mute
        _ControlBtn(
          icon: state.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
          label: state.isMuted ? l10n.unmute : l10n.mute,
          isActive: state.isMuted,
          onTap: () => ref.read(callControllerProvider.notifier).toggleMute(),
        ),
        // Camera on/off
        _ControlBtn(
          icon: state.isCameraOn
              ? Icons.videocam_rounded
              : Icons.videocam_off_rounded,
          label: state.isCameraOn ? l10n.camera : l10n.camOff,
          isActive: !state.isCameraOn,
          onTap: () => ref.read(callControllerProvider.notifier).toggleCamera(),
        ),
        // End call (big red center)
        _EndCallBtn(onTap: _endCall, label: _endButtonLabel),
        // Flip camera
        _ControlBtn(
          icon: Icons.flip_camera_ios_rounded,
          label: l10n.flip,
          onTap: () => ref.read(callControllerProvider.notifier).switchCamera(),
        ),
        // Speaker (placeholder visual — actual speaker toggle varies by platform)
        _ControlBtn(
          icon: Icons.volume_up_rounded,
          label: l10n.speaker,
          onTap: () {}, // Speaker toggle (future enhancement)
        ),
      ],
    );
  }

  // ─── Voice Call UI ───────────────────────────────────────────────────────

  Widget _buildVoiceCallUI(CallState state) {
    final l10n = context.localizations;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.accentColor.withValues(alpha: 0.9),
            widget.accentColor.withValues(alpha: 0.3),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Caller info + duration
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _remoteName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formattedDuration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Audio wave animation
                  _AudioWaveAnimation(
                    isActive: state.status == CallStatus.active,
                  ),
                ],
              ),
            ),

            // Bottom: Controls — large round buttons matching web pattern
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mute button (only shown after call is connected)
                  if (!_isCallerWaiting) ...[
                    _ControlBtn(
                      icon: state.isMuted ? Icons.mic_off : Icons.mic,
                      label: state.isMuted ? l10n.unmute : l10n.mute,
                      isActive: state.isMuted,
                      onTap: () {
                        ref.read(callControllerProvider.notifier).toggleMute();
                      },
                    ),
                    const SizedBox(width: 32),
                  ],
                  // End/Cancel call button
                  _EndCallBtn(label: _endButtonLabel, onTap: _endCall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    final l10n = context.localizations;
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFE11D48),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.callError,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _endCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.dismiss),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Audio wave animation for voice calls.
class _AudioWaveAnimation extends StatefulWidget {
  final bool isActive;

  const _AudioWaveAnimation({required this.isActive});

  @override
  State<_AudioWaveAnimation> createState() => _AudioWaveAnimationState();
}

class _AudioWaveAnimationState extends State<_AudioWaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    if (widget.isActive) _controller.repeat();
  }

  @override
  void didUpdateWidget(_AudioWaveAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final delay = index * 0.15;
            final value = (_controller.value + delay) % 1.0;
            final height = 8.0 + 24.0 * sin(value).abs();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 4,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─── Small control button (Mute, Camera, Flip, Speaker) ────────────────────

class _ControlBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  State<_ControlBtn> createState() => _ControlBtnState();
}

class _ControlBtnState extends State<_ControlBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.isActive
        ? Colors.white.withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.14);
    final iconColor = widget.isActive ? const Color(0xFF1A1A2E) : Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: _pressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 90),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isActive
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.18),
                  width: 1.2,
                ),
              ),
              child: Icon(widget.icon, color: iconColor, size: 22),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Large red End Call button ──────────────────────────────────────────────

class _EndCallBtn extends StatefulWidget {
  final VoidCallback onTap;
  final String label;

  const _EndCallBtn({required this.onTap, required this.label});

  @override
  State<_EndCallBtn> createState() => _EndCallBtnState();
}

class _EndCallBtnState extends State<_EndCallBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            scale: _pressed ? 0.88 : 1.0,
            duration: const Duration(milliseconds: 90),
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE11D48),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Status pill (Connecting / Stable) ─────────────────────────────────────

class _StatusPill extends StatelessWidget {
  final bool isConnected;
  const _StatusPill({required this.isConnected});

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isConnected ? Colors.green : const Color(0xFF6C63FF))
            .withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isConnected ? Colors.greenAccent : const Color(0xFF6C63FF))
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConnected ? Icons.wifi_rounded : Icons.wifi_find_rounded,
            color: isConnected ? Colors.greenAccent : const Color(0xFF9D8FFF),
            size: 12,
          ),
          const SizedBox(width: 5),
          Text(
            isConnected ? l10n.connected : l10n.connecting,
            style: TextStyle(
              color: isConnected ? Colors.greenAccent : const Color(0xFF9D8FFF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Draggable local video PiP ─────────────────────────────────────────────

class _DraggablePiP extends StatefulWidget {
  final RTCVideoRenderer localRenderer;
  final dynamic localStream; // MediaStream?

  const _DraggablePiP({required this.localRenderer, required this.localStream});

  @override
  State<_DraggablePiP> createState() => _DraggablePiPState();
}

class _DraggablePiPState extends State<_DraggablePiP> {
  Offset _pos = const Offset(-1, -1);

  @override
  Widget build(BuildContext context) {
    const w = 108.0;
    const h = 148.0;
    final mqSize = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;

    if (_pos.dx == -1) {
      _pos = Offset(mqSize.width - w - 16, safeTop + 72);
    }

    return Positioned(
      left: _pos.dx,
      top: _pos.dy,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _pos = Offset(
              (_pos.dx + d.delta.dx).clamp(8, mqSize.width - w - 8),
              (_pos.dy + d.delta.dy).clamp(
                safeTop + 8,
                mqSize.height - h - 120,
              ),
            );
          });
        },
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: widget.localStream != null
              ? RTCVideoView(
                  widget.localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              : const Center(
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white24,
                    size: 28,
                  ),
                ),
        ),
      ),
    );
  }
}
