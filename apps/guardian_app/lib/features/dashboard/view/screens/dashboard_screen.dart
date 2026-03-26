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
              data: (data) => _buildSummarySection(context, data),
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

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: NeuroColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _QuickActionCard(
                    title: 'Register New Adolescent',
                    subtitle: 'Add another child to your monitoring dashboard',
                    icon: Icons.person_add_outlined,
                    onTap: () => context.push('/register-adolescent'),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, GuardianDashboardData data) {
    // Calculate stats from weekly trends
    final avgEmotionalScore = data.weeklyTrends.isEmpty 
        ? 0.0 
        : data.weeklyTrends.map((t) => t.sentimentScore).reduce((a, b) => a + b) / data.weeklyTrends.length;
    
    final totalJournals = data.weeklyTrends.isEmpty 
        ? 0 
        : data.weeklyTrends.map((t) => t.journalCount ?? 0).reduce((a, b) => a + b);

    return Column(
      children: [
        // Premium Hero Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 32),
          decoration: const BoxDecoration(
            color: NeuroColors.guardianSurface,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning,',
                        style: TextStyle(
                          fontSize: 16,
                          color: NeuroColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Guardian', // In real app, get from auth
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: NeuroColors.guardianPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: NeuroColors.guardianPrimary.withOpacity(0.2),
                    child: const Icon(Icons.person, color: NeuroColors.guardianPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Adolescent Status Overview
              InkWell(
                onTap: () => context.push('/adolescent/mock_id'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.adolescentName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Last check-in: 2h ago',
                            style: TextStyle(
                              fontSize: 12,
                              color: NeuroColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _buildQuickStat(
                        label: 'Score',
                        value: avgEmotionalScore.toStringAsFixed(1),
                        color: NeuroColors.alertLow,
                      ),
                      const SizedBox(width: 16),
                      _buildQuickStat(
                        label: 'Journals',
                        value: totalJournals.toString(),
                        color: NeuroColors.adolescentPrimary,
                      ),
                      const SizedBox(width: 16),
                      _buildQuickStat(
                        label: 'Alerts',
                        value: data.activeAlerts.toString(),
                        color: data.activeAlerts > 0 ? NeuroColors.alertHigh : NeuroColors.alertLow,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Weekly Trend Chart
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weekly Sentiment Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NeuroColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: NeuroTrendChart(trends: data.weeklyTrends),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _chartLegend('Sentiment', NeuroColors.guardianPrimary),
                  const SizedBox(width: 16),
                  _chartLegend('Journals', NeuroColors.adolescentPrimary),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat({required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: NeuroColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _chartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: NeuroColors.onSurfaceVariant)),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
