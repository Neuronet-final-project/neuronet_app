import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
class GuardianDashboardController extends _$GuardianDashboardController {
  @override
  FutureOr<GuardianDashboardData> build() async {
    // In a real app, we would fetch the adolescent targeted for this guardian
    // For now, we use Alex Johnson from MockDataService
    return MockDataService.getMockGuardianDashboard();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return MockDataService.getMockGuardianDashboard();
    });
  }
}

@riverpod
class GuardianAlertsController extends _$GuardianAlertsController {
  @override
  FutureOr<List<Alert>> build() async {
    return MockDataService.getMockAlerts();
  }

  Future<void> markAsViewed(String alertId) async {
    // Logic to update viewed status in mock service if needed
    // For now, just refresh local state
    state = await AsyncValue.guard(() async {
      final currentAlerts = state.value ?? [];
      return currentAlerts.map((a) {
        if (a.alertId == alertId) {
          return a.copyWith(viewedStatus: true);
        }
        return a;
      }).toList();
    });
  }
}
