import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_service.g.dart';

/// Service to manage onboarding completion state.
class OnboardingService {
  final SharedPreferences _prefs;
  static const String _onboardingKey = 'neuronet_onboarding_completed';

  OnboardingService(this._prefs);

  /// Returns true if the user has already completed the onboarding flow.
  bool hasCompletedOnboarding() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  /// Marks the onboarding as completed.
  Future<bool> markOnboardingComplete() async {
    return await _prefs.setBool(_onboardingKey, true);
  }

  /// Resets the onboarding state (useful for testing or debug).
  Future<bool> resetOnboarding() async {
    return await _prefs.remove(_onboardingKey);
  }
}

@riverpod
Future<OnboardingService> onboardingService(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  return OnboardingService(prefs);
}

/// Provider that exposes whether onboarding has been completed.
/// This is used by the router to decide if the user should be redirected to onboarding.
@riverpod
class OnboardingStatus extends _$OnboardingStatus {
  @override
  FutureOr<bool> build() async {
    final service = await ref.watch(onboardingServiceProvider.future);
    return service.hasCompletedOnboarding();
  }

  Future<void> completeOnboarding() async {
    final service = await ref.read(onboardingServiceProvider.future);
    await service.markOnboardingComplete();
    state = const AsyncValue.data(true);
  }
}
