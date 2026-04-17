import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/providers/profile_provider.dart';

part 'alerts_provider.freezed.dart';
part 'alerts_provider.g.dart';

@freezed
abstract class AdolescentAlertsState with _$AdolescentAlertsState {
  const factory AdolescentAlertsState({
    @Default([]) List<Alert> alerts,
    @Default(false) bool isLoading,
    String? error,
  }) = _AdolescentAlertsState;
}

@riverpod
class AdolescentAlertsController extends _$AdolescentAlertsController {
  @override
  FutureOr<AdolescentAlertsState> build() async {
    final profileState = await ref.watch(adolescentProfileControllerProvider.future);
    final alertService = ref.watch(alertServiceProvider);

    final id = profileState.user?.id ?? '';
    if (id.isEmpty || id == 'fallback') {
      return const AdolescentAlertsState(alerts: [], isLoading: false);
    }

    final result = await alertService.getAdolescentAlerts(id);
    return result.when(
      success: (value) => AdolescentAlertsState(alerts: value, isLoading: false),
      failure: (f) => AdolescentAlertsState(isLoading: false, error: f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profileState = await ref.read(adolescentProfileControllerProvider.future);
      final alertService = ref.read(alertServiceProvider);

      final id = profileState.user?.id ?? '';
      if (id.isEmpty || id == 'fallback') {
        return const AdolescentAlertsState(alerts: [], isLoading: false);
      }

      final result = await alertService.getAdolescentAlerts(id);
      return result.when(
        success: (value) => AdolescentAlertsState(alerts: value, isLoading: false),
        failure: (f) => AdolescentAlertsState(
          alerts: state.value?.alerts ?? [],
          isLoading: false,
          error: f.message,
        ),
      );
    });
  }
}
