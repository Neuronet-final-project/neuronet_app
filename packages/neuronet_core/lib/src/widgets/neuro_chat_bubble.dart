import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

/// Shared chat message bubble widget used across AI chat, counselor chat,
/// and guardian counselor messaging screens.
///
/// Provides consistent styling, accessibility support, and timestamp formatting.
class NeuroChatBubble extends StatelessWidget {
  const NeuroChatBubble({
    super.key,
    required this.messageContent,
    required this.timestamp,
    required this.isUser,
    this.senderLabel,
    this.userColor,
    this.maxWidthFactor = 0.75,
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

  @override
  Widget build(BuildContext context) {
    final accentColor = userColor ?? NeuroColors.adolescentPrimary;
    final formattedTime = DateFormat('h:mm a').format(timestamp);
    final label = senderLabel ?? (isUser ? 'You' : 'Contact');

    return Semantics(
      label: '$label said: $messageContent. Sent at $formattedTime',
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
          ),
          decoration: BoxDecoration(
            color: isUser ? accentColor : NeuroColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            boxShadow: [
              if (!isUser) NeuroShadows.sm,
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                messageContent,
                style: TextStyle(
                  color: isUser ? Colors.white : NeuroColors.onSurface,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTime,
                style: TextStyle(
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.7)
                      : NeuroColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
