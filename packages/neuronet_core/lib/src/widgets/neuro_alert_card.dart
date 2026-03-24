import 'package:flutter/material.dart';
import '../models/alert.dart';
import '../models/enums.dart';
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
    final severityColor = _getSeverityColor();
    final icon = _getAlertIcon();

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
                    Text(
                      _getAlertTitle(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: NeuroColors.onSurface,
                      ),
                    ),
                    _SeverityBadge(severity: alert.severityLevel, color: severityColor),
                  ],
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

  Color _getSeverityColor() {
    return switch (alert.severityLevel) {
      AlertSeverity.low => NeuroColors.alertLow,
      AlertSeverity.medium => NeuroColors.alertMedium,
      AlertSeverity.high => NeuroColors.alertHigh,
    };
  }

  IconData _getAlertIcon() {
    return switch (alert.alertType) {
      AlertType.moodDrop => Icons.trending_down,
      AlertType.emotionalPattern => Icons.psychology_outlined,
      AlertType.journalFrequency => Icons.history_edu,
      AlertType.contentFlag => Icons.report_problem_outlined,
    };
  }

  String _getAlertTitle() {
    return switch (alert.alertType) {
      AlertType.moodDrop => 'Mood Drop Detected',
      AlertType.emotionalPattern => 'Emotional Pattern',
      AlertType.journalFrequency => 'Journal Frequency',
      AlertType.contentFlag => 'Content Flag',
    };
  }

  String _formatTime(DateTime dateTime) {
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
  final AlertSeverity severity;
  final Color color;

  const _SeverityBadge({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity.name.toUpperCase(),
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
