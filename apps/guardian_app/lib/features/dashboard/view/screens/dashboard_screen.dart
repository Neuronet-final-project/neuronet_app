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
             // If error with no data, show error
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
                   _buildSummarySection(context, ref, data),
                 ],
               ),
             );
           },
           loading: () => SliverToBoxAdapter(
             child: Column(
               children: [
                 const NeuroSkeletonHeroCard(),
                 Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                   child: Column(
                     children: [
                       const SizedBox(height: 16),
                       const NeuroSkeletonTrendCard(),
                       const SizedBox(height: 16),
                       const NeuroSkeletonInsightsCard(),
                       const SizedBox(height: 16),
                       const NeuroSkeletonQuickActions(count: 3),
                     ],
                   ),
                 ),
               ],
             ),
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
    WidgetRef ref,
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
        
        // 2. Emotional Trends Card (Replace Mood Overview)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTrendCard(context, ref, data)
              .animate()
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.1),
        ),

        // 3. Aggregated Insights Card (NEW)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: _buildAggregatedInsightsCard(context, ref, data)
              .animate()
              .fadeIn(delay: 600.ms)
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

   Widget _buildTrendCard(BuildContext context, WidgetRef ref, GuardianDashboardData data) {
     final trends = data.emotionalTrends;
     final currentPeriod = ref.watch(guardianDashboardControllerProvider).value?.period ?? '7d';

     return GuardianBentoCard(
       padding: const EdgeInsets.all(24),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Text(
             'Emotional Trends',
             style: Theme.of(context).textTheme.titleLarge?.copyWith(
                   fontWeight: FontWeight.w900,
                   color: NeuroColors.guardianPrimaryDark,
                   letterSpacing: -0.5,
                 ),
           ),
           const SizedBox(height: 12),
           _buildPeriodSelector(ref, currentPeriod),
           const SizedBox(height: 24),
           if (trends.isEmpty)
             const NeuroEmptyState(
               isMini: true,
               title: 'No Trend Data Yet',
               message: 'Trend visualization will appear once mood entries are recorded by linked adolescents. Data typically appears within 24 hours of a journal entry.',
               icon: Icons.show_chart,
             )
           else
             SizedBox(
               height: 220,
               child: NeuroTrendChart(
                 trends: trends,
                 showDots: true,
                 lineColor: NeuroColors.guardianPrimary,
               ),
             ),
          ],
        ),
      );
    }

  /// Period selector widget (7d / 14d / 30d)
  Widget _buildPeriodSelector(WidgetRef ref, String currentPeriod) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: '7d',
          label: Text('7d', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: '14d',
          label: Text('14d', style: TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: '30d',
          label: Text('30d', style: TextStyle(fontSize: 12)),
        ),
      ],
      selected: {currentPeriod},
      onSelectionChanged: (Set<String> newSelection) {
        final selected = newSelection.first;
        ref.read(guardianDashboardControllerProvider.notifier).refresh(period: selected);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Builds the Aggregated Insights card showing cross-adolescent statistics
  Widget _buildAggregatedInsightsCard(BuildContext context, WidgetRef ref, GuardianDashboardData data) {
    final adolescents = data.adolescentRisks;
    final alerts = data.alertList;
    final currentPeriod = ref.watch(guardianDashboardControllerProvider).value?.period ?? '7d';
    
    // Calculate average mood sentiment from emotional trends (weighted average of sentimentScore)
    double? averageSentiment;
    if (data.emotionalTrends.isNotEmpty) {
      final totalScore = data.emotionalTrends.fold<double>(0, (sum, trend) => sum + trend.sentimentScore);
      averageSentiment = totalScore / data.emotionalTrends.length;
    }

    // Count alerts by severity
    final lowAlerts = alerts.where((a) => a.severityLevel.toLowerCase() == 'low').length;
    final mediumAlerts = alerts.where((a) => a.severityLevel.toLowerCase() == 'medium').length;
    final highAlerts = alerts.where((a) => a.severityLevel.toLowerCase() == 'high').length;

    // Total activity stats
    final totalJournalCount = data.totalJournalCount;
    final totalMoodEntries = data.moodDistribution.values.fold<int>(0, (sum, count) => sum + count);

    return GuardianBentoCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: NeuroColors.guardianPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Aggregated Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: NeuroColors.guardianPrimaryDark,
                      letterSpacing: -0.5,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Average Sentiment (if available)
          if (averageSentiment != null) ...[
            _buildInsightRow(
              context,
              label: 'Average Mood Sentiment',
              value: '${(averageSentiment * 100).toStringAsFixed(0)}%',
              subtitle: 'Across all linked adolescents (last $currentPeriod)',
              color: _getSentimentColor(averageSentiment),
            ),
            const SizedBox(height: 16),
          ],

          // Alert Summary
          _buildInsightRow(
            context,
            label: 'Alerts Summary',
            value: '${alerts.length} total',
            subtitle: 'Low: $lowAlerts, Medium: $mediumAlerts, High: $highAlerts',
            color: NeuroColors.alertMedium,
          ),
          const SizedBox(height: 16),

          // Activity Stats
          _buildInsightRow(
            context,
            label: 'Activity Stats',
            value: '$totalJournalCount journals, $totalMoodEntries mood entries',
            subtitle: '${adolescents.length} adolescent(s) linked',
            color: NeuroColors.alertLow, // Using alertLow (green) for positive activity
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
    BuildContext context, {
    required String label,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: NeuroColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: NeuroColors.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getSentimentColor(double sentiment) {
    // sentiment is 0.0 to 1.0 (higher = more positive)
    if (sentiment >= 0.7) return NeuroColors.moodHappy;
    if (sentiment >= 0.5) return NeuroColors.moodCalm;
    if (sentiment >= 0.3) return NeuroColors.moodAnxious;
    return NeuroColors.moodSad;
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
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
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

// ─── Skeleton Loading Widgets ──────────────────────────────────────────────────

 class _SkeletonBox extends StatelessWidget {
   const _SkeletonBox({
     this.width,
     this.height,
   });

   final double? width, height;

   @override
   Widget build(BuildContext context) {
     return NeuroShimmer(
       child: Container(
         width: width,
         height: height,
         decoration: BoxDecoration(
           color: Colors.grey[300],
         ),
       ),
     );
   }
 }

  class _SkeletonCircle extends StatelessWidget {
    const _SkeletonCircle({required this.radius, this.color});

    final double radius;
    final Color? color;

    @override
    Widget build(BuildContext context) {
      return NeuroShimmer(
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: color ?? Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
      );
    }
  }

 class NeuroSkeletonHeroCard extends StatelessWidget {
   const NeuroSkeletonHeroCard({super.key});

   @override
   Widget build(BuildContext context) {
     return GuardianBentoCard(
       margin: const EdgeInsets.fromLTRB(16, 20, 16, 20),
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
                   const _SkeletonBox(width: 100, height: 12),
                   const SizedBox(height: 6),
                   const _SkeletonBox(width: 140, height: 22),
                 ],
               ),
               const Spacer(),
               const _SkeletonCircle(radius: 18, color: Colors.white24),
             ],
           ),
           const SizedBox(height: 28),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: List.generate(3, (_) => 
               NeuroShimmer(
                 child: Container(
                   width: 70,
                   height: 52,
                   decoration: BoxDecoration(
                     color: Colors.white.withValues(alpha: 0.15),
                     borderRadius: BorderRadius.circular(16),
                   ),
                 ),
               ),
             ),
           ),
         ],
       ),
     );
   }
 }

 class NeuroSkeletonTrendCard extends StatelessWidget {
   const NeuroSkeletonTrendCard({super.key});

   @override
   Widget build(BuildContext context) {
     return GuardianBentoCard(
       padding: const EdgeInsets.all(24),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const _SkeletonBox(width: 180, height: 28),
           const SizedBox(height: 12),
           Row(
             children: [
               Row(
                 children: List.generate(3, (_) => 
                   Container(
                     margin: const EdgeInsets.symmetric(horizontal: 4),
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                     decoration: BoxDecoration(
                       color: Colors.grey[300],
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: const SizedBox(width: 36, height: 12),
                   ),
                 ),
               ),
             ],
           ),
           const SizedBox(height: 24),
           const _SkeletonBox(height: 220),
         ],
       ),
     );
   }
 }

