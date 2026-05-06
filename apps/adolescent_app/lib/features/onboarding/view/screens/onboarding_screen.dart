import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';

class AdolescentOnboardingScreen extends ConsumerWidget {
  const AdolescentOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(l10nProvider);
    debugPrint('[Onboarding] Building with locale: ${currentLocale.languageCode}');
    
    return NeuroOnboardingScreen(
      primaryColor: NeuroColors.adolescentPrimary,
      onFinish: () async {
        await ref.read(onboardingStatusProvider.notifier).completeOnboarding();
        if (context.mounted) {
          context.go(AdolescentRoutes.login);
        }
      },
      pages: [
        OnboardingPageData(
          title: context.localizations.onboardingTitle1,
          description: context.localizations.onboardingDesc1,
          icon: Icons.lock_person_rounded,
          color: NeuroColors.adolescentPrimary,
        ),
        OnboardingPageData(
          title: context.localizations.onboardingTitle2,
          description: context.localizations.onboardingDesc2,
          icon: Icons.insights_rounded,
          color: NeuroColors.adolescentPrimary,
        ),
        OnboardingPageData(
          title: context.localizations.onboardingTitle3,
          description: context.localizations.onboardingDesc3,
          icon: Icons.favorite_rounded,
          color: NeuroColors.adolescentPrimary,
        ),
        OnboardingPageData(
          title: context.localizations.onboardingTitle4,
          description: context.localizations.onboardingDesc4,
          icon: Icons.rocket_launch_rounded,
          color: NeuroColors.adolescentPrimary,
        ),
      ],
    );
  }
}
