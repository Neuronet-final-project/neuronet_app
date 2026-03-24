import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(guardianDashboardControllerProvider);
    final alertsAsync = ref.watch(guardianAlertsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guardian Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(guardianDashboardControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Summary Stats
          SliverToBoxAdapter(
            child: dashboardAsync.when(
              data: (data) => _buildSummarySection(data),
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              )),
              error: (err, stack) => Center(child: Text('Error loading dashboard: $err')),
            ),
          ),

          // Priority Alerts Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Priority Alerts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NeuroColors.onSurface,
                ),
              ),
            ),
          ),

          // Alerts List
          alertsAsync.when(
            data: (alerts) {
              if (alerts.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No active alerts at this time.'),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final alert = alerts[index];
                    return NeuroAlertCard(
                      alert: alert,
                      onTap: () => context.go('/alerts/${alert.alertId}'),
                    );
                  },
                  childCount: alerts.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text('Error loading alerts: $err')),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSummarySection(GuardianDashboardData data) {
    // Calculate stats from weekly trends
    final avgEmotionalScore = data.weeklyTrends.isEmpty 
        ? 0.0 
        : data.weeklyTrends.map((t) => t.sentimentScore).reduce((a, b) => a + b) / data.weeklyTrends.length;
    
    final totalJournals = data.weeklyTrends.isEmpty 
        ? 0 
        : data.weeklyTrends.map((t) => t.journalCount ?? 0).reduce((a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Insights for ${data.adolescentName}',
              style: const TextStyle(
                fontSize: 14,
                color: NeuroColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                NeuroSummaryCard(
                  label: 'Emotional Score',
                  value: avgEmotionalScore.toStringAsFixed(1),
                  icon: Icons.sentiment_satisfied_alt,
                  color: NeuroColors.alertLow,
                  subtitle: 'Weekly Average',
                ),
                NeuroSummaryCard(
                  label: 'Journal Count',
                  value: totalJournals.toString(),
                  icon: Icons.history_edu,
                  color: NeuroColors.adolescentPrimary,
                  subtitle: 'Past 7 Days',
                ),
                NeuroSummaryCard(
                  label: 'Active Alerts',
                  value: data.activeAlerts.toString(),
                  icon: Icons.notification_important,
                  color: data.activeAlerts > 0 ? NeuroColors.alertHigh : NeuroColors.alertLow,
                  subtitle: 'Requires Review',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
