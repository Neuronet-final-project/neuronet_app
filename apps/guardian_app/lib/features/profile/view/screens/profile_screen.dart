import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:guardian_app/config/router/app_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:guardian_app/features/auth/providers/auth_provider.dart';
import 'package:guardian_app/features/profile/providers/profile_provider.dart';
import 'package:guardian_app/features/ui/bento_card.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(guardianProfileControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFFF9FAFB),
            title: const Text(
              'My Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_note_rounded, size: 24),
                onPressed: () => context.push(GuardianRoutes.editProfile),
                color: NeuroColors.guardianPrimaryDark,
              ),
              const SizedBox(width: 8),
            ],
          ),
          profileState.when(
            data: (state) {
              if (state.isLoading && state.user == null) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.error != null && state.user == null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: NeuroErrorWidget(
                        message: state.error!,
                        onRetry: () => ref
                            .read(guardianProfileControllerProvider.notifier)
                            .refresh(),
                      ),
                    ),
                  ),
                );
              }

              final user = state.user;
              if (user == null) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No user profile found.')),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildContent(context, ref, user),
                  ]),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Padding(padding: const EdgeInsets.all(24.0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, User user) {
    return Column(
      children: [
        _ProfileHeader(
          user: user,
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
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
              label: 'Email',
              value: user.email,
              icon: Icons.alternate_email_rounded,
              showDivider: true,
            ),
            _SettingTile(
              label: 'Role',
              value: user.role == UserRole.guardian
                  ? 'Guardian'
                  : user.role.name.toUpperCase(),
              icon: Icons.verified_user_rounded,
              showDivider: false,
            ),
          ],
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 16),

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
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.05),

        const SizedBox(height: 32),

        // Sign Out button — matches adolescent style
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text(
                  'Sign Out',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                content: const Text(
                  'Are you sure you want to sign out?',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref.read(authControllerProvider.notifier).logout();
                    },
                    child: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: NeuroColors.guardianPrimary,
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),
        Center(
          child: Text(
            'NeuroNet Guardian v${AppConstants.appVersion}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9CA3AF),
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: const EdgeInsets.all(24),
      gradient: GuardianStyles.primaryGradient,
      child: Row(
        children: [
          Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(
                delay: 3.seconds,
                duration: 1500.ms,
                color: Colors.white.withValues(alpha: 0.2),
              ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.accountStatus.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
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
        GuardianBentoCard(
          padding: EdgeInsets.zero,
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
    this.isDestructive = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool showDivider;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  State<_SettingTile> createState() => _SettingTileState();
}

class _SettingTileState extends State<_SettingTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final destructiveColor = const Color(0xFFEF4444);
    final iconBgColor = widget.isDestructive
        ? destructiveColor.withValues(alpha: 0.1)
        : NeuroColors.guardianPrimary.withValues(alpha: 0.05);
    final iconColor = widget.isDestructive
        ? destructiveColor
        : NeuroColors.guardianPrimary;

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
                    child: Icon(widget.icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: widget.isDestructive
                                ? destructiveColor
                                : NeuroColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: widget.isDestructive
                                ? destructiveColor.withValues(alpha: 0.8)
                                : NeuroColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onTap != null && !widget.isDestructive)
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: NeuroColors.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (widget.showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFF3F4F6),
            ),
          ),
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: NeuroColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: NeuroColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeTrackColor: NeuroColors.guardianPrimary,
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: const Color(0xFFF3F4F6),
            ),
          ),
      ],
    );
  }
}
