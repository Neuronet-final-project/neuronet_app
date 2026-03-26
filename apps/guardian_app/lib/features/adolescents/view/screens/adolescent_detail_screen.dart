import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';

class AdolescentDetailScreen extends ConsumerWidget {
  final String adolescentId;

  const AdolescentDetailScreen({
    super.key,
    required this.adolescentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real app, we would fetch details by ID. 
    // For now, we use mock data from the dashboard provider or a dedicated detail provider.
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adolescent Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('Registration Details'),
            _buildDetailTile('Full Name', 'Adolescent User'),
            _buildDetailTile('Relationship', 'Parent/Guardian'),
            _buildDetailTile('Linked Since', 'Jan 15, 2026'),
            const SizedBox(height: 32),
            _buildSectionTitle('Active Consent'),
            _buildConsentItem('Mood Tracking', true),
            _buildConsentItem('Journal Pattern Analysis', true),
            _buildConsentItem('Emergency Contact Access', true),
            _buildConsentItem('Third-party sharing', false),
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
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: NeuroColors.adolescentPrimary.withOpacity(0.1),
            child: const Icon(Icons.person, size: 50, color: NeuroColors.adolescentPrimary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Adolescent User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Active Member',
            style: TextStyle(
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
