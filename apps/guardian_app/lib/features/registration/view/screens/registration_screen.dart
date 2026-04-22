import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:intl/intl.dart';
import 'package:guardian_app/features/registration/providers/registration_provider.dart';
import 'package:guardian_app/features/ui/bento_card.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationControllerProvider);
    final controller = ref.read(registrationControllerProvider.notifier);

    // If we have an activation code, show the success screen
    if (state.activationCode != null) {
      return _SuccessView(
        activationCode: state.activationCode!,
        onFinish: () => Navigator.of(context).pop(),
      );
    }

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              color: NeuroColors.guardianPrimaryDark,
            ),
            title: const Text(
              'Enroll Adolescent',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const _HeaderSection(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _RegistrationForm(state: state, controller: controller),
                      const SizedBox(height: 16),
                      _ConsentSection(state: state, controller: controller),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: _SubmitButton(
                          state: state,
                          controller: controller,
                        ),
                      ),
                      if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: NeuroErrorWidget(message: state.error!),
                        ),
                      const SizedBox(height: 48),
                    ],
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

class _SubmitButton extends StatelessWidget {
  final RegistrationState state;
  final RegistrationController controller;

  const _SubmitButton({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: state.isLoading ? null : controller.submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: NeuroColors.guardianPrimary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        shadowColor: NeuroColors.guardianPrimary.withValues(alpha: 0.3),
      ),
      child: state.isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            )
          : const Text(
              'Complete Registration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      padding: const EdgeInsets.all(16),
      gradient: GuardianStyles.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'New Enrollment',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Connect your child to the Neuronet platform to begin monitoring their emotional health and guiding their developmental journey.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _RegistrationForm extends StatelessWidget {
  final RegistrationState state;
  final RegistrationController controller;

  const _RegistrationForm({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.badge_outlined,
                size: 20,
                color: NeuroColors.guardianPrimary,
              ),
              const SizedBox(width: 12),
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildField(
            label: "Adolescent's Full Name",
            icon: Icons.person_outline,
            onChanged: controller.updateName,
          ),
          const SizedBox(height: 16),
          _buildDatePicker(context),
          const SizedBox(height: 16),
          _buildField(
            label: 'Support Email (Required)',
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            onChanged: controller.updateEmail,
            errorText:
                state.email.isNotEmpty &&
                    !RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(state.email)
                ? 'Invalid email format'
                : null,
          ),
          const SizedBox(height: 16),
          _buildRelationshipDropdown(context),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NeuroColors.onSurfaceVariant,
            ),
          ),
        ),
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: NeuroColors.guardianPrimary,
                width: 2,
              ),
            ),
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Date of Birth',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NeuroColors.onSurfaceVariant,
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(
                const Duration(days: 365 * 13),
              ),
              firstDate: DateTime.now().subtract(
                const Duration(days: 365 * 19),
              ),
              lastDate: DateTime.now(),
            );
            if (picked != null) controller.updateDOB(picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: NeuroColors.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  state.dateOfBirth == null
                      ? 'Select Date'
                      : DateFormat('MMM d, yyyy').format(state.dateOfBirth!),
                  style: TextStyle(
                    color: state.dateOfBirth == null
                        ? NeuroColors.onSurfaceVariant
                        : NeuroColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Relationship to Adolescent',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: NeuroColors.onSurfaceVariant,
            ),
          ),
        ),
        DropdownButtonFormField<RelationshipType>(
          value: state.relationship,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.family_restroom_rounded, size: 20),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          items: RelationshipType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
            );
          }).toList(),
          onChanged: (value) =>
              value != null ? controller.updateRelationship(value) : null,
        ),
      ],
    );
  }
}

class _ConsentSection extends StatelessWidget {
  final RegistrationState state;
  final RegistrationController controller;

  const _ConsentSection({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.rule_rounded,
                size: 20,
                color: NeuroColors.guardianPrimary,
              ),
              const SizedBox(width: 12),
              const Text(
                'Initial Capabilities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select the features you want to enable initially. You can adjust these granularly after enrollment.',
            style: TextStyle(
              fontSize: 13,
              color: NeuroColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ...ConsentType.values.map((type) {
            final isEnabled = state.consents.contains(type);
            return _buildFeatureToggle(type, isEnabled);
          }),
        ],
      ),
    );
  }

  Widget _buildFeatureToggle(ConsentType type, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isEnabled
            ? NeuroColors.guardianPrimary.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => controller.toggleConsent(type),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEnabled
                        ? NeuroColors.guardianPrimary
                        : NeuroColors.onSurfaceVariant.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(type),
                    size: 16,
                    color: isEnabled
                        ? Colors.white
                        : NeuroColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isEnabled
                              ? NeuroColors.onSurface
                              : NeuroColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        type.description,
                        style: TextStyle(
                          fontSize: 11,
                          color: NeuroColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: Switch.adaptive(
                    value: isEnabled,
                    activeTrackColor: NeuroColors.guardianPrimary,
                    onChanged: (_) => controller.toggleConsent(type),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(ConsentType type) {
    switch (type) {
      case ConsentType.participation:
        return Icons.psychology_outlined;
      case ConsentType.shareAiSummaries:
        return Icons.summarize_outlined;
      case ConsentType.shareAlerts:
        return Icons.notifications_active_outlined;
      case ConsentType.counselorChat:
        return Icons.chat_bubble_outline_rounded;
    }
  }
}

class _SuccessView extends StatelessWidget {
  final String activationCode;
  final VoidCallback onFinish;

  const _SuccessView({required this.activationCode, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Enrollment Complete!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: NeuroColors.guardianPrimaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your adolescent has been successfully registered. Share this activation code with them to link their device.',
                style: TextStyle(
                  fontSize: 15,
                  color: NeuroColors.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              _buildCodeDisplay(context),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onFinish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeuroColors.guardianPrimaryDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Return to Dashboard',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeDisplay(BuildContext context) {
    return Column(
      children: [
        const Text(
          'ACTIVATION CODE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: NeuroColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: activationCode));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Activation code copied'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: NeuroColors.guardianPrimary.withValues(alpha: 0.2),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activationCode,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: NeuroColors.guardianPrimary,
                    fontFamily: 'Courier', // Mono feel
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(
                  Icons.copy_rounded,
                  color: NeuroColors.guardianPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
