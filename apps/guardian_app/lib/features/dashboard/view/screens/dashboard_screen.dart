import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:guardian_app/features/adolescents/providers/adolescent_provider.dart';
import 'package:guardian_app/features/profile/providers/profile_provider.dart';
import 'package:guardian_app/features/ui/bento_card.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFF9FAFB),
              surfaceTintColor: const Color(0xFFF9FAFB),
              elevation: 0,
              title: const Text(
                'Guardian Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: NeuroColors.guardianPrimaryDark,
                ),
              ),
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, size: 20, color: NeuroColors.guardianPrimary),
                      ),
                    );
                  },
                ),
              ],
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
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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
                            ...list.map(
                              (adolescent) => _QuickActionCard(
                                title: adolescent.fullName,
                                subtitle:
                                    'Risk Level: ${adolescent.currentRiskLevel ?? "LOW"}',
                                icon: Icons.face,
                                onTap: () => context.push(
                                  '/adolescent/${adolescent.effectiveId}',
                                ),
                              ),
                            ),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
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
                        final pendingAsync = ref.watch(
                          pendingAdolescentsProvider,
                        );
                        return pendingAsync.when(
                          data: (pending) {
                            // Always show the card, even with 0 pending
                            return _QuickActionCard(
                              title: 'Pending Activations',
                              subtitle: pending.isEmpty
                                  ? 'No adolescents awaiting activation'
                                  : '${pending.length} adolescent(s) awaiting activation',
                              icon: Icons.hourglass_top,
                              badge: pending.isEmpty
                                  ? '0'
                                  : pending.length.toString(),
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
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildDataSlivers(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final dashboardState = ref.watch(guardianDashboardControllerProvider);

        return dashboardState.when(
          data: (state) {
            if (state.isLoading && state.data == null) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state.error != null && state.data == null) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: NeuroErrorWidget(
                      message: 'Dashboard data failed to load: ${state.error}',
                      onRetry: () => ref
                          .read(guardianDashboardControllerProvider.notifier)
                          .refresh(),
                    ),
                  ),
                ),
              );
            }

            final data = state.data;
            if (data == null) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('No dashboard data available.')),
              );
            }

            final isFallback =
                data.totalAdolescentsLinked == 0 &&
                data.moodDistribution.isEmpty;

            return SliverToBoxAdapter(
              child: Column(
                children: [
                  if (isFallback)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: NeuroEmptyState(
                        isMini: true,
                        title: 'Data Unavailable',
                        message:
                            'Guardian activity data is temporarily unavailable. Quick Actions are active.',
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
                  message: 'Dashboard data failed to load: $err',
                  onRetry: () => ref
                      .read(guardianDashboardControllerProvider.notifier)
                      .refresh(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    GuardianDashboardData data,
  ) {
    return Column(
      children: [
        GuardianBentoCard(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          gradient: GuardianStyles.primaryGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good Morning,',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final profileAsync = ref.watch(
                            guardianProfileControllerProvider,
                          );
                          final name = profileAsync.maybeWhen(
                            data: (state) =>
                                state.user?.fullName.split(' ')[0] ??
                                'Guardian',
                            orElse: () => 'Guardian',
                          );
                          return Text(
                            name,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickStat(
                      context: context,
                      label: 'Adolescents',
                      value: data.totalAdolescentsLinked.toString(),
                      color: Colors.white,
                    ),
                    _buildQuickStat(
                      context: context,
                      label: 'Total Journals',
                      value: data.totalJournalCount.toString(),
                      color: Colors.white,
                    ),
                    _buildQuickStat(
                      context: context,
                      label: 'Alerts',
                      value: data.unviewedAlertsCount.toString(),
                      color: data.unviewedAlertsCount > 0
                          ? Colors.orangeAccent
                          : Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: GuardianBentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mood Overview',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (data.moodDistribution.isEmpty)
                  const NeuroEmptyState(
                    isMini: true,
                    title: 'No Mood Data',
                    message: 'No recorded entries yet.',
                    icon: Icons.analytics_outlined,
                  )
                else
                  ...data.moodDistribution.entries.map((entry) {
                    final mood = entry.key;
                    final count = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                          const SizedBox(width: 12),
                          Text(
                            mood,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          Text(
                            '$count entries',
                            style: const TextStyle(
                              color: NeuroColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStat({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.8),
                letterSpacing: 0.5,
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
    return GuardianBentoCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: NeuroColors.guardianPrimary),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            if (badge != null && badge != '0')
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
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: NeuroColors.onSurface.withValues(alpha: 0.6), fontSize: 13),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: NeuroColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
