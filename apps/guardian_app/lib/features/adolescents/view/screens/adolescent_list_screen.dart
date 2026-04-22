import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/adolescent_provider.dart';
import 'package:guardian_app/features/ui/bento_card.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';

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
            centerTitle: false,
            title: const Text(
              'Adolescent Profiles',
              style: TextStyle(
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
                    const Text(
                      'Failed to load adolescents',
                      style: TextStyle(
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
                    ElevatedButton(
                      onPressed: () => ref.invalidate(linkedAdolescentsProvider),
                      child: const Text('Retry'),
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
      return const SliverFillRemaining(
        child: NeuroEmptyState(
          title: 'No Adolescents Linked',
          message: 'Register an adolescent to get started.',
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
            );
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
            CircleAvatar(
              radius: 28,
              backgroundColor: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 28, color: NeuroColors.guardianPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    adolescent.fullName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: NeuroColors.guardianPrimaryDark,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adolescent.email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NeuroColors.onSurface.withValues(alpha: 0.6),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: NeuroColors.onSurfaceVariant),
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
