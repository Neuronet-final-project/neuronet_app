import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_provider.g.dart';

@riverpod
class GuardianConsentController extends _$GuardianConsentController {
  @override
  FutureOr<List<Consent>> build() async {
    return MockDataService.getMockConsents();
  }

  Future<void> updateConsent(String consentId, ConsentStatus status) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentConsents = state.value ?? [];
      // In a real app, this would call a repository/API
      return currentConsents.map((c) {
        if (c.consentId == consentId) {
          return c.copyWith(
            consentStatus: status,
            revokedAt: status == ConsentStatus.revoked ? DateTime.now() : null,
            grantedAt: status == ConsentStatus.granted ? DateTime.now() : c.grantedAt,
          );
        }
        return c;
      }).toList();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return MockDataService.getMockConsents();
    });
  }
}