class NeuroSkeletonInsightsCard extends StatelessWidget {
  const NeuroSkeletonInsightsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SkeletonBox(width: 20, height: 20),
              const SizedBox(width: 8),
              const _SkeletonBox(width: 180, height: 28),
            ],
          ),
          const SizedBox(height: 20),
          ...List.generate(3, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SkeletonBox(width: 4, height: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SkeletonBox(width: 180, height: 13),
                      const SizedBox(height: 4),
                      const _SkeletonBox(width: 120, height: 20),
                      const SizedBox(height: 4),
                      const _SkeletonBox(width: 200, height: 11),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class NeuroSkeletonQuickAction extends StatelessWidget {
  const NeuroSkeletonQuickAction({super.key});

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const _SkeletonCircle(radius: 12, color: Colors.grey),
        title: const _SkeletonBox(width: double.infinity, height: 16),
        subtitle: const _SkeletonBox(width: 180, height: 12),
        trailing: const _SkeletonBox(width: 24, height: 24),
      ),
    );
  }
}

class NeuroSkeletonQuickActions extends StatelessWidget {
  const NeuroSkeletonQuickActions({
    super.key,
    this.count = 3,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(count, (_) => 
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: NeuroSkeletonQuickAction(),
          ),
        ),
      ),
    );
  }
}

