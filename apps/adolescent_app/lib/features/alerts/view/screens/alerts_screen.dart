import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/alerts_provider.dart';

class AdolescentAlertsScreen extends ConsumerStatefulWidget {
  const AdolescentAlertsScreen({super.key});

  @override
  ConsumerState<AdolescentAlertsScreen> createState() => _AdolescentAlertsScreenState();
}

class _AdolescentAlertsScreenState extends ConsumerState<AdolescentAlertsScreen> {
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    // Mark alerts as viewed when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAlertsAsViewed();
    });
  }

  Future<void> _markAlertsAsViewed() async {
    final alertsState = ref.read(adolescentAlertsControllerProvider).value;
    if (alertsState == null || alertsState.alerts.isEmpty) {
      print('[Insights] No alerts to mark as viewed');
      return;
    }

    // Check if there are any unviewed alerts
    final unviewedAlerts = alertsState.alerts.where((a) => !a.viewedStatus).toList();
    print('[Insights] Found ${unviewedAlerts.length} unviewed alerts out of ${alertsState.alerts.length} total');
    
    if (unviewedAlerts.isEmpty) {
      print('[Insights] All alerts already viewed');
      return;
    }

    print('[Insights] Marking ${unviewedAlerts.length} alerts as viewed...');
    // Call the mark viewed method
    await ref.read(adolescentAlertsControllerProvider.notifier).markAllAsViewed();
    print('[Insights] Alerts marked as viewed successfully');
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(adolescentAlertsControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        title: const Text('My Insights', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF7C4DFF),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(adolescentAlertsControllerProvider.notifier).refresh(),
            tooltip: 'Refresh insights',
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE7FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.insights_rounded,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No insights yet!',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D1B6B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Keep journaling and tracking your moods.\nWe\'ll share helpful patterns here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF9E9EB8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Sort alerts by date (newest first)
          final sortedAlerts = [...alerts]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          // Separate recent (last 7 days) and history
          final now = DateTime.now();
          final sevenDaysAgo = now.subtract(const Duration(days: 7));
          final recentAlerts = sortedAlerts.where((a) => a.createdAt.isAfter(sevenDaysAgo)).toList();
          final historyAlerts = sortedAlerts.where((a) => !a.createdAt.isAfter(sevenDaysAgo)).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(adolescentAlertsControllerProvider.notifier).refresh(),
            color: const Color(0xFF7C4DFF),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Recent Insights Section
                if (recentAlerts.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFFB47CFF)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'RECENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${recentAlerts.length} new ${recentAlerts.length == 1 ? 'insight' : 'insights'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF9E9EB8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...recentAlerts.map((alert) => _InsightCard(alert: alert)),
                ],

                // History Section
                if (historyAlerts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => setState(() => _showHistory = !_showHistory),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE4DAF5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.history_rounded, color: Color(0xFF7C4DFF), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Insights History (${historyAlerts.length})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D1B6B),
                              ),
                            ),
                          ),
                          Icon(
                            _showHistory ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                            color: const Color(0xFF7C4DFF),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showHistory) ...[
                    const SizedBox(height: 16),
                    ...historyAlerts.map((alert) => _InsightCard(alert: alert, isHistory: true)),
                  ],
                ],
              ],
            ),
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
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
  const _InsightCard({required this.alert, this.isHistory = false});

  final Alert alert;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine if this insight is unread
    final isUnread = !alert.viewedStatus;
    
    // Non-alarming severity colors/labels for teens
    final color = switch (alert.severityLevel.toLowerCase()) {
      'high' => const Color(0xFFFF7043), // Soft orange instead of red
      'medium' => const Color(0xFFFFB74D), // Amber
      _ => const Color(0xFF64B5F6), // Light blue
    };

    // Friendly emotion labels for teens
    final friendlyEmotions = alert.detectedEmotions.take(3).map(_getFriendlyEmotion).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // Unread: red/pink gradient background, Read: white background
        gradient: isUnread
            ? const LinearGradient(
                colors: [Color(0xFFFFE5E5), Color(0xFFFFF0F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isUnread ? null : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isUnread 
              ? const Color(0xFFFF6B6B).withValues(alpha: 0.4)
              : (isHistory ? const Color(0xFFE4DAF5) : color.withValues(alpha: 0.3)),
          width: isUnread ? 2.5 : (isHistory ? 1 : 2),
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? const Color(0xFFFF6B6B).withValues(alpha: 0.15)
                : (isHistory 
                    ? Colors.black.withValues(alpha: 0.03)
                    : color.withValues(alpha: 0.08)),
            blurRadius: isUnread ? 16 : (isHistory ? 4 : 12),
            offset: Offset(0, isUnread ? 6 : (isHistory ? 2 : 4)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
                    // Unread indicator badge
                    if (isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getFriendlyType(alert.alertType),
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(alert.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnread ? const Color(0xFF9E4A4A) : const Color(0xFF9E9EB8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  alert.aiSummary.isNotEmpty
                      ? _makeTeenFriendly(alert.aiSummary)
                      : alert.triggerDescription,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isUnread ? const Color(0xFF5A1B1B) : const Color(0xFF2D1B6B),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Friendly emotion chips for teens
                if (friendlyEmotions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: friendlyEmotions.map((emotion) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isUnread 
                              ? const Color(0xFFFFD6D6)
                              : const Color(0xFFF3EEFF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isUnread 
                                ? const Color(0xFFFFB3B3)
                                : const Color(0xFFE4DAF5),
                          ),
                        ),
                        child: Text(
                          emotion,
                          style: TextStyle(
                            fontSize: 12,
                            color: isUnread 
                                ? const Color(0xFFD32F2F)
                                : const Color(0xFF7C4DFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 13,
                        color: isUnread ? const Color(0xFFFF6B6B) : color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: isUnread ? const Color(0xFFFF6B6B) : color,
                    ),
                  ],
                ),
              ],
            ),
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
