import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/voice_recorder_service.dart';

/// Shared chat message input widget used across AI chat, counselor chat,
/// and guardian counselor messaging screens.
///
/// Provides a text field with a send button, microphone button for voice messages,
/// proper padding for system bars, and consistent styling.
class NeuroChatInput extends StatefulWidget {
  const NeuroChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type your message...',
    this.accentColor,
    this.isEnabled = true,
    this.onSendVoice,
  });

  /// Text editing controller for the input field.
  final TextEditingController controller;

  /// Callback fired when the send button is tapped.
  final VoidCallback onSend;

  /// Placeholder text shown when the field is empty.
  final String hintText;

  /// Accent color for the send button. Defaults to [NeuroColors.adolescentPrimary].
  final Color? accentColor;

  /// Whether the input field is enabled (disables send button when false).
  final bool isEnabled;

  /// Optional callback to send a voice message file.
  /// If null, the microphone button will be hidden.
  final Future<void> Function(File audioFile)? onSendVoice;

  @override
  State<NeuroChatInput> createState() => _NeuroChatInputState();
}

class _NeuroChatInputState extends State<NeuroChatInput> {
  final VoiceRecorderService _recorder = VoiceRecorderService();
  bool _isRecording = false;
  Duration _recordingDuration = Duration.zero;
  StreamSubscription<Duration>? _durationSubscription;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording and send voice message
      final filePath = await _recorder.stopRecording();
      if (filePath != null && widget.onSendVoice != null) {
        await widget.onSendVoice!(File(filePath));
      }
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      _durationSubscription?.cancel();
      _durationSubscription = null;
    } else {
      // Start recording
      final granted = await _recorder.startRecording();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required to record voice messages.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _durationSubscription?.cancel();
      _durationSubscription = _recorder.recordingDurationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _recordingDuration = duration;
          });
        }
      });
    }
  }

  Future<void> _cancelRecording() async {
    await _recorder.cancelRecording();
    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
    _durationSubscription?.cancel();
    _durationSubscription = null;
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? NeuroColors.adolescentPrimary;
    final showVoiceButton = widget.onSendVoice != null;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: NeuroColors.surface,
          boxShadow: [NeuroShadows.sm],
        ),
        child: _isRecording ? _buildRecordingUI(color) : _buildNormalUI(color, showVoiceButton),
      ),
    );
  }

  Widget _buildNormalUI(Color color, bool showVoiceButton) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showVoiceButton) ...[
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: widget.isEnabled ? _toggleRecording : null,
              icon: const Icon(Icons.mic, size: 20),
              color: color,
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeuroRadius.xl),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: NeuroColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            enabled: widget.isEnabled,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: widget.isEnabled ? color : color.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: widget.isEnabled ? widget.onSend : null,
            icon: const Icon(Icons.send, size: 20),
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingUI(Color color) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.delete, size: 20),
            color: Colors.red,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            tooltip: 'Cancel recording',
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            VoiceRecorderService.formatDuration(_recordingDuration),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _toggleRecording,
            icon: const Icon(Icons.send, size: 20),
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            tooltip: 'Send voice message',
          ),
        ),
      ],
    );
  }
}
