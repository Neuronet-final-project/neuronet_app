import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import 'package:guardian_app/features/profile/providers/profile_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: NeuroColors.guardianPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Dashboard'),
              background: Container(color: NeuroColors.guardianPrimary),
            ),
          ),
          _buildDataSlivers(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _QuickActionCard(
                    title: 'View Alerts',
                    subtitle: 'Check active alerts for your adolescents',
                    icon: Icons.notifications_active_outlined,
                    onTap: () => context.push('/alerts'),
                  ),
                  _QuickActionCard(
                    title: 'Add Adolescent',
                    subtitle: 'Link a new account to your command center',
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

  Widget _buildDataSlivers(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final dashboardState = ref.watch(guardianDashboardControllerProvider);

        return dashboardState.when(
          data: (data) {
            final isFallback = data.totalAdolescentsLinked == 0 && data.moodDistribution.isEmpty;

            return SliverToBoxAdapter(
              child: Column(
                children: [
                  if (isFallback)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: const Text(
                          'Note: Guardian activity data is temporarily unavailable. Quick Actions are active.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ),
                  _buildSummarySection(context, data),
                ],
              ),
            );
          },
          loading: () => const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: NeuroErrorWidget(
                  message: 'Dashboard data failed to load.',
                  onRetry: () => ref.read(guardianDashboardControllerProvider.notifier).refresh(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(BuildContext context, GuardianDashboardData data) {
    return Column(
      children: [
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
                      Consumer(
                        builder: (context, ref, child) {
                          final profileAsync = ref.watch(guardianProfileControllerProvider);
                          final name = profileAsync.maybeWhen(
                            data: (user) => user.fullName.split(' ')[0],
                            orElse: () => 'Guardian',
                          );
                          return Text(
                            name,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: NeuroColors.guardianPrimaryDark,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: NeuroColors.guardianPrimary.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: NeuroColors.guardianPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat(
                      label: 'Adolescents',
                      value: data.totalAdolescentsLinked.toString(),
                      color: NeuroColors.guardianPrimary,
                    ),
                    _buildQuickStat(
                      label: 'Total Journals',
                      value: data.totalJournalCount.toString(),
                      color: NeuroColors.adolescentPrimary,
                    ),
                    _buildQuickStat(
                      label: 'Alerts',
                      value: data.unviewedAlertsCount.toString(),
                      color: data.unviewedAlertsCount > 0 ? NeuroColors.alertHigh : NeuroColors.alertLow,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mood Distribution Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: NeuroColors.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              if (data.moodDistribution.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No mood data recorded yet.',
                      style: TextStyle(color: NeuroColors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                Column(
                  children: data.moodDistribution.entries.map((entry) {
                    final mood = entry.key;
                    final count = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: NeuroColors.guardianPrimary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(mood, style: const TextStyle(fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Text('$count entries', style: const TextStyle(color: NeuroColors.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }).toList(),
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
