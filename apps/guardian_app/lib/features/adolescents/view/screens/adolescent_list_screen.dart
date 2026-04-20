import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/adolescent_provider.dart';

class AdolescentListScreen extends ConsumerWidget {
  const AdolescentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adolescentsState = ref.watch(linkedAdolescentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: adolescentsState.when(
        data: (adolescents) => _buildContent(context, adolescents),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: NeuroColors.error),
              const SizedBox(height: 16),
              Text(
                'Failed to load adolescents',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                err.toString(),
                style: const TextStyle(color: NeuroColors.onSurfaceVariant),
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
    );
  }

  Widget _buildContent(BuildContext context, List<AdolescentResponse> adolescents) {
    if (adolescents.isEmpty) {
      return const NeuroEmptyState(
        title: 'No Adolescents Linked',
        message: 'Register an adolescent to get started.',
        icon: Icons.person_add_outlined,
        color: NeuroColors.guardianPrimary,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: adolescents.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final adolescent = adolescents[index];
        return _AdolescentCard(adolescent: adolescent);
      },
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final id = adolescent.effectiveId;
          context.push(
            '/adolescent/$id/chat?name=${Uri.encodeComponent(adolescent.fullName)}',
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adolescent.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: NeuroColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: NeuroColors.onSurfaceVariant),
            ],
          ),
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
