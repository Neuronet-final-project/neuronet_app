import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NeuroEmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final bool isMini;

  const NeuroEmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color,
    this.onActionPressed,
    this.actionLabel,
    this.isMini = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = color ?? theme.primaryColor;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 24, 
        vertical: isMini ? 24 : 48,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isMini ? 12 : 20),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: isMini ? 32 : 48,
              color: accentColor,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 2000.ms,
                curve: Curves.easeInOut,
              )
              .shimmer(
                delay: 1000.ms,
                duration: 2000.ms,
                color: Colors.white.withValues(alpha: 0.2),
              ),
          SizedBox(height: isMini ? 16 : 24),
          Text(
            title,
            style: (isMini ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (onActionPressed != null && actionLabel != null) ...[
            SizedBox(height: isMini ? 20 : 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: isMini ? 12 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
