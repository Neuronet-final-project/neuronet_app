import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';

class GuardianOnboardingScreen extends ConsumerWidget {
  const GuardianOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NeuroOnboardingScreen(
      primaryColor: NeuroColors.guardianPrimary,
      onFinish: () async {
        await ref.read(onboardingStatusProvider.notifier).completeOnboarding();
        if (context.mounted) {
          context.go(GuardianRoutes.login);
        }
      },
      pages: const [
        OnboardingPageData(
          title: 'Empower Growth',
          description: "Help your child grow with confidence. NeuroNet provides a safe balance between support and independence.",
          icon: Icons.family_restroom_rounded,
          color: NeuroColors.guardianPrimary,
        ),
        OnboardingPageData(
          title: 'Consent-Driven Oversight',
          description: 'You decide what information is shared with counselors. Your oversight is always based on the consents you manage.',
          icon: Icons.verified_user_rounded,
          color: NeuroColors.guardianPrimary,
        ),
        OnboardingPageData(
          title: 'Stay Informed, Respect Privacy',
          description: "Receive AI-generated summaries and alerts about emotional trends, without ever exposing your child's private journal text.",
          icon: Icons.notifications_active_rounded,
          color: NeuroColors.guardianPrimary,
        ),
      ],
    );
  }
}
