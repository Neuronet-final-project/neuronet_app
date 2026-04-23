import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
        // 1. Hero Card (Greeting + Stats)
        GuardianBentoCard(
          margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          gradient: GuardianStyles.primaryGradient,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(context).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
              const SizedBox(height: 32),
              _buildSummaryPill(context, data).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
            ],
          ),
        ),
        
        // 2. Mood Overview Card
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildMoodCard(context, data)
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.1),
        ),
      ],
    );
  }

  Widget _buildGreeting(BuildContext context) {
    return Row(
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
                final profileAsync = ref.watch(guardianProfileControllerProvider);
                final name = profileAsync.maybeWhen(
                  data: (state) => state.user?.fullName.split(' ')[0] ?? 'Guardian',
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
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSummaryPill(BuildContext context, GuardianDashboardData data) {
    return Container(
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
            value: data.totalAdolescentsLinked,
            color: Colors.white,
          ),
          _buildQuickStat(
            context: context,
            label: 'Total Journals',
            value: data.totalJournalCount,
            color: Colors.white,
          ),
          _buildQuickStat(
            context: context,
            label: 'Alerts',
            value: data.unviewedAlertsCount,
            color: data.unviewedAlertsCount > 0 ? Colors.orangeAccent : Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard(BuildContext context, GuardianDashboardData data) {
    final moodEntries = data.moodDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final totalEntries = moodEntries.fold<int>(0, (sum, e) => sum + e.value);

    return GuardianBentoCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mood Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: NeuroColors.guardianPrimaryDark,
                      letterSpacing: -0.5,
                    ),
              ),
              if (moodEntries.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getMoodColor(moodEntries.first.key).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Dominant: ${moodEntries.first.key}',
                    style: TextStyle(
                      color: _getMoodColor(moodEntries.first.key),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (moodEntries.isEmpty)
            const NeuroEmptyState(
              isMini: true,
              title: 'Awaiting Records',
              message: 'Mood distribution will appear once entries are logged.',
              icon: Icons.bubble_chart_outlined,
            )
          else
            ...moodEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final mood = entry.value.key;
              final count = entry.value.value;
              final percentage = totalEntries > 0 ? count / totalEntries : 0.0;
              final color = _getMoodColor(mood);

              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _getMoodEmoji(mood),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          mood,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: NeuroColors.onSurface,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: color,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          ' entries',
                          style: TextStyle(
                            color: NeuroColors.onSurfaceVariant.withValues(alpha: 0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: NeuroColors.onSurfaceVariant.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        RepaintBoundary(
                          child: FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color,
                                    color.withValues(alpha: 0.7),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ).animate().shimmer(
                                  delay: (index * 150).ms + 800.ms,
                                  duration: 1200.ms,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                          ).animate().scaleX(
                                duration: 800.ms,
                                delay: (index * 150).ms + 400.ms,
                                curve: Curves.easeOutExpo,
                                alignment: Alignment.centerLeft,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Color _getMoodColor(String mood) {
    final m = mood.toLowerCase();
    if (m.contains('happ')) return NeuroColors.moodHappy;
    if (m.contains('sad')) return NeuroColors.moodSad;
    if (m.contains('anxious') || m.contains('worried')) return NeuroColors.moodAnxious;
    if (m.contains('calm') || m.contains('peace')) return NeuroColors.moodCalm;
    if (m.contains('stress')) return NeuroColors.moodStressed;
    if (m.contains('excit')) return NeuroColors.moodExcited;
    if (m.contains('tire') || m.contains('exhaust')) return NeuroColors.moodTired;
    if (m.contains('angr') || m.contains('annoy')) return NeuroColors.moodAngry;
    if (m.contains('hope')) return NeuroColors.moodHopeful;
    return NeuroColors.moodNeutral;
  }

  String _getMoodEmoji(String mood) {
    final m = mood.toLowerCase();
    if (m.contains('happ')) return '😊';
    if (m.contains('sad')) return '😢';
    if (m.contains('anxious') || m.contains('worried')) return '😟';
    if (m.contains('calm') || m.contains('peace')) return '😌';
    if (m.contains('stress')) return '😫';
    if (m.contains('excit')) return '🤩';
    if (m.contains('tire') || m.contains('exhaust')) return '🥱';
    if (m.contains('angr') || m.contains('annoy')) return '😠';
    if (m.contains('hope')) return '✨';
    return '😐';
  }

  Widget _buildQuickStat({
    required BuildContext context,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutExpo,
          builder: (context, val, child) {
            return Text(
              val.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.8),
                letterSpacing: 0.5,
                fontSize: 10,
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
