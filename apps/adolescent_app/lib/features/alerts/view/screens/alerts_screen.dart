import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/alerts_provider.dart';

class AdolescentAlertsScreen extends ConsumerWidget {
  const AdolescentAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(adolescentAlertsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(adolescentAlertsControllerProvider.notifier).refresh(),
            tooltip: 'Refresh alerts',
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (state) {
          if (state.error != null) {
            return NeuroErrorWidget(
              message: state.error!,
              onRetry: () => ref.read(adolescentAlertsControllerProvider.notifier).refresh(),
            );
          }

          final alerts = state.alerts;
          if (alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: NeuroEmptyState(
                  title: 'No new insights yet!',
                  message: 'Keep journaling to see patterns and insights appear here.',
                  icon: Icons.bubble_chart_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _InsightCard(alert: alert);
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 4,
          itemBuilder: (context, index) => const NeuroSkeletonCard(),
        ),
        error: (err, stack) => NeuroErrorWidget(
          message: 'Could not load insights.',
          onRetry: () => ref.read(adolescentAlertsControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Non-alarming severity colors/labels for teens
    final color = switch (alert.severityLevel.toLowerCase()) {
      'high' => NeuroColors.alertMedium.withValues(alpha: 0.8), // Avoid red for teens
      'medium' => NeuroColors.alertLow,
      _ => NeuroColors.alertLow.withValues(alpha: 0.6),
    };

    // Friendly emotion labels for teens
    final friendlyEmotions = alert.detectedEmotions.take(3).map(_getFriendlyEmotion).toList();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/alerts/${alert.alertId}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getFriendlyType(alert.alertType),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(alert.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alert.aiSummary.isNotEmpty
                    ? _makeTeenFriendly(alert.aiSummary)
                    : 'A new pattern noticed',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (alert.aiSummary.isEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  alert.triggerDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],

              // Friendly emotion chips for teens
              if (friendlyEmotions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: friendlyEmotions.map((emotion) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        emotion,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFriendlyType(String type) {
    return switch (type.toLowerCase()) {
      'emotionalpattern' => 'Mood Pattern',
      'mooddrop' => 'Energy Shift',
      'journalfrequency' => 'Activity Note',
      'contentflag' => 'Mindfulness Prompt',
      'high_risk_sentiment' => 'Mood Pattern',
      'high_risk_chat' => 'Chat Insight',
      _ => 'Notice',
    };
  }

  /// Make raw AI emotions teen-friendly
  String _getFriendlyEmotion(String emotion) {
    return switch (emotion.toLowerCase()) {
      'sadness' => '😔 Feeling down',
      'loneliness' => '🫂 Feeling alone',
      'hopelessness' => '💭 Tough thoughts',
      'fear' => '😨 Feeling scared',
      'anger' => '😤 Feeling frustrated',
      'nervousness' => '😰 Feeling nervous',
      'anxiety' => '🌊 Waves of worry',
      'disappointment' => '😞 Disappointed',
      'grief' => '💔 Heavy heart',
      'annoyance' => '😒 Annoyed',
      'confusion' => '🤔 Confused',
      _ => '💫 $emotion',
    };
  }

  /// Convert AI summary to teen-friendly language
  String _makeTeenFriendly(String summary) {
    return summary
        .replaceAll('The adolescent', 'You')
        .replaceAll('the adolescent', 'you')
        .replaceAll('signs of', 'patterns around')
        .replaceAll('Main concern:', 'What we noticed:')
        .replaceAll('Risk level:', '')
        .replaceAll('detected over', 'noticed in');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}';
  }
}
