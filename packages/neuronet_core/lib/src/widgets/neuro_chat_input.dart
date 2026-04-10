import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared chat message input widget used across AI chat, counselor chat,
/// and guardian counselor messaging screens.
///
/// Provides a text field with a send button, proper padding for system bars,
/// and consistent styling.
class NeuroChatInput extends StatelessWidget {
  const NeuroChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type your message...',
    this.accentColor,
    this.isEnabled = true,
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

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? NeuroColors.adolescentPrimary;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: NeuroColors.surface,
          boxShadow: [NeuroShadows.sm],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
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
                enabled: isEnabled,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: isEnabled ? color : color.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: isEnabled ? onSend : null,
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
        ),
      ),
    );
  }
}
