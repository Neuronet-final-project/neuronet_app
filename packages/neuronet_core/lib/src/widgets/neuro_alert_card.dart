import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../theme/app_theme.dart';
import 'neuro_card.dart';

class NeuroAlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;

  const NeuroAlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(alert.severityLevel);
    final icon = _getAlertIcon(alert.alertType);

    return NeuroCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: severityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getAlertTitle(alert.alertType),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: NeuroColors.onSurface,
                        ),
                      ),
                    ),
                    _SeverityBadge(
                      label: alert.severityLevel.toUpperCase(),
                      color: severityColor,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  alert.adolescentName,
                  style: TextStyle(
                    fontSize: 12,
                    color: NeuroColors.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.triggerDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: NeuroColors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _formatTime(alert.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: NeuroColors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Color _getSeverityColor(String level) =>
      switch (level.toLowerCase()) {
        'high' => NeuroColors.alertHigh,
        'medium' => NeuroColors.alertMedium,
        _ => NeuroColors.alertLow,
      };

  static IconData _getAlertIcon(String type) =>
      switch (type.toLowerCase()) {
        'mood_drop' => Icons.trending_down,
        'emotional_pattern' => Icons.psychology_outlined,
        'journal_frequency' => Icons.history_edu,
        'content_flag' => Icons.report_problem_outlined,
        _ => Icons.warning_amber_outlined,
      };

  static String _getAlertTitle(String type) =>
      switch (type.toLowerCase()) {
        'mood_drop' => 'Mood Drop Detected',
        'emotional_pattern' => 'Emotional Pattern',
        'journal_frequency' => 'Journal Frequency',
        'content_flag' => 'Content Flag',
        _ => 'Alert',
      };

  static String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _SeverityBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _SeverityBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
