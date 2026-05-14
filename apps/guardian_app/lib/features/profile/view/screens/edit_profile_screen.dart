import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:guardian_app/features/profile/providers/profile_provider.dart';
import 'package:guardian_app/features/ui/bento_card.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(guardianProfileControllerProvider).value?.user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final notifier = ref.read(guardianProfileControllerProvider.notifier);
    
    final result = await notifier.updateProfile(
      fullName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      password: _passwordController.text.trim().isNotEmpty ? _passwordController.text.trim() : null,
    );

    if (mounted) {
      if (result.isSuccess) {
        NeuroToast.show(context, context.localizations.profileUpdatedSuccess, type: NeuroToastType.success);
        Navigator.of(context).pop();
      } else {
        NeuroToast.show(context, '${context.localizations.errorPrefix}: ${result.failure.message}', type: NeuroToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(guardianProfileControllerProvider);
    final isLoading = profileState.value?.isLoading ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF9FAFB),
            surfaceTintColor: const Color(0xFFF9FAFB),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded, size: 24),
              onPressed: () => Navigator.of(context).pop(),
              color: NeuroColors.guardianPrimaryDark,
            ),
            title: Text(
              context.localizations.editProfile,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : _handleUpdate,
                child: Text(
                  context.localizations.saveUpper,
                  style: TextStyle(
                    color: isLoading ? Colors.grey : NeuroColors.guardianPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _PersonalInfoCard(
                  nameController: _nameController,
                  email: profileState.value?.user?.email ?? '',
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                const SizedBox(height: 16),
                _SecurityCard(
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.05),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: NeuroButton(
                    onPressed: _handleUpdate,
                    label: context.localizations.updateProfile,
                    isLoading: isLoading,
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scale(begin: const Offset(0.98, 0.98)),
                ),
                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  final TextEditingController nameController;
  final String email;

  const _PersonalInfoCard({required this.nameController, required this.email});

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, color: NeuroColors.guardianPrimary, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: NeuroColors.guardianPrimaryDark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.localizations.fullName,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeuroColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: context.localizations.enterFullName,
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 20),
          Text(
            context.localizations.emailAddressNonEditable,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeuroColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Text(
              email,
              style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;

  const _SecurityCard({
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline_rounded, color: NeuroColors.guardianPrimary, size: 20),
              const SizedBox(width: 10),
              Text(
                context.localizations.security,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: NeuroColors.guardianPrimaryDark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            context.localizations.newPassword,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: NeuroColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: context.localizations.changePasswordDesc,
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 20),
              ),
            ),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Text(
            context.localizations.passwordProtectionAdvice,
            style: TextStyle(fontSize: 11, color: Colors.grey[500], height: 1.4),
          ),
        ],
      ),
    );
  }
}
