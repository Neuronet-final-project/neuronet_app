import 'package:flutter/foundation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_provider.freezed.dart';
part 'dashboard_provider.g.dart';

@freezed
abstract class GuardianDashboardState with _$GuardianDashboardState {
  const factory GuardianDashboardState({
    GuardianDashboardData? data,
    @Default(false) bool isLoading,
    String? error,
    @Default('7d') String period, // Track selected period: '7d', '14d', '30d'
  }) = _GuardianDashboardState;
}

@freezed
abstract class GuardianAlertsState with _$GuardianAlertsState {
  const factory GuardianAlertsState({
    @Default([]) List<Alert> alerts,
    @Default(false) bool isLoading,
    String? error,
  }) = _GuardianAlertsState;
}

@riverpod
class GuardianDashboardController extends _$GuardianDashboardController {
  @override
  FutureOr<GuardianDashboardState> build() async {
    final service = ref.watch(dashboardServiceProvider);
    debugPrint('[DashboardProvider] build: fetching guardian dashboard');
    final result = await service.getGuardianDashboard(period: '7d'); // Default to 7 days
    
    return result.when(
      success: (data) {
        debugPrint('[DashboardProvider] build success: got ${data.totalAdolescentsLinked} adolescents');
        return GuardianDashboardState(data: data, isLoading: false, period: '7d');
      },
      failure: (f) {
        debugPrint('[DashboardProvider] build failure: ${f.message} (type: ${f.runtimeType})');
        return GuardianDashboardState(isLoading: false, error: f.message, period: '7d');
      },
    );
  }

  Future<void> refresh({String? period}) async {
    final effectivePeriod = period ?? '7d';
    debugPrint('[DashboardProvider] refresh(period=$effectivePeriod)');
    // Immediately update period and set loading flag
    state = AsyncValue.data(
      (state.value ?? const GuardianDashboardState()).copyWith(
        isLoading: true,
        period: effectivePeriod,
      ),
    );
    state = await AsyncValue.guard(() async {
      final service = ref.read(dashboardServiceProvider);
      final result = await service.getGuardianDashboard(period: effectivePeriod);
      return result.when(
        success: (data) => GuardianDashboardState(data: data, isLoading: false, period: effectivePeriod),
        failure: (f) => GuardianDashboardState(isLoading: false, error: f.message, period: effectivePeriod),
      );
    });
    debugPrint('[DashboardProvider] refresh complete, state: ${state.value?.error != null ? "error: ${state.value?.error}" : "success"}');
  }
}

@riverpod
class GuardianAlertsController extends _$GuardianAlertsController {
  @override
  FutureOr<GuardianAlertsState> build() async {
    final service = ref.watch(alertServiceProvider);
    final result = await service.getGuardianAlerts();

    return result.when(
      success: (alerts) => GuardianAlertsState(alerts: alerts, isLoading: false),
      failure: (f) => GuardianAlertsState(isLoading: false, error: f.message),
    );
  }

  Future<void> markAsViewed(String alertId) async {
    final currentState = state.value;
    if (currentState == null) return;

    final service = ref.read(alertServiceProvider);

    // Optimistic update
    final previousAlerts = currentState.alerts;
    final updatedAlerts = currentState.alerts.map(
      (a) => a.alertId == alertId ? a.copyWith(viewedStatus: true) : a
    ).toList();
    
    state = AsyncValue.data(currentState.copyWith(alerts: updatedAlerts));

    final result = await service.markViewed(alertId);
    if (result.isFailure) {
      // Rollback
      state = AsyncValue.data(currentState.copyWith(alerts: previousAlerts, error: result.failure.message));
    }
  }

  Future<void> resolveAlert(
    String alertId, {
    String? notes,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true, error: null));

    final service = ref.read(alertServiceProvider);
    final resolveResult = await service.resolveAlert(alertId, notes: notes);
    
    if (resolveResult.isFailure) {
      state = AsyncValue.data(currentState.copyWith(isLoading: false, error: resolveResult.failure.message));
      return;
    }

    // Refresh data after successful resolution
    await refresh();
  }

  Future<void> refresh() async {
    // We can't just invalidateSelf() because that would trigger a build() that might throw 
    // and we want to keep using our Explicit State pattern.
    // However, build() is already safe. Invalidation is fine too.
    
    state = AsyncValue.data(state.value?.copyWith(isLoading: true) ?? const GuardianAlertsState(isLoading: true));
    
    final service = ref.read(alertServiceProvider);
    final result = await service.getGuardianAlerts();
    
    state = AsyncValue.data(result.when(
      success: (alerts) => GuardianAlertsState(alerts: alerts, isLoading: false),
      failure: (f) => state.value?.copyWith(isLoading: false, error: f.message) ?? GuardianAlertsState(isLoading: false, error: f.message),
    ));
  }
}
