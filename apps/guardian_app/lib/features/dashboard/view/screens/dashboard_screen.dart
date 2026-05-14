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
              title: Text(
                context.localizations.guardianOverview,
                style: const TextStyle(
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
                            Text(
                              context.localizations.linkedAdolescents,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: NeuroColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...list.map(
                              (adolescent) => _QuickActionCard(
                                title: adolescent.fullName,
                                subtitle: context.localizations.riskLevel(
                                  adolescent.currentRiskLevel?.toUpperCase() ??
                                      context.localizations.lowRisk,
                                ),
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
                    Text(
                      context.localizations.quickActions,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _QuickActionCard(
                      title: context.localizations.viewAlerts,
                      subtitle: context.localizations.viewAlertsSubtitle,
                      icon: Icons.notifications_active_outlined,
                      onTap: () => context.push('/alerts'),
                    ),
                    _QuickActionCard(
                      title: context.localizations.addAdolescent,
                      subtitle: context.localizations.addAdolescentSubtitle,
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
                              title: context.localizations.pendingActivations,
                              subtitle: pending.isEmpty
                                  ? context.localizations.noAdolescentsAwaitingActivation
                                  : context.localizations.adolescentsAwaitingActivation(pending.length),
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
                    _QuickActionCard(
                      title: context.localizations.counselorApprovals,
                      subtitle: context.localizations.counselorApprovalsSubtitle,
                      icon: Icons.verified_user_outlined,
                      onTap: () => context.push('/approvals'),
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
                debugPrint('DashboardScreen: showing error widget, error=${state.error}');
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
                debugPrint('DashboardScreen: data is null');
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(context.localizations.noDashboardData)),
                );
              }

              debugPrint('DashboardScreen: received data - adolescents: ${data.totalAdolescentsLinked}, journals: ${data.totalJournalCount}, alerts: ${data.unviewedAlertsCount}, moodDist: ${data.moodDistribution}, trends: ${data.emotionalTrends.length}');
              final isFallback =
                  data.totalAdolescentsLinked == 0 &&
                  data.moodDistribution.isEmpty;

             return SliverToBoxAdapter(
               child: Column(
                 children: [
                   if (isFallback)
                     Padding(
                       padding: const EdgeInsets.symmetric(
                         horizontal: 16,
                         vertical: 8,
                       ),
                       child: NeuroEmptyState(
                         isMini: true,
                         title: context.localizations.dataUnavailable,
                         message: context.localizations.guardianDataUnavailableDesc,
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
            error: (err, stack) {
              debugPrint('DashboardScreen: provider error - $err');
              debugPrint('DashboardScreen: stack trace - $stack');
              return SliverFillRemaining(
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
              );
            },
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
        
        // 2. Emotional Trends Card
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
              '${context.localizations.goodMorning},',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final profileAsync = ref.watch(guardianProfileControllerProvider);
                final name = profileAsync.maybeWhen(
                  data: (state) => state.user?.fullName.split(' ')[0] ?? context.localizations.guardian,
                  orElse: () => context.localizations.guardian,
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
            label: context.localizations.adolescentsLabel,
            value: data.totalAdolescentsLinked,
            color: Colors.white,
          ),
          _buildQuickStat(
            context: context,
            label: context.localizations.totalJournalsLabel,
            value: data.totalJournalCount,
            color: Colors.white,
          ),
          _buildQuickStat(
            context: context,
            label: context.localizations.alerts,
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
             context.localizations.emotionalTrends,
             style: Theme.of(context).textTheme.titleLarge?.copyWith(
                   fontWeight: FontWeight.w900,
                   color: NeuroColors.guardianPrimaryDark,
                   letterSpacing: -0.5,
                 ),
           ),
           const SizedBox(height: 12),
           _buildPeriodSelector(context, ref, currentPeriod),
           const SizedBox(height: 24),
           if (trends.isEmpty)
             NeuroEmptyState(
               isMini: true,
               title: context.localizations.noTrendDataYet,
               message: context.localizations.noTrendDataDesc,
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
  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref, String currentPeriod) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: '7d',
          label: Text(context.localizations.sevenDays, style: const TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: '14d',
          label: Text(context.localizations.fourteenDays, style: const TextStyle(fontSize: 12)),
        ),
        ButtonSegment(
          value: '30d',
          label: Text(context.localizations.thirtyDays, style: const TextStyle(fontSize: 12)),
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
     debugPrint('_buildAggregatedInsightsCard: adolescentRisks=${data.adolescentRisks.length}, alertList=${data.alertList.length}');
     final adolescents = data.adolescentRisks;
     final alerts = data.alertList;
     final currentPeriod = ref.watch(guardianDashboardControllerProvider).value?.period ?? '7d';
     
     // Calculate average mood sentiment from emotional trends (weighted average of sentimentScore)
     double? averageSentiment;
     if (data.emotionalTrends.isNotEmpty) {
       final totalScore = data.emotionalTrends.fold<double>(0, (sum, trend) => sum + trend.sentimentScore);
       averageSentiment = totalScore / data.emotionalTrends.length;
       debugPrint('_buildAggregatedInsightsCard: averageSentiment=$averageSentiment');
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
                context.localizations.aggregatedInsights,
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
              label: context.localizations.averageMoodSentiment,
              value: '${(averageSentiment * 100).toStringAsFixed(0)}%',
              subtitle: context.localizations.allAdolescentsSubtitle(currentPeriod),
              color: _getSentimentColor(averageSentiment),
            ),
            const SizedBox(height: 16),
          ],

          // Alert Summary
          _buildInsightRow(
            context,
            label: context.localizations.alertsSummary,
            value: context.localizations.totalCount(alerts.length),
            subtitle: context.localizations.alertsSeverityBreakdown(lowAlerts, mediumAlerts, highAlerts),
            color: NeuroColors.alertMedium,
          ),
          const SizedBox(height: 16),

          // Activity Stats
          _buildInsightRow(
            context,
            label: context.localizations.activityStats,
            value: context.localizations.journalMoodStats(totalJournalCount, totalMoodEntries),
            subtitle: context.localizations.adolescentsLinked(adolescents.length),
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
                    // Greeting text placeholder — white rounded box
                    NeuroShimmer(
                      child: Container(
                        width: 100,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Title placeholder — white rounded box
                    NeuroShimmer(
                      child: Container(
                        width: 140,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Notification/avatar placeholder — white circle
                NeuroShimmer(
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
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

