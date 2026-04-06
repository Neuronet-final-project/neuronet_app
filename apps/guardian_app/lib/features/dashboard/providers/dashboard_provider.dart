import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class GuardianDashboardController extends _$GuardianDashboardController {
  @override
  FutureOr<GuardianDashboardData> build() async {
    final service = ref.watch(dashboardServiceProvider);
    final result = await service.getGuardianDashboard();
    return result.when(
      success: (data) => data,
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(dashboardServiceProvider);
      final result = await service.getGuardianDashboard();
      return result.value;
    });
  }
}

@riverpod
class GuardianAlertsController extends _$GuardianAlertsController {
  @override
  FutureOr<List<Alert>> build() async {
    final service = ref.watch(alertServiceProvider);
    final result = await service.getGuardianAlerts();
    return result.when(
      success: (alerts) => alerts,
      failure: (f) => throw Exception(f.message),
    );
  }

  Future<void> markAsViewed(String alertId) async {
    final service = ref.read(alertServiceProvider);

    // Optistic update for better UX
    final previousState = state;
    state = AsyncValue.data(
      (state.value ?? []).map((a) => a.alertId == alertId ? a.copyWith(viewedStatus: true) : a).toList(),
    );

    try {
      final result = await service.markViewed(alertId);
      if (result.isFailure) {
        state = previousState;
        throw Exception(result.failure.message);
      }
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> resolveAlert(
    String alertId, {
    String? notes,
  }) async {
    final service = ref.read(alertServiceProvider);

    state = await AsyncValue.guard(() async {
      final resolveResult = await service.resolveAlert(alertId, notes: notes);
      if (resolveResult.isFailure) {
        throw Exception(resolveResult.failure.message);
      }
      final alertsResult = await service.getGuardianAlerts();
      return alertsResult.value;
    });

    if (state.hasError) {
      throw state.error!;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(alertServiceProvider);
      final result = await service.getGuardianAlerts();
      return result.value;
    });
  }
}
