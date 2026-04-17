import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'consent_provider.freezed.dart';
part 'consent_provider.g.dart';

@freezed
abstract class GuardianConsentState with _$GuardianConsentState {
  const factory GuardianConsentState({
    @Default([]) List<Consent> consents,
    @Default(false) bool isLoading,
    String? error,
  }) = _GuardianConsentState;
}

@riverpod
class GuardianConsentController extends _$GuardianConsentController {
  @override
  FutureOr<GuardianConsentState> build() async {
    final service = ref.watch(consentServiceProvider);
    final result = await service.getGuardianConsents();

    return result.when(
      success: (consents) => GuardianConsentState(consents: consents, isLoading: false),
      failure: (f) => GuardianConsentState(isLoading: false, error: f.message),
    );
  }

  Future<void> updateConsent(Consent consent, ConsentStatus status) async {
    final service = ref.read(consentServiceProvider);
    final email = consent.adolescentId;
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistic update
    final previousConsents = currentState.consents;
    final updatedList = currentState.consents.map((c) {
      if (c.consentId == consent.consentId) {
        return c.copyWith(
          consentStatus: status,
          revokedAt:
              status == ConsentStatus.revoked ? DateTime.now() : c.revokedAt,
          grantedAt:
              status == ConsentStatus.granted ? DateTime.now() : c.grantedAt,
        );
      }
      return c;
    }).toList();
    
    state = AsyncValue.data(currentState.copyWith(consents: updatedList));

    try {
      // Find both flags for this child to send to backend
      final childConsents = updatedList.where((c) => c.adolescentId == email);

      bool aiValue = childConsents
          .firstWhere((c) => c.consentType == ConsentType.shareAiSummaries)
          .consentStatus == ConsentStatus.granted;
      bool alertsValue = childConsents
          .firstWhere((c) => c.consentType == ConsentType.shareAlerts)
          .consentStatus == ConsentStatus.granted;

      final result = await service.updateConsent(
        email: email,
        shareAiSummaries: aiValue,
        shareAlerts: alertsValue,
      );
      
      if (result.isFailure) {
        state = AsyncValue.data(currentState.copyWith(consents: previousConsents, error: result.failure.message));
      }
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(consents: previousConsents, error: e.toString()));
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(consentServiceProvider);
      final result = await service.getGuardianConsents();
      return result.when(
        success: (consents) => GuardianConsentState(consents: consents, isLoading: false),
        failure: (f) => GuardianConsentState(isLoading: false, error: f.message),
      );
    });
  }
}
