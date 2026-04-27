import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:adolescent_app/features/profile/providers/profile_provider.dart';
import 'package:adolescent_app/features/auth/providers/auth_provider.dart';
import 'package:adolescent_app/config/router/app_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileState = ref.watch(adolescentProfileControllerProvider);

    return Scaffold(
      backgroundColor: NeuroColors.adolescentSurface,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6A1FDB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: profileState.when(
        data: (state) {
          if (state.isLoading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.user == null) {
            return Center(
              child: NeuroErrorWidget(
                message: 'Error: ${state.error}',
                onRetry: () => ref.read(adolescentProfileControllerProvider.notifier).refresh(),
              ),
            );
          }

          final user = state.user;
          if (user == null) {
             return Center(
              child: NeuroErrorWidget(
                message: 'User profile not found.',
                onRetry: () => ref.read(adolescentProfileControllerProvider.notifier).refresh(),
              ),
            );
          }

          return _buildContent(context, ref, theme, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: NeuroErrorWidget(
            message: 'Error: $err',
            onRetry: () => ref.read(adolescentProfileControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, ThemeData theme, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          _ProfileHeader(user: user),
          const SizedBox(height: 16),

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
                label: 'Email Address',
                value: user.email,
                icon: Icons.alternate_email_rounded,
                showDivider: true,
              ),
              _SettingTile(
                label: 'Account Status',
                value: user.accountStatus.name.toUpperCase(),
                icon: Icons.verified_user_rounded,
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          _SettingSection(
            title: 'Privacy & Permissions',
            children: [
              _SettingTile(
                label: 'Consent Status',
                value: 'View what your guardian has approved',
                icon: Icons.shield_outlined,
                showDivider: false,
                onTap: () => context.push(AdolescentRoutes.consentStatus),
              ),
            ],
          ),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A1FDB),
              foregroundColor: Colors.white,
              elevation: 2,
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
            'NeuroNet v${AppConstants.appVersion}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: NeuroColors.onSurfaceVariant.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
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
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NeuroColors.adolescentPrimary, NeuroColors.adolescentPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: NeuroColors.adolescentPrimary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2),
                border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.person_rounded, size: 40, color: Colors.white),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Adolescent Account',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: NeuroColors.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: NeuroColors.adolescentPrimary.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: const Color(0xFFE8DCF9), width: 1),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingTile extends StatefulWidget {
  const _SettingTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.showDivider,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  State<_SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<_SettingTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final iconBgColor = NeuroColors.adolescentPrimary.withValues(alpha: 0.08);
    final iconColor = NeuroColors.adolescentPrimary;

    return Column(
      children: [
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isPressed ? 0.98 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: NeuroColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.value,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: NeuroColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onTap != null)
                    const Icon(Icons.chevron_right_rounded, color: NeuroColors.onSurfaceVariant, size: 20),
                ],
              ),
            ),
          ),
        ),
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, thickness: 1, color: NeuroColors.outline.withValues(alpha: 0.2)),
          ),
      ],
    );
  }
}
