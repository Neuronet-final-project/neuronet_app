import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:adolescent_app/features/auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: NeuroColors.adolescentSurface,
              child: Icon(Icons.person, size: 50, color: NeuroColors.adolescentPrimary),
            ),
            const SizedBox(height: 16),
            Text(
              'Alex Johnson',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'Adolescent Account',
              style: theme.textTheme.bodyMedium?.copyWith(color: NeuroColors.onSurfaceVariant),
            ),
            const SizedBox(height: 40),
            _buildProfileItem(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: 'alex.j@example.com',
            ),
            _buildProfileItem(
              context,
              icon: Icons.verified_user_outlined,
              label: 'Account Status',
              value: 'Active',
            ),
            _buildProfileItem(
              context,
              icon: Icons.family_restroom_outlined,
              label: 'Linked Guardian',
              value: 'Sarah Johnson',
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'NeuroNet v1.0.0',
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: NeuroColors.adolescentPrimary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey)),
                Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
