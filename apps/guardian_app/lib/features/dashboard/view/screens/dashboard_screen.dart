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
            onPressed: () =>
                ref.read(guardianDashboardControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Summary Stats
          SliverToBoxAdapter(
            child: dashboardAsync.when(
              data: (data) => _buildSummarySection(context, data),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Error loading dashboard',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      err.toString(),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error loading alerts: $err',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
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
                    subtitle:
                        'Add another child to your monitoring dashboard',
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

  Widget _buildSummarySection(
      BuildContext context, GuardianDashboardData data) {
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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good day,',
                        style: TextStyle(
                          fontSize: 16,
                          color: NeuroColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Guardian',
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
                    backgroundColor:
                        NeuroColors.guardianPrimary.withValues(alpha: 0.2),
                    child: const Icon(Icons.person,
                        color: NeuroColors.guardianPrimary),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Summary Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Linked',
                      value: data.totalAdolescentsLinked.toString(),
                      icon: Icons.people_outline,
                      color: NeuroColors.guardianPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Journals',
                      value: data.totalJournalCount.toString(),
                      icon: Icons.book_outlined,
                      color: NeuroColors.adolescentPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Alerts',
                      value: data.unviewedAlertsCount.toString(),
                      icon: Icons.notifications_outlined,
                      color: data.unviewedAlertsCount > 0
                          ? NeuroColors.alertHigh
                          : NeuroColors.alertLow,
                    ),
                  ),
                ],
              ),

              // Adolescent Risk Cards
              if (data.adolescentRisks.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Your Adolescents',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NeuroColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...data.adolescentRisks.map(
                  (risk) => _AdolescentRiskCard(risk: risk),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                fontSize: 11, color: NeuroColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _AdolescentRiskCard extends StatelessWidget {
  final AdolescentRisk risk;

  const _AdolescentRiskCard({required this.risk});

  Color _riskColor(String level) => switch (level.toLowerCase()) {
        'high' => NeuroColors.alertHigh,
        'medium' => NeuroColors.alertMedium,
        _ => NeuroColors.alertLow,
      };

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(risk.currentRiskLevel);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: riskColor.withValues(alpha: 0.15),
            child: Icon(Icons.person, color: riskColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  risk.adolescentName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  'Risk: ${risk.currentRiskLevel.toUpperCase()}',
                  style: TextStyle(color: riskColor, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              risk.currentRiskLevel.toUpperCase(),
              style: TextStyle(
                  color: riskColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11),
            ),
          ),
        ],
      ),
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
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child:
              Icon(icon, color: Theme.of(context).primaryColor),
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
