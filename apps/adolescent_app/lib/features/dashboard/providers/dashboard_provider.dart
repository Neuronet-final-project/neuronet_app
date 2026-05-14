import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.freezed.dart';
part 'dashboard_provider.g.dart';

@freezed
abstract class DashboardState with _$DashboardState {
  const factory DashboardState({
    DashboardData? data,
    @Default(false) bool isLoading,
    String? error,
  }) = _DashboardState;
}

@riverpod
class AdolescentDashboardController extends _$AdolescentDashboardController {
  @override
  FutureOr<DashboardState> build() async {
    final service = ref.read(dashboardServiceProvider);
    final result = await service.getAdolescentDashboard();
    
    return result.when(
      success: (value) => DashboardState(data: value, isLoading: false),
      failure: (f) => DashboardState(isLoading: false, error: f.message),
    );
  }

  Future<void> refresh() async {
    // If we already have data, don't set state to loading manually.
    // Riverpod will automatically set state to 'isLoading: true' while keeping the data.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }
    
    state = await AsyncValue.guard(() async {
      final service = ref.read(dashboardServiceProvider);
      final result = await service.getAdolescentDashboard();
      return result.when(
        success: (value) => DashboardState(data: value, isLoading: false),
        failure: (f) => DashboardState(isLoading: false, error: f.message),
      );
    });
  }
}
