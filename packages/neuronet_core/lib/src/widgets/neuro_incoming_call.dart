import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';

/// Incoming call overlay screen shown when a call is detected.
/// Can be used as a full-screen dialog or pushed as a route.
class NeuroIncomingCallScreen extends ConsumerStatefulWidget {
  final Call? incomingCall;
  final Color accentColor;

  const NeuroIncomingCallScreen({
    super.key,
    this.incomingCall,
    this.accentColor = Colors.green,
  });

  @override
  ConsumerState<NeuroIncomingCallScreen> createState() =>
      _NeuroIncomingCallScreenState();
}

class _NeuroIncomingCallScreenState extends ConsumerState<NeuroIncomingCallScreen> {
  bool _isRinging = true;

  @override
  void initState() {
    super.initState();
    // If no call was passed, check the controller state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(callControllerProvider).value;
      if (widget.incomingCall == null && state?.currentCall == null) {
        // No incoming call found, navigate back
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  Future<void> _acceptCall() async {
    if (!_isRinging) return;
    setState(() => _isRinging = false);

    await ref.read(callControllerProvider.notifier).answerCall();

    if (mounted) {
      // Navigate to active call screen
      final state = ref.read(callControllerProvider).value;
      if (state?.currentCall != null) {
        Navigator.of(context).pop(); // Close incoming screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => NeuroActiveCallScreen(
              call: state!.currentCall!,
              remotePeerEmail: state.remotePeerEmail,
              accentColor: widget.accentColor,
            ),
          ),
        );
      }
    }
  }

  Future<void> _declineCall() async {
    if (!_isRinging) return;
    setState(() => _isRinging = false);

    await ref.read(callControllerProvider.notifier).rejectCall();

    if (mounted) Navigator.of(context).pop();
  }

  String get _callerName {
    final call = widget.incomingCall ?? ref.read(callControllerProvider).value?.currentCall;
    final email = call?.callerEmail;
    if (email == null) return 'Unknown Caller';
    return email.split('@').first[0].toUpperCase() + email.split('@').first.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final callType = widget.incomingCall?.callType ?? CallType.voice;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.accentColor.withValues(alpha: 0.9),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top: Caller info
              Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        callType == CallType.voice
                            ? Icons.phone_android
                            : Icons.videocam,
                        size: 48,
                        color: widget.accentColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _callerName,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      callType.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isRinging) _RingingIndicator(),
                  ],
                ),
              ),

              // Bottom: Accept/Decline buttons
              Padding(
                padding: const EdgeInsets.only(bottom: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallActionButton(
                      icon: Icons.call_end,
                      label: 'Decline',
                      backgroundColor: Colors.red,
                      onPressed: _declineCall,
                    ),
                    _CallActionButton(
                      icon: Icons.call,
                      label: 'Accept',
                      backgroundColor: Colors.green,
                      onPressed: _acceptCall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated ringing indicator.
class _RingingIndicator extends StatefulWidget {
  const _RingingIndicator();

  @override
  State<_RingingIndicator> createState() => _RingingIndicatorState();
}

class _RingingIndicatorState extends State<_RingingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
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
        final value = (_controller.value * 2 * 3.14159);
        final scale = 1.0 + 0.1 * sin(value).abs();
        return Transform.scale(
          scale: scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final opacity = sin(value + delay).abs();
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5 + opacity * 0.5),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

/// Circular action button for accept/decline.
class _CallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final VoidCallback onPressed;

  const _CallActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          backgroundColor: backgroundColor,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
