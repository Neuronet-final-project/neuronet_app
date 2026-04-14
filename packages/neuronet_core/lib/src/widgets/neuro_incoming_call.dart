import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// Incoming call overlay screen shown when a call is detected.
/// Can be used as a full-screen dialog or pushed as a route.
class NeuroIncomingCallScreen extends ConsumerStatefulWidget {
  final Call? incomingCall;
  final Color accentColor;

  /// Called when the call is accepted or declined, so the caller can remove
  /// the overlay and navigate to the active call screen.
  final VoidCallback? onDismissed;

  const NeuroIncomingCallScreen({
    super.key,
    this.incomingCall,
    this.accentColor = Colors.green,
    this.onDismissed,
  });

  @override
  ConsumerState<NeuroIncomingCallScreen> createState() =>
      _NeuroIncomingCallScreenState();
}

class _NeuroIncomingCallScreenState extends ConsumerState<NeuroIncomingCallScreen> {
  bool _isRinging = true;
  final AudioPlayer _ringtonePlayer = AudioPlayer();
  Timer? _ringtoneCycleTimer;
  File? _ringtoneFile;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // Start ringtone playback
    _startRingtone();
    // If no call was passed, check the controller state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      final state = ref.read(callControllerProvider).value;
      if (widget.incomingCall == null && state?.currentCall == null) {
        // No incoming call found, navigate back
        if (mounted) {
          _stopRingtone();
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopRingtone();
    _ringtonePlayer.dispose();
    super.dispose();
  }

  /// Generates a ringtone WAV matching the web's dual-tone pattern
  /// (440Hz + 480Hz bursts, 2 bursts per cycle, 3-second cycle).
  Future<File> _generateRingtoneFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/neuronet_ringtone.wav');

    const sampleRate = 44100;
    const durationSec = 3; // Full cycle: 3 seconds
    const totalSamples = sampleRate * durationSec;
    const bytesPerSample = 2; // 16-bit
    const numChannels = 1; // Mono
    final dataSize = totalSamples * bytesPerSample * numChannels;

    final buffer = BytesBuilder();

    // Write WAV header (44 bytes)
    _writeWavHeader(buffer, dataSize, sampleRate, numChannels, bytesPerSample * 8);

    // Generate audio data
    for (int i = 0; i < totalSamples; i++) {
      final t = i / sampleRate; // Time in seconds
      double sample = 0.0;

      // First burst: 0.0 – 0.5s
      if (t < 0.5) {
        final env = _envelope(t, 0.0, 0.05, 0.4, 0.5);
        sample += env * (_sine(440, t) + _sine(480, t)) * 0.15;
      }
      // Second burst: 0.6 – 1.1s
      else if (t >= 0.6 && t < 1.1) {
        final t2 = t - 0.6;
        final env = _envelope(t2, 0.0, 0.05, 0.4, 0.5);
        sample += env * (_sine(440, t2) + _sine(480, t2)) * 0.15;
      }
      // Rest is silence (1.1s – 3.0s)

      final int16 = (sample.clamp(-1.0, 1.0) * 32767).toInt();
      buffer.addByte(int16 & 0xFF);
      buffer.addByte((int16 >> 8) & 0xFF);
    }

    await file.writeAsBytes(buffer.takeBytes());
    return file;
  }

  double _sine(double freq, double t) => sin(2 * pi * freq * t);

  double _envelope(double t, double attackStart, double attackEnd, double sustainEnd, double releaseEnd) {
    if (t < attackStart) return 0.0;
    if (t < attackEnd) return (t - attackStart) / (attackEnd - attackStart);
    if (t < sustainEnd) return 1.0;
    if (t < releaseEnd) return 1.0 - (t - sustainEnd) / (releaseEnd - sustainEnd);
    return 0.0;
  }

  void _writeWavHeader(BytesBuilder buffer, int dataSize, int sampleRate, int numChannels, int bitsPerSample) {
    final byteData = BytesBuilder();

    // RIFF header
    byteData.add(_asciiBytes('RIFF'));
    byteData.add(_uint32(36 + dataSize)); // File size - 8
    byteData.add(_asciiBytes('WAVE'));

    // fmt chunk
    byteData.add(_asciiBytes('fmt '));
    byteData.add(_uint32(16)); // Subchunk1Size (PCM)
    byteData.add(_uint16(1)); // AudioFormat (PCM)
    byteData.add(_uint16(numChannels));
    byteData.add(_uint32(sampleRate));
    byteData.add(_uint32(sampleRate * numChannels * bitsPerSample ~/ 8)); // ByteRate
    byteData.add(_uint16(numChannels * bitsPerSample ~/ 8)); // BlockAlign
    byteData.add(_uint16(bitsPerSample));

    // data chunk
    byteData.add(_asciiBytes('data'));
    byteData.add(_uint32(dataSize));

    buffer.add(byteData.takeBytes());
  }

  List<int> _asciiBytes(String s) => s.codeUnits;
  List<int> _uint32(int v) => [v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF];
  List<int> _uint16(int v) => [v & 0xFF, (v >> 8) & 0xFF];

  /// Starts the ringtone with a repeating pattern matching the web's
  /// dual-tone burst (440Hz/480Hz) every 3 seconds.
  Future<void> _startRingtone() async {
    try {
      _ringtoneFile = await _generateRingtoneFile();
      await _ringtonePlayer.setReleaseMode(ReleaseMode.loop);
      await _ringtonePlayer.setVolume(0.6);
      await _ringtonePlayer.play(DeviceFileSource(_ringtoneFile!.path));
    } catch (e) {
      debugPrint('[NeuroIncomingCall] Failed to start ringtone: $e');
    }
  }

  Future<void> _stopRingtone() async {
    _ringtoneCycleTimer?.cancel();
    _ringtoneCycleTimer = null;
    try {
      await _ringtonePlayer.stop();
    } catch (_) {}
  }

  Future<void> _acceptCall() async {
    if (!_isRinging) return;
    setState(() => _isRinging = false);
    _stopRingtone();

    await ref.read(callControllerProvider.notifier).answerCall();

    // Notify parent to remove this overlay.
    // The active call screen will be shown automatically via the inline
    // Stack overlay when the call controller status changes to "answered".
    widget.onDismissed?.call();
  }

  Future<void> _declineCall() async {
    if (!_isRinging) return;
    setState(() => _isRinging = false);
    _stopRingtone();

    await ref.read(callControllerProvider.notifier).rejectCall();

    // Remove this overlay and notify caller
    widget.onDismissed?.call();
  }

  String get _callerName {
    final call = widget.incomingCall ?? ref.read(callControllerProvider).value?.currentCall;
    if (call == null) return 'Unknown Caller';

    // Use callerName if available (from backend), otherwise derive from email
    if (call.callerName != null && call.callerName!.isNotEmpty) {
      return call.callerName!;
    }
    final email = call.callerEmail;
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
