import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:intl/intl.dart';
import 'package:guardian_app/features/registration/providers/registration_provider.dart';

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
      appBar: AppBar(
        title: const Text('Register Adolescent'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _HeaderSection(),
            const SizedBox(height: 32),
            _RegistrationForm(state: state, controller: controller),
            const SizedBox(height: 32),
            _ConsentSection(state: state, controller: controller),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: state.isLoading ? null : controller.submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Complete Registration',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.person_add_outlined, size: 64, color: Theme.of(context).primaryColor),
        const SizedBox(height: 16),
        Text(
          'Add a New Adolescent',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Register your child to start monitoring their emotional well-being.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RegistrationForm extends StatelessWidget {
  final RegistrationState state;
  final RegistrationController controller;

  const _RegistrationForm({required this.state, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: "Adolescent's Full Name",
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          onChanged: controller.updateName,
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 19)),
              lastDate: DateTime.now(),
            );
            if (picked != null) controller.updateDOB(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Icons.calendar_today),
              border: OutlineInputBorder(),
            ),
            child: Text(
              state.dateOfBirth == null
                  ? 'Select Date'
                  : DateFormat('MMM d, yyyy').format(state.dateOfBirth!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Email Address (Optional)',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: controller.updateEmail,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<RelationshipType>(
          initialValue: state.relationship,
          decoration: const InputDecoration(
            labelText: 'Relationship to Adolescent',
            prefixIcon: Icon(Icons.family_restroom),
            border: OutlineInputBorder(),
          ),
          items: RelationshipType.values.map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
            );
          }).toList(),
          onChanged: (value) => value != null ? controller.updateRelationship(value) : null,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Initial Consents',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the features you want to enable initially. You can change these later.',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ...ConsentType.values.map((type) {
          return CheckboxListTile(
            title: Text(type.label),
            subtitle: Text(type.description, style: const TextStyle(fontSize: 12)),
            value: state.consents.contains(type),
            onChanged: (_) => controller.toggleConsent(type),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String activationCode;
  final VoidCallback onFinish;

  const _SuccessView({
    required this.activationCode,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Registration Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Give this activation code to your child to connect their device:',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  activationCode,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onFinish,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
