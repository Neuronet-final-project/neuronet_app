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
      pages: [
        OnboardingPageData(
          title: context.localizations.guardianOnboardingTitle1,
          description: context.localizations.guardianOnboardingDesc1,
          icon: Icons.auto_graph_rounded,
          color: const Color(0xFF6366F1),
        ),
        OnboardingPageData(
          title: context.localizations.guardianOnboardingTitle2,
          description: context.localizations.guardianOnboardingDesc2,
          icon: Icons.verified_user_rounded,
          color: const Color(0xFF8B5CF6),
        ),
        OnboardingPageData(
          title: context.localizations.guardianOnboardingTitle3,
          description: context.localizations.guardianOnboardingDesc3,
          icon: Icons.notifications_active_rounded,
          color: NeuroColors.guardianPrimary,
        ),
      ],
    );
  }
}
