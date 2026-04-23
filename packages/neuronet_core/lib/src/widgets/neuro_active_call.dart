import 'dart:math';
import 'dart:ui';
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
  
  // PiP Position State
  Offset _pipPosition = const Offset(-1, -1); // -1 means uninitialized (default to top-right)
  bool _isDraggingPiP = false;

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
    if (email == null) return 'Unknown';
    return email.split('@').first[0].toUpperCase() + email.split('@').first.substring(1);
  }

  String get _formattedDuration {
    final state = ref.read(callControllerProvider).value;
    if (state?.status == CallStatus.initiated) {
      return 'Calling...';
    }
    return VoiceRecorderService.formatDuration(state?.duration ?? Duration.zero);
  }

  bool get _isCallerWaiting {
    final state = ref.read(callControllerProvider).value;
    return state?.status == CallStatus.initiated;
  }

  String get _endButtonLabel {
    return _isCallerWaiting ? 'Cancel' : 'End Call';
  }

  Future<void> _endCall() async {
    await ref.read(callControllerProvider.notifier).endCall();
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callControllerProvider);

    // Ensure renderers are initialized before showing any WebRTC UI
    if (!_renderersInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: callState.when(
        data: (state) {
          // Update remote stream to renderer (with guards to prevent redundant updates)
          if (state.remoteStream != null && _remoteRenderer.srcObject != state.remoteStream) {
            _remoteRenderer.srcObject = state.remoteStream;
          }
          if (state.localStream != null && _localRenderer.srcObject != state.localStream) {
            _localRenderer.srcObject = state.localStream;
          }

          return _buildCallUI(state);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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

  // ─── Video Call UI ───────────────────────────────────────────────────────

  Widget _buildVideoCallUI(CallState state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Remote video (full screen)
        state.remoteStream != null
            ? RTCVideoView(
                _remoteRenderer,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            : Container(
                color: Colors.grey[900],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        'Connecting...',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),

        // Overlay UI
        SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top: Remote name + duration
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF0F0F23).withValues(alpha: 0.8),
                          const Color(0xFF0F0F23).withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _remoteName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black45,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formattedDuration,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        // Connection quality indicator
                        _ConnectionStatusPill(isActive: state.status == CallStatus.active),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom: Controls — large round buttons matching web pattern
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xFF0F0F23).withValues(alpha: 0.95),
                          const Color(0xFF0F0F23).withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Only show controls after call is connected (not while caller is waiting)
                        if (!_isCallerWaiting) ...[
                          _ActiveCallControlButton(
                            key: const ValueKey('mute_button'),
                            icon: state.isMuted ? Icons.mic_off : Icons.mic,
                            label: state.isMuted ? 'Unmute' : 'Mute',
                            isActive: state.isMuted,
                            size: 56,
                            onPressed: () {
                              ref.read(callControllerProvider.notifier).toggleMute();
                            },
                          ),
                          const SizedBox(width: 20),
                          _ActiveCallControlButton(
                            icon: state.isCameraOn ? Icons.videocam_off : Icons.videocam,
                            label: state.isCameraOn ? 'Video Off' : 'Video On',
                            isActive: !state.isCameraOn,
                            size: 56,
                            onPressed: () {
                              ref.read(callControllerProvider.notifier).toggleCamera();
                            },
                          ),
                          const SizedBox(width: 20),
                          _ActiveCallControlButton(
                            icon: Icons.cameraswitch,
                            label: 'Flip',
                            size: 56,
                            onPressed: () {
                              ref.read(callControllerProvider.notifier).switchCamera();
                            },
                          ),
                          const SizedBox(width: 32),
                        ],
                        _ActiveCallControlButton(
                          key: const ValueKey('end_call_button'),
                          icon: Icons.call_end,
                          label: _endButtonLabel,
                          backgroundColor: const Color(0xFFE11D48), // Premium Play Red
                          size: 72,
                          onPressed: _endCall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Local video (Picture-in-Picture with Draggable + Snap)
        LayoutBuilder(
          builder: (context, constraints) {
            const pipWidth = 120.0;
            const pipHeight = 160.0;
            final margin = MediaQuery.of(context).padding.top + 20;
            
            // Initialize position if first build
            if (_pipPosition.dx == -1) {
              _pipPosition = Offset(constraints.maxWidth - pipWidth - 16, margin + 60);
            }

            return Positioned(
              left: _pipPosition.dx,
              top: _pipPosition.dy,
              child: GestureDetector(
                onPanStart: (_) => setState(() => _isDraggingPiP = true),
                onPanUpdate: (details) {
                  setState(() {
                    _pipPosition += details.delta;
                    // Clamp within screen boundaries
                    _pipPosition = Offset(
                      _pipPosition.dx.clamp(16, constraints.maxWidth - pipWidth - 16),
                      _pipPosition.dy.clamp(margin, constraints.maxHeight - pipHeight - 100),
                    );
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    _isDraggingPiP = false;
                    // Snap to nearest corner
                    final centerX = _pipPosition.dx + pipWidth / 2;
                    final snapX = centerX > constraints.maxWidth / 2 
                        ? constraints.maxWidth - pipWidth - 16 
                        : 16.0;
                    
                    _pipPosition = Offset(snapX, _pipPosition.dy);
                  });
                },
                child: AnimatedContainer(
                  duration: _isDraggingPiP ? Duration.zero : const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  width: pipWidth,
                  height: pipHeight,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: state.localStream != null
                      ? RTCVideoView(
                          _localRenderer,
                          mirror: true,
                          objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                        )
                      : Container(
                          color: const Color(0xFF0F0F23),
                          child: const Center(
                            child: Icon(Icons.videocam_off_rounded, color: Colors.white24, size: 32),
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─── Voice Call UI ───────────────────────────────────────────────────────

  Widget _buildVoiceCallUI(CallState state) {
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
                  _AudioWaveAnimation(isActive: state.status == CallStatus.active),
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
                  if (!_isCallerWaiting)
                    _ActiveCallControlButton(
                      key: const ValueKey('mute_button'),
                      icon: state.isMuted ? Icons.mic_off : Icons.mic,
                      label: state.isMuted ? 'Unmute' : 'Mute',
                      isActive: state.isMuted,
                      size: 60,
                      onPressed: () {
                        ref.read(callControllerProvider.notifier).toggleMute();
                      },
                    ),
                  if (!_isCallerWaiting) const SizedBox(width: 32),
                  // End/Cancel call button
                  _ActiveCallControlButton(
                    key: const ValueKey('end_call_button'),
                    icon: Icons.call_end,
                    label: _endButtonLabel,
                    backgroundColor: Colors.red,
                    size: 72,
                    onPressed: _endCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Call Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
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

class _ActiveCallControlButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? backgroundColor;
  final double size;
  final VoidCallback onPressed;

  const _ActiveCallControlButton({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.backgroundColor,
    this.size = 60,
    required this.onPressed,
  });

  @override
  State<_ActiveCallControlButton> createState() => _ActiveCallControlButtonState();
}

class _ActiveCallControlButtonState extends State<_ActiveCallControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ??
        (widget.isActive ? Colors.white : Colors.white.withValues(alpha: 0.15));
    final iconColor = widget.backgroundColor != null
        ? Colors.white
        : (widget.isActive ? const Color(0xFFE11D48) : Colors.white);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      if (widget.isActive || widget.backgroundColor != null)
                        BoxShadow(
                          color: (widget.backgroundColor ?? Colors.white)
                              .withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    color: iconColor,
                    size: widget.size * 0.45,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _ConnectionStatusPill extends StatefulWidget {
  final bool isActive;

  const _ConnectionStatusPill({required this.isActive});

  @override
  State<_ConnectionStatusPill> createState() => _ConnectionStatusPillState();
}

class _ConnectionStatusPillState extends State<_ConnectionStatusPill>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi, color: Colors.greenAccent, size: 14),
            const SizedBox(width: 6),
            Text(
              widget.isActive ? 'Stable' : 'Connecting',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
