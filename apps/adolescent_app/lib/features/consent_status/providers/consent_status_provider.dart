import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';

part 'consent_status_provider.freezed.dart';
part 'consent_status_provider.g.dart';

@freezed
abstract class ConsentStatusState with _$ConsentStatusState {
  const factory ConsentStatusState({
    @Default(true) bool shareAiSummaries,
    @Default(true) bool shareAlerts,
  }) = _ConsentStatusState;
}

@riverpod
class AdolescentConsentController extends _$AdolescentConsentController {
  @override
  Future<ConsentStatusState> build() async {
    final service = ref.read(consentServiceProvider);
    final result = await service.getMyConsent();
    return result.when(
      success: (data) {
        return ConsentStatusState(
          shareAiSummaries: data['share_ai_summaries'] as bool? ?? true,
          shareAlerts: data['share_alerts'] as bool? ?? true,
        );
      },
      failure: (f) => throw Exception(f.message),
    );
  }
}
