import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';
import '../../providers/alerts_provider.dart';
import '../../../channels/providers/channels_provider.dart';

class AdolescentAlertDetailScreen extends ConsumerWidget {
  const AdolescentAlertDetailScreen({
    super.key,
    required this.alertId,
  });

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(adolescentAlertsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.localizations.insightDetail),
        elevation: 0,
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
          final alert = alerts.firstWhere(
            (a) => a.alertId == alertId,
            orElse: () => throw Exception('Alert not found'),
          );
          return _buildContent(context, ref, theme, alert);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => NeuroErrorWidget(
          message: context.localizations.failedToLoadAlertDetails,
          onRetry: () => ref.read(adolescentAlertsControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Alert alert,
  ) {
    final color = _getFriendlyColor(alert.severityLevel);
    
    // Safely pull from behavioral_analysis map if available
    final dynamic rawEmotions = alert.behavioralAnalysis?['emotions'] ?? alert.detectedEmotions;
    final List<String> emotionsList = (rawEmotions is List) ? rawEmotions.cast<String>() : <String>[];
    final friendlyEmotions = emotionsList.map((e) => _getFriendlyEmotion(context, e)).toList();
    
    final String aiSummary = alert.behavioralAnalysis?['behavioral_summary'] as String? ?? alert.aiSummary;
    
    final bool hasRecommendations = alert.channelRecommendations != null && 
                                   alert.channelRecommendations!['recommended_channels'] != null &&
                                   (alert.channelRecommendations!['recommended_channels'] as List).isNotEmpty;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.05),
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
                    color: color.withValues(alpha: 0.2),
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
                  _getFriendlyTitle(context, alert.alertType),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.localizations.patternNoticedOn(_formatFullDate(alert.createdAt)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Summary (teen-friendly)
                if (aiSummary.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: NeuroColors.surface,
                      borderRadius: BorderRadius.circular(NeuroRadius.xl),
                      border: Border.all(
                        color: NeuroColors.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [NeuroShadows.sm],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, size: 20, color: color),
                            const SizedBox(width: 8),
                            Text(
                              context.localizations.whatWeNoticed,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _makeTeenFriendly(aiSummary),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: NeuroColors.surface,
                      borderRadius: BorderRadius.circular(NeuroRadius.xl),
                      border: Border.all(
                        color: NeuroColors.outline.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      boxShadow: [NeuroShadows.sm],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline_rounded, size: 20, color: color),
                            const SizedBox(width: 8),
                            Text(
                              context.localizations.whatWeNoticed,
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
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Emotions section (teen-friendly with emojis)
                if (friendlyEmotions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    context.localizations.feelingsPickedUp,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: friendlyEmotions.map((emotion) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          emotion,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 32),

                // AI Channel Recommendations
                if (hasRecommendations) ...[
                  Text(
                    context.localizations.groupsHelp,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...(alert.channelRecommendations?['recommended_channels'] as List? ?? []).map((ch) {
                    final map = ch as Map<String, dynamic>;
                    final channelId = map['channel_id'] as String?;
                    
                    return Consumer(
                      builder: (context, ref, _) {
                        final channelsAsync = ref.watch(channelsControllerProvider);
                        final channel = channelsAsync.value?.channels.where(
                          (c) => c.channelId == channelId
                        ).firstOrNull;
                        final isFollowed = channel?.isFollowed ?? false;

                        return _ActionTile(
                          icon: Icons.group_rounded,
                          title: map['channel_name'] as String? ?? 'Support Group',
                          subtitle: context.localizations.channelRecSubtitle,
                          onTap: () {
                            if (channelId != null) {
                              context.push('${AdolescentRoutes.channels}/$channelId');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Channel not found. Please try again later.'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          trailing: channelId != null ? FilledButton.tonal(
                            onPressed: () {
                              ref.read(channelsControllerProvider.notifier).toggleFollow(channelId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isFollowed ? context.localizations.leftGroup : context.localizations.joinedGroup(map['channel_name'] as String? ?? '')),
                                  behavior: SnackBarBehavior.floating,
                                )
                              );
                            },
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Text(isFollowed ? context.localizations.joined : context.localizations.join),
                          ) : null,
                        );
                      }
                    );
                  }),
                  const SizedBox(height: 32),
                ],

                // Non-clinical suggestion section
                Text(
                  context.localizations.thinkingAboutThis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _ActionTile(
                  icon: Icons.edit_note_rounded,
                  title: context.localizations.keepJournaling,
                  subtitle: context.localizations.journalingSubtitle,
                  onTap: () {},
                ),
                _ActionTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: context.localizations.chatWithCounselor,
                  subtitle: context.localizations.chatWithCounselorSubtitle,
                  onTap: () => context.push(AdolescentRoutes.counselorChat),
                ),

                const SizedBox(height: 40),

                // Footer Disclaimer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.localizations.alertDisclaimer,
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
      'high_risk_sentiment' => Icons.show_chart_rounded,
      'high_risk_chat' => Icons.chat_bubble_outline_rounded,
      _ => Icons.notifications_none_rounded,
    };
  }

  String _getFriendlyTitle(BuildContext context, String type) {
    final l10n = context.localizations;
    return switch (type.toLowerCase()) {
      'emotionalpattern' => l10n.moodPattern,
      'mooddrop' => l10n.energyShift,
      'journalfrequency' => l10n.activityUpdate,
      'contentflag' => l10n.mindfulnessPrompt,
      'high_risk_sentiment' => l10n.moodPattern,
      'high_risk_chat' => l10n.chatInsight,
      _ => l10n.notice,
    };
  }

  String _getFriendlyEmotion(BuildContext context, String emotion) {
    final l10n = context.localizations;
    return switch (emotion.toLowerCase()) {
      'sadness' => l10n.emotionSadness,
      'loneliness' => l10n.emotionLoneliness,
      'hopelessness' => l10n.emotionHopelessness,
      'fear' => l10n.emotionFear,
      'anger' => l10n.emotionAnger,
      'nervousness' => l10n.emotionNervousness,
      'anxiety' => l10n.emotionAnxiety,
      'disappointment' => l10n.emotionDisappointment,
      'grief' => l10n.emotionGrief,
      'annoyance' => l10n.emotionAnnoyance,
      'confusion' => l10n.emotionConfusion,
      _ => '💫 $emotion',
    };
  }

  String _makeTeenFriendly(String summary) {
    return summary
        .replaceAll('The adolescent', 'You')
        .replaceAll('the adolescent', 'you')
        .replaceAll('signs of', 'patterns around')
        .replaceAll('Main concern:', 'What we noticed:')
        .replaceAll('Risk level:', '')
        .replaceAll('detected over', 'noticed in');
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
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

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
        title: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
