import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';

class AdolescentOnboardingScreen extends ConsumerWidget {
  const AdolescentOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeuroOnboardingScreen(
      primaryColor: NeuroColors.adolescentPrimary,
      onFinish: () async {
        await ref.read(onboardingStatusProvider.notifier).completeOnboarding();
        if (context.mounted) {
          context.go(AdolescentRoutes.login);
        }
      },
      pages: const [
        OnboardingPageData(
          title: 'Your Safe Space',
          description: 'A private place for your thoughts and feelings. Your journals are never seen by guardians or counselors.',
          icon: Icons.lock_person_rounded,
          color: NeuroColors.adolescentPrimary,
        ),
        OnboardingPageData(
          title: 'Understand Your Trends',
          description: 'Our AI helps you see patterns in your emotional journey over time, helping you grow with self-awareness.',
          icon: Icons.insights_rounded,
          color: NeuroColors.adolescentPrimary,
        ),
        OnboardingPageData(
          title: 'Support, Not Diagnosis',
          description: "We're here to support you. Our AI is an informational assistant, not a doctor or therapist.",
          icon: Icons.favorite_rounded,
          color: NeuroColors.adolescentPrimary,
        ),
        OnboardingPageData(
          title: 'Ready to Start?',
          description: 'Use the activation code provided by your guardian to unlock your personal emotional journey.',
          icon: Icons.rocket_launch_rounded,
          color: NeuroColors.adolescentPrimary,
        ),
      ],
    );
  }
}
