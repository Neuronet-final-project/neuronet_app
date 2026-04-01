import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class GuardianDashboardController extends _$GuardianDashboardController {
  @override
  FutureOr<GuardianDashboardData> build() async {
    final service = ref.watch(dashboardServiceProvider);
    try {
      final data = await service.getGuardianDashboard();
      // ignore: avoid_print
      print('DEBUG: Dashboard data loaded for: ${data.adolescentName}');
      return data;
    } catch (e, stack) {
      // ignore: avoid_print
      print('DEBUG: GuardianDashboardController error: $e');
      // ignore: avoid_print
      print('DEBUG: Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(dashboardServiceProvider);
      return service.getGuardianDashboard();
    });
  }
}

@riverpod
class GuardianAlertsController extends _$GuardianAlertsController {
  @override
  FutureOr<List<Alert>> build() async {
    final service = ref.watch(alertServiceProvider);
    return service.getGuardianAlerts();
  }

  Future<void> markAsViewed(String alertId) async {
    final service = ref.read(alertServiceProvider);
    
    // Optistic update for better UX
    final previousState = state;
    state = AsyncValue.data(
      (state.value ?? []).map((a) => a.alertId == alertId ? a.copyWith(viewedStatus: true) : a).toList(),
    );

    try {
      await service.markViewed(alertId);
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
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await service.resolveAlert(alertId, notes: notes);
      return service.getGuardianAlerts();
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(alertServiceProvider);
      return service.getGuardianAlerts();
    });
  }
}
