import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_provider.g.dart';

@riverpod
@riverpod
Future<DashboardData> adolescentDashboard(Ref ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Return mock data for now
  return MockDataService.getMockAdolescentDashboard();
}
