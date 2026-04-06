import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_provider.g.dart';

@riverpod
class GuardianConsentController extends _$GuardianConsentController {
  @override
  FutureOr<List<Consent>> build() async {
    final service = ref.watch(consentServiceProvider);
    final result = await service.getGuardianConsents();
    return result.when(
      success: (consents) => consents,
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> updateConsent(Consent consent, ConsentStatus status) async {
    final service = ref.read(consentServiceProvider);
    final email = consent.adolescentId;

    // Optimistic update
    final previousState = state;
    if (state.hasValue) {
      final updatedList = state.value!.map((c) {
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
      state = AsyncValue.data(updatedList);
    }

    try {
      // Find both flags for this child to send to backend
      final childConsents = state.value!.where((c) => c.adolescentId == email);

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
        state = previousState;
        throw Exception(result.failure.message);
      }
    } catch (e) {
      // Revert on error
      state = previousState;
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(consentServiceProvider);
      final result = await service.getGuardianConsents();
      return result.value;
    });
  }
}
