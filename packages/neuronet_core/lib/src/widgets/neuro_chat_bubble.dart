import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/voice_recorder_service.dart';

/// Shared chat message bubble widget used across AI chat, counselor chat,
/// and guardian counselor messaging screens.
///
/// Provides consistent styling, accessibility support, timestamp formatting,
/// and voice message playback support.
class NeuroChatBubble extends StatefulWidget {
  const NeuroChatBubble({
    super.key,
    required this.messageContent,
    required this.timestamp,
    required this.isUser,
    this.senderLabel,
    this.userColor,
    this.maxWidthFactor = 0.75,
    this.isVoiceMessage = false,
    this.voiceUrl,
  });

  /// The message text to display.
  final String messageContent;

  /// When the message was sent.
  final DateTime timestamp;

  /// Whether this message was sent by the current user.
  final bool isUser;

  /// Label for screen readers (e.g., "You", "Counselor", "NEURO Assistant").
  final String? senderLabel;

  /// Accent color for user messages. Defaults to [NeuroColors.adolescentPrimary].
  final Color? userColor;

  /// Maximum width as a fraction of screen width. Defaults to 0.75.
  final double maxWidthFactor;

  /// Whether this is a voice message.
  final bool isVoiceMessage;

  /// URL or file path to the voice audio file.
  final String? voiceUrl;

  @override
  State<NeuroChatBubble> createState() => _NeuroChatBubbleState();
}

class _NeuroChatBubbleState extends State<NeuroChatBubble> {
  final VoiceRecorderService _player = VoiceRecorderService();
  bool _isPlaying = false;

  @override
  void dispose() {
    _player.stopPlayback();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _player.stopPlayback();
      setState(() => _isPlaying = false);
    } else {
      if (widget.voiceUrl != null) {
        setState(() => _isPlaying = true);
        await _player.playAudio(widget.voiceUrl!);
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.userColor ?? NeuroColors.adolescentPrimary;
    final formattedTime = DateFormat('h:mm a').format(widget.timestamp);
    final label = widget.senderLabel ?? (widget.isUser ? 'You' : 'Contact');

    return Semantics(
      label: widget.isVoiceMessage
          ? '$label sent a voice message. Sent at $formattedTime'
          : '$label said: ${widget.messageContent}. Sent at $formattedTime',
      child: Align(
        alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * widget.maxWidthFactor,
          ),
          decoration: BoxDecoration(
            color: widget.isUser ? accentColor : NeuroColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(widget.isUser ? 16 : 4),
              bottomRight: Radius.circular(widget.isUser ? 4 : 16),
            ),
            boxShadow: [
              if (!widget.isUser) NeuroShadows.sm,
            ],
          ),
          child: widget.isVoiceMessage
              ? _buildVoiceBubble(accentColor, formattedTime)
              : _buildTextBubble(accentColor, formattedTime),
        ),
      ),
    );
  }

  Widget _buildVoiceBubble(Color accentColor, String formattedTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play/Pause button
            GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.isUser ? Colors.white : accentColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: widget.isUser ? accentColor : Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Waveform visualization (simplified)
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: List.generate(
                  12,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 3,
                    height: 12 + (index % 3) * 6.0,
                    decoration: BoxDecoration(
                      color: (widget.isUser ? Colors.white : accentColor)
                          .withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Duration label
            Text(
              '🎤 Voice',
              style: TextStyle(
                color: widget.isUser
                    ? Colors.white.withValues(alpha: 0.9)
                    : NeuroColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          formattedTime,
          style: TextStyle(
            color: widget.isUser
                ? Colors.white.withValues(alpha: 0.7)
                : NeuroColors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildTextBubble(Color accentColor, String formattedTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.messageContent.isEmpty ? '(empty message)' : widget.messageContent,
          style: TextStyle(
            color: widget.isUser ? Colors.white : NeuroColors.onSurface,
            fontSize: 15,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formattedTime,
          style: TextStyle(
            color: widget.isUser
                ? Colors.white.withValues(alpha: 0.7)
                : NeuroColors.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
