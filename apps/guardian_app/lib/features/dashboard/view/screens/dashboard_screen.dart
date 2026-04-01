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
      body: Stack(
        children: [
          // Mesh Gradient Background (Midnight Navy)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: NeuroColors.guardianMesh,
                ),
              ),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: kToolbarHeight + 40)),
              
              // Welcome Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPERATIONAL STATUS:',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: NeuroColors.commandPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'All Systems Nominal',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 28),
                      ),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.1),
                ),
              ),

              // Summary Bento Grid
              SliverToBoxAdapter(
                child: dashboardAsync.when(
                  data: (data) => _buildBentoSummary(context, data),
                  loading: () => _buildLoadingGrid(context),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),

              // Priority Alerts Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    children: [
                      const Icon(Icons.radar, color: NeuroColors.commandAlertPink, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'ACTIVE MONITORING',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          letterSpacing: 2,
                          color: NeuroColors.commandAlertPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Alerts List
              alertsAsync.when(
                data: (alerts) {
                  if (alerts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: NeuroCard(
                          child: const Center(child: Text('No anomalies detected.')),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final alert = alerts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NeuroAlertCard(
                              alert: alert,
                              onTap: () => context.push('/alert-details/${alert.alertId}'),
                            ),
                          ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
                        },
                        childCount: alerts.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SYSTEM ACTIONS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2),
                      ),
                      const SizedBox(height: 16),
                      NeuroCard(
                        onTap: () => context.push('/register-adolescent'),
                        child: Row(
                          children: [
                            const Icon(Icons.person_add_outlined, color: NeuroColors.commandPrimary),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Register New Link', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Initialize a new monitoring node', style: TextStyle(fontSize: 12, color: NeuroColors.onSurface.withValues(alpha: 0.7))),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoSummary(BuildContext context, GuardianDashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: NeuroDashboardCard(
                  title: 'Sentiment',
                  subtitle: 'Weekly Performance',
                  height: 240,
                  child: NeuroTrendChart(trends: data.weeklyTrends, showDots: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    _buildQuickStat(context, 'Alerts', data.unviewedAlertsCount.toString(), data.unviewedAlertsCount > 0 ? NeuroColors.commandAlertPink : NeuroColors.alertLow),
                    const SizedBox(height: 12),
                    _buildQuickStat(context, 'Nodes', data.totalAdolescentsLinked.toString(), NeuroColors.commandPrimary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NeuroCard(
            onTap: () => context.push('/adolescent/${data.adolescentId}'),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: NeuroColors.commandPrimary.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: NeuroColors.commandPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.adolescentName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text('Status: Monitored', style: TextStyle(fontSize: 12, color: NeuroColors.onSurface.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildQuickStat(BuildContext context, String label, String value, Color color) {
    return NeuroCard(
      padding: const EdgeInsets.all(16),
      height: 114,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1)),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          color: NeuroColors.commandSurface,
          borderRadius: BorderRadius.circular(24),
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.3, end: 0.8, duration: 800.ms),
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
