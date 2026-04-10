import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:guardian_app/features/auth/providers/auth_provider.dart';
import 'package:guardian_app/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(guardianProfileControllerProvider);

    return Scaffold(
      backgroundColor: NeuroColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: NeuroColors.guardianPrimary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: profileState.when(
        data: (user) => _buildContent(context, ref, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(guardianProfileControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 48),
          
          _SettingSection(
            title: 'Account Information',
            children: [
              _SettingTile(
                label: 'Full Name',
                value: user.fullName,
                icon: Icons.person_rounded,
                showDivider: true,
              ),
              _SettingTile(
                label: 'Email',
                value: user.email,
                icon: Icons.alternate_email_rounded,
                showDivider: true,
              ),
              _SettingTile(
                label: 'Role',
                value: user.role == UserRole.guardian ? 'Guardian' : user.role.name.toUpperCase(),
                icon: Icons.verified_user,
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          _SettingSection(
            title: 'Notification Settings',
            children: [
              _CustomSwitchTile(
                title: 'Alert Notifications',
                subtitle: 'Get notified when patterns are detected',
                value: true,
                onChanged: (val) {},
                showDivider: true,
              ),
              _CustomSwitchTile(
                title: 'Counselor Messages',
                subtitle: 'Push notifications for new messages',
                value: true,
                onChanged: (val) {},
                showDivider: false,
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          ElevatedButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: NeuroColors.alertHigh.withValues(alpha: 0.1),
              foregroundColor: NeuroColors.alertHigh,
              elevation: 0,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout_rounded, size: 22),
                SizedBox(width: 8),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          Text(
            'NeuroNet Guardian v${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.grey[400],
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.2), width: 4),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Icon(Icons.person_rounded, size: 60, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: 24),
        Text(
          user.fullName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: NeuroColors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Account Status: ${user.accountStatus.name.toUpperCase()}',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: NeuroColors.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: NeuroColors.surface,
            borderRadius: BorderRadius.circular(NeuroRadius.xl),
            boxShadow: [NeuroShadows.sm],
            border: Border.all(color: NeuroColors.outline.withValues(alpha: 0.3)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool showDivider;

  const _SettingTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: NeuroColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: NeuroColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: NeuroColors.outline.withValues(alpha: 0.3), indent: 76, endIndent: 20),
      ],
    );
  }
}

class _CustomSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDivider;

  const _CustomSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: NeuroColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: NeuroColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: NeuroColors.surface,
                activeTrackColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: NeuroColors.outline.withValues(alpha: 0.3), indent: 20, endIndent: 20),
      ],
    );
  }
}
