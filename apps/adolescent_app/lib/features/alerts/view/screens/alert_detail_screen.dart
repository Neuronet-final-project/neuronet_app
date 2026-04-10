import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';

class AdolescentAlertDetailScreen extends StatelessWidget {
  const AdolescentAlertDetailScreen({
    super.key,
    required this.alert,
  });

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Friendly, playful UI
    final color = _getFriendlyColor(alert.severityLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insight Detail'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIcon(alert.alertType),
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _getFriendlyTitle(alert.alertType),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pattern noticed on ${_formatFullDate(alert.createdAt)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Trigger Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome, size: 20, color: color),
                            const SizedBox(width: 8),
                            Text(
                              'What we noticed',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          alert.triggerDescription,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Non-clinical suggestion section
                   Text(
                    'Thinking about this?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ActionTile(
                    icon: Icons.edit_note_rounded,
                    title: 'Keep Journaling',
                    subtitle: 'Sharing your thoughts helps us find more patterns.',
                    onTap: () {}, // Navigate to journal
                  ),
                  _ActionTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Chat with Counselor',
                    subtitle: 'It\'s always good to reach out if you feel like it.',
                    onTap: () => context.push(AdolescentRoutes.counselorChat),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer Disclaimer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'These insights are patterns we noticed based on your activity. They aren\'t a diagnosis or medical advice. We\'re just here to help you understand your emotional journey.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFriendlyColor(String severity) {
    return switch (severity.toLowerCase()) {
      'high' => NeuroColors.alertMedium, // Non-alarming
      _ => NeuroColors.alertLow,
    };
  }

  IconData _getIcon(String type) {
    return switch (type.toLowerCase()) {
      'emotionalpattern' => Icons.show_chart_rounded,
      'mooddrop' => Icons.water_drop_outlined,
      'journalfrequency' => Icons.history_edu_rounded,
      'contentflag' => Icons.lightbulb_outline_rounded,
      _ => Icons.notifications_none_rounded,
    };
  }

  String _getFriendlyTitle(String type) {
    return switch (type.toLowerCase()) {
      'emotionalpattern' => 'Mood Pattern',
      'mooddrop' => 'Energy Shift',
      'journalfrequency' => 'Activity Update',
      'contentflag' => 'Mindfulness Prompt',
      _ => 'Notice',
    };
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onTap: onTap,
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
