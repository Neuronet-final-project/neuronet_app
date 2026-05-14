import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/adolescent_provider.dart';
import 'package:guardian_app/features/ui/bento_card.dart';

class AdolescentListScreen extends ConsumerWidget {
  const AdolescentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adolescentsState = ref.watch(linkedAdolescentsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF9FAFB),
            surfaceTintColor: const Color(0xFFF9FAFB),
            elevation: 0,
            title: Text(
              context.localizations.adolescentProfiles,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
          ),
          adolescentsState.when(
            data: (adolescents) => _buildSliverContent(context, adolescents),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: NeuroColors.error),
                    const SizedBox(height: 16),
                    Text(
                      context.localizations.failedToLoadAdolescents,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: NeuroColors.guardianPrimaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      err.toString(),
                      style: const TextStyle(color: NeuroColors.guardianPrimaryDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    NeuroButton(
                      onPressed: () => ref.invalidate(linkedAdolescentsProvider),
                      label: context.localizations.retry,
                      width: 120,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverContent(BuildContext context, List<AdolescentResponse> adolescents) {
    if (adolescents.isEmpty) {
      return SliverFillRemaining(
        child: NeuroEmptyState(
          title: context.localizations.noAdolescentsLinked,
          message: context.localizations.registerAdolescentGetStarted,
          icon: Icons.person_add_outlined,
          color: NeuroColors.guardianPrimary,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final adolescent = adolescents[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AdolescentCard(adolescent: adolescent),
            )
            .animate(delay: (index * 80).ms)
            .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
            .slideY(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.elasticOut);
          },
          childCount: adolescents.length,
        ),
      ),
    );
  }
}

class _AdolescentCard extends StatelessWidget {
  final AdolescentResponse adolescent;

  const _AdolescentCard({required this.adolescent});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(adolescent.accountStatus);
    final statusLabel = adolescent.accountStatus?.name.toUpperCase() ?? 'UNKNOWN';
    final riskLevel = adolescent.currentRiskLevel?.toLowerCase() ?? 'low';
    final hasAlerts = (adolescent.unresolvedAlertsCount ?? 0) > 0;

    return GuardianBentoCard(
      padding: EdgeInsets.zero,
      onTap: () {
        final id = adolescent.effectiveId;
        context.push(
          '/adolescent/$id/chat?name=${Uri.encodeComponent(adolescent.fullName)}',
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Risk Halo Pulse
                if (riskLevel == 'high' || riskLevel == 'medium')
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (riskLevel == 'high' ? NeuroColors.error : NeuroColors.alertMedium)
                                .withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 5.seconds, curve: Curves.easeInOut)
                     .fadeOut(duration: 5.seconds),
                  ),
                
                CircleAvatar(
                  radius: 28,
                  backgroundColor: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, size: 28, color: NeuroColors.guardianPrimary),
                ),

                // Alert Badge (Shield Icon)
                if (hasAlerts)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: NeuroColors.error,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: NeuroColors.error.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 10),
                          const SizedBox(width: 2),
                          Text(
                            '${adolescent.unresolvedAlertsCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .shimmer(
                      delay: 9.seconds,
                      duration: 1.seconds,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adolescent.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: NeuroColors.guardianPrimaryDark,
                          letterSpacing: -0.2,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adolescent.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NeuroColors.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (adolescent.accountStatus == AccountStatus.active)
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(right: 6),
                                decoration: const BoxDecoration(
                                  color: NeuroColors.alertLow,
                                  shape: BoxShape.circle,
                                ),
                              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                               .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 3.seconds)
                               .fadeOut(duration: 3.seconds),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: statusColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        )
                      )
                        .animate()
                        .shimmer(
                          duration: 2.seconds,
                        )
                        .then()
                        .shimmer(duration: 2.seconds, delay: 2.seconds),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: NeuroColors.onSurfaceVariant, size: 24),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(AccountStatus? status) {
    switch (status) {
      case AccountStatus.active:
        return NeuroColors.alertLow;
      case AccountStatus.pendingActivation:
        return NeuroColors.alertMedium;
      case AccountStatus.suspended:
        return NeuroColors.alertHigh;
      case AccountStatus.inactive:
      case null:
        return NeuroColors.onSurfaceVariant;
    }
  }
}
