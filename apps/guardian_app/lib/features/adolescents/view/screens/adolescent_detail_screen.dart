import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_app/config/router/app_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/adolescent_provider.dart';

class AdolescentDetailScreen extends ConsumerWidget {
  final String adolescentId;

  const AdolescentDetailScreen({super.key, required this.adolescentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(
      adolescentDetailControllerProvider(adolescentId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Adolescent Profile')),
      body: detailState.when(
        data: (state) {
          if (state.isLoading && state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: NeuroErrorWidget(
                  message: state.error!,
                  onRetry: () => ref
                      .read(
                        adolescentDetailControllerProvider(adolescentId).notifier,
                      )
                      .refresh(),
                ),
              ),
            );
          }

          final profile = state.profile;
          if (profile == null) {
            return Center(
              child: NeuroErrorWidget(
                message: 'Adolescent profile not found.',
                onRetry: () => ref
                    .read(
                      adolescentDetailControllerProvider(adolescentId).notifier,
                    )
                    .refresh(),
              ),
            );
          }

          return _buildContent(context, ref, state);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: NeuroErrorWidget(
              message: 'Error: $err',
              onRetry: () => ref
                  .read(
                    adolescentDetailControllerProvider(adolescentId).notifier,
                  )
                  .refresh(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AdolescentDetailState state,
  ) {
    final profile = state.profile!;
    final consents = state.consents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context, profile),
          const SizedBox(height: 32),
          _buildSectionTitle('Registration Details'),
          _buildDetailTile('Full Name', profile.fullName),
          _buildDetailTile('Email', profile.email),
          _buildDetailTile(
            'Relationship',
            profile.relationship?.name.toUpperCase() ?? 'N/A',
          ),
          _buildDetailTile(
            'Account Status',
            profile.accountStatus?.name.toUpperCase() ?? 'ACTIVE',
          ),
          _buildDetailTile(
            'Linked Since',
            profile.createdAt?.toIso8601String().split('T')[0] ?? 'N/A',
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('Active Consent'),
          if (consents.isEmpty)
            const NeuroEmptyState(
              isMini: true,
              title: 'No Consents Found',
              message: 'No consents record found for this account.',
              icon: Icons.assignment_late_outlined,
              color: NeuroColors.guardianPrimary,
            )
          else
            ...consents.map(
              (c) => _buildConsentItem(
                c.consentType.label,
                c.consentStatus == ConsentStatus.granted,
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => context.push(GuardianRoutes.consent),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('Manage Consents'),
              style: TextButton.styleFrom(
                foregroundColor: NeuroColors.guardianPrimary,
              ),
            ),
          ),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () {
              // Logic to be implemented: unlink account
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: NeuroColors.error,
              side: const BorderSide(color: NeuroColors.error),
            ),
            child: const Text('Unlink Account'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AdolescentResponse profile) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: NeuroColors.adolescentPrimary.withValues(
              alpha: 0.1,
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: NeuroColors.adolescentPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            profile.email,
            style: const TextStyle(color: NeuroColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              final id = profile.effectiveId;
              context.push(
                '/adolescent/$id/chat?name=${Uri.encodeComponent(profile.fullName)}',
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Contact Counselor'),
            style: ElevatedButton.styleFrom(
              backgroundColor: NeuroColors.guardianPrimary,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              final id = profile.effectiveId;
              context.push(
                '/adolescent/$id/recommendations?name=${Uri.encodeComponent(profile.fullName)}',
              );
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('View Recommendations'),
            style: OutlinedButton.styleFrom(
              foregroundColor: NeuroColors.guardianPrimary,
              side: BorderSide(color: NeuroColors.guardianPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: NeuroColors.guardianPrimary,
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: NeuroColors.onSurfaceVariant),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildConsentItem(String title, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isEnabled ? Icons.check_circle : Icons.cancel,
            color: isEnabled
                ? NeuroColors.alertLow
                : NeuroColors.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(title),
          const Spacer(),
          Text(
            isEnabled ? 'ENABLED' : 'DISABLED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isEnabled
                  ? NeuroColors.alertLow
                  : NeuroColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
