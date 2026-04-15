import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../services/voice_recorder_service.dart';
import '../models/conversation.dart';

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
    this.messageType = MessageContentType.text,
    this.attachmentUrl,
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

  /// The type of content in this message.
  final MessageContentType messageType;

  /// URL or file path to the attached media file.
  final String? attachmentUrl;

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

  Future<void> _togglePlayback(String? url) async {
    if (_isPlaying) {
      await _player.stopPlayback();
      setState(() => _isPlaying = false);
    } else {
      if (url != null) {
        setState(() => _isPlaying = true);
        await _player.playAudio(url);
        setState(() => _isPlaying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.userColor ?? NeuroColors.adolescentPrimary;
    final formattedTime = DateFormat('h:mm a').format(widget.timestamp);
    final label = widget.senderLabel ?? (widget.isUser ? 'You' : 'Contact');

    final isVoice = widget.messageType == MessageContentType.audio;

    return Semantics(
      label: isVoice
          ? '$label sent a voice message. Sent at $formattedTime'
          : widget.messageType == MessageContentType.image
              ? '$label sent an image. Sent at $formattedTime'
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
          child: _buildBubbleContent(context, accentColor, formattedTime),
        ),
      ),
    );
  }

  Widget _buildBubbleContent(BuildContext context, Color accentColor, String formattedTime) {
    final effectiveType = widget.messageType;

    final effectiveUrl = widget.attachmentUrl;

    return switch (effectiveType) {
      MessageContentType.audio => _buildVoiceBubble(accentColor, formattedTime, effectiveUrl),
      MessageContentType.image => _buildImageBubble(context, accentColor, formattedTime, effectiveUrl),
      MessageContentType.video => _buildVideoBubble(context, accentColor, formattedTime, effectiveUrl),
      MessageContentType.file => _buildFileBubble(accentColor, formattedTime, effectiveUrl),
      _ => _buildTextBubble(accentColor, formattedTime),
    };
  }

  Widget _buildVoiceBubble(Color accentColor, String formattedTime, [String? audioUrl]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play/Pause button
            GestureDetector(
              onTap: () => _togglePlayback(audioUrl),
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

  Widget _buildImageBubble(BuildContext context, Color accentColor, String formattedTime, String? imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageUrl != null && imageUrl.isNotEmpty)
          GestureDetector(
            onTap: () => _showFullScreenImage(context, imageUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.error_outline),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        if (widget.messageContent.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.messageContent,
            style: TextStyle(
              color: widget.isUser ? Colors.white : NeuroColors.onSurface,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
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

  Widget _buildVideoBubble(BuildContext context, Color accentColor, String formattedTime, String? videoUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.videocam, color: Colors.white54, size: 48),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Play Video', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.messageContent.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.messageContent,
            style: TextStyle(
              color: widget.isUser ? Colors.white : NeuroColors.onSurface,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
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

  Widget _buildFileBubble(Color accentColor, String formattedTime, String? fileUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isUser ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isUser ? Colors.white.withValues(alpha: 0.2) : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file_rounded,
                color: widget.isUser ? Colors.white : accentColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileUrl?.split('/').last ?? 'Attachment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.isUser ? Colors.white : NeuroColors.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Tap to download',
                      style: TextStyle(
                        color: widget.isUser ? Colors.white70 : NeuroColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Center(
                child: Hero(
                  tag: imageUrl,
                  child: InteractiveViewer(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

