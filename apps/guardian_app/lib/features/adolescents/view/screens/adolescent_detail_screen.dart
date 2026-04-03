import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/adolescent_provider.dart';

class AdolescentDetailScreen extends ConsumerWidget {
  final String adolescentId;

  const AdolescentDetailScreen({
    super.key,
    required this.adolescentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(adolescentDetailControllerProvider(adolescentId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adolescent Profile'),
      ),
      body: detailState.when(
        data: (state) => _buildContent(context, ref, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(adolescentDetailControllerProvider(adolescentId).notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AdolescentDetailState detail) {
    final profile = detail.profile;
    final consents = detail.consents;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(profile),
          const SizedBox(height: 32),
          _buildSectionTitle('Registration Details'),
          _buildDetailTile('Full Name', profile.fullName),
          _buildDetailTile('Email', profile.email),
          _buildDetailTile('Relationship', profile.relationship?.name.toUpperCase() ?? 'N/A'),
          _buildDetailTile('Account Status', profile.accountStatus?.name.toUpperCase() ?? 'ACTIVE'),
          _buildDetailTile('Linked Since', profile.createdAt?.toIso8601String().split('T')[0] ?? 'N/A'),
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
            ...consents.map((c) => _buildConsentItem(
              c.consentType.label, 
              c.consentStatus == ConsentStatus.granted,
            )),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () {
              // TODO: Implement unlink logic
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

  Widget _buildProfileHeader(AdolescentResponse profile) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
            child: const Icon(Icons.person, size: 50, color: NeuroColors.adolescentPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            profile.email,
            style: const TextStyle(
              color: NeuroColors.onSurfaceVariant,
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
          Text(label, style: const TextStyle(color: NeuroColors.onSurfaceVariant)),
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
            color: isEnabled ? NeuroColors.alertLow : NeuroColors.onSurfaceVariant,
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
              color: isEnabled ? NeuroColors.alertLow : NeuroColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
