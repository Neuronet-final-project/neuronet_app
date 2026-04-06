import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardData> adolescentDashboard(Ref ref) async {
  final service = ref.watch(dashboardServiceProvider);
  final result = await service.getAdolescentDashboard();
  return result.when(
    success: (value) => value,
    failure: (f) => throw Exception(f.message),
  );
}
