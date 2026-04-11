import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:guardian_app/features/adolescents/providers/adolescent_provider.dart';
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
          SliverToBoxAdapter(
            child: Consumer(
              builder: (context, ref, child) {
                final adolescentsAsync = ref.watch(linkedAdolescentsProvider);
                
                return adolescentsAsync.when(
                  data: (list) {
                    if (list.isEmpty) return const SizedBox.shrink();
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Linked Adolescents',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: NeuroColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...list.map((adolescent) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuickActionCard(
                              title: adolescent.fullName,
                              subtitle: 'Risk Level: ${adolescent.currentRiskLevel ?? "LOW"}',
                              icon: Icons.face,
                              onTap: () => context.push('/adolescent/${adolescent.effectiveId}'),
                            ),
                          )),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                );
              },
            ),
          ),
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
                  Consumer(
                    builder: (context, ref, _) {
                      final pendingAsync = ref.watch(pendingAdolescentsProvider);
                      return pendingAsync.when(
                        data: (pending) {
                          // Always show the card, even with 0 pending
                          return _QuickActionCard(
                            title: 'Pending Activations',
                            subtitle: pending.isEmpty
                                ? 'No adolescents awaiting activation'
                                : '${pending.length} adolescent(s) awaiting activation',
                            icon: Icons.hourglass_top,
                            badge: pending.isEmpty ? '0' : pending.length.toString(),
                            onTap: pending.isEmpty
                                ? () => context.push('/register-adolescent')
                                : () => context.push('/pending-adolescents'),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: NeuroEmptyState(
                        isMini: true,
                        title: 'Data Unavailable',
                        message: 'Guardian activity data is temporarily unavailable. Quick Actions are active.',
                        icon: Icons.cloud_off,
                        color: NeuroColors.moodAnxious,
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
                  color: NeuroColors.surface,
                  borderRadius: BorderRadius.circular(NeuroRadius.xl),
                  boxShadow: [
                    NeuroShadows.md,
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
                      color: NeuroColors.guardianPrimary,
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: NeuroEmptyState(
                    isMini: true,
                    title: 'No Mood Data',
                    message: 'Adolescents have not recorded any mood entries yet.',
                    icon: Icons.analytics_outlined,
                    color: NeuroColors.guardianPrimary,
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
  final String? badge;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.badge,
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
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: NeuroColors.guardianPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
