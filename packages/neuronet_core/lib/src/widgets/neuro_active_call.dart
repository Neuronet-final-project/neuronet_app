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

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  String get _remoteName {
    final email = widget.remotePeerEmail;
    if (email == null) return 'Unknown';
    return email.split('@').first[0].toUpperCase() + email.split('@').first.substring(1);
  }

  String get _formattedDuration {
    final state = ref.read(callControllerProvider).value;
    return VoiceRecorderService.formatDuration(state?.duration ?? Duration.zero);
  }

  Future<void> _endCall() async {
    await ref.read(callControllerProvider.notifier).endCall();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final callState = ref.watch(callControllerProvider);

    return Scaffold(
      body: callState.when(
        data: (state) {
          // Update remote stream to renderer
          if (state.remoteStream != null) {
            _remoteRenderer.srcObject = state.remoteStream;
          }
          if (state.localStream != null) {
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
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
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formattedDuration,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Connection quality indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wifi, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Connected',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom: Controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlButton(
                      icon: state.isMuted ? Icons.mic_off : Icons.mic,
                      label: state.isMuted ? 'Unmute' : 'Mute',
                      isActive: state.isMuted,
                      onPressed: () {
                        ref.read(callControllerProvider.notifier).toggleMute();
                      },
                    ),
                    _ControlButton(
                      icon: Icons.cameraswitch,
                      label: 'Switch Camera',
                      onPressed: () {
                        ref.read(callControllerProvider.notifier).switchCamera();
                      },
                    ),
                    _ControlButton(
                      icon: state.isCameraOn ? Icons.videocam_off : Icons.videocam,
                      label: state.isCameraOn ? 'Camera Off' : 'Camera On',
                      isActive: !state.isCameraOn,
                      onPressed: () {
                        ref.read(callControllerProvider.notifier).toggleCamera();
                      },
                    ),
                    FloatingActionButton(
                      heroTag: 'endCall',
                      backgroundColor: Colors.red,
                      onPressed: _endCall,
                      child: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Local video (picture-in-picture)
        Positioned(
          top: 80,
          right: 16,
          child: Container(
            width: 120,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
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
                : const Center(
                    child: Icon(Icons.videocam_off, color: Colors.white54),
                  ),
          ),
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

            // Bottom: Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'mute',
                    backgroundColor: state.isMuted
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    onPressed: () {
                      ref.read(callControllerProvider.notifier).toggleMute();
                    },
                    child: Icon(
                      state.isMuted ? Icons.mic_off : Icons.mic,
                      color: state.isMuted ? Colors.red : Colors.white,
                      size: 28,
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'endCall',
                    backgroundColor: Colors.red,
                    onPressed: _endCall,
                    child: const Icon(Icons.call_end, color: Colors.white, size: 32),
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
            final height = 8.0 + 24.0 * (value.sin().abs());
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

/// Small control button for video call screen.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: isActive
              ? Colors.white
              : Colors.white.withValues(alpha: 0.2),
          onPressed: onPressed,
          child: Icon(
            icon,
            color: isActive ? Colors.red : Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}
