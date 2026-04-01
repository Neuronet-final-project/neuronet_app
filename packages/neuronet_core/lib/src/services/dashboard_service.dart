import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'dashboard_service.g.dart';

class DashboardService {
  DashboardService(this._client);
  final ApiClient _client;

  /// Fetches the dashboard data for the currently authenticated guardian.
  Future<GuardianDashboardData> getGuardianDashboard() async {
    final response = await _client.get(ApiEndpoints.guardianDashboard);
    return GuardianDashboardData.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches the dashboard data for the currently authenticated adolescent.
  Future<DashboardData> getAdolescentDashboard() async {
    final response = await _client.get(ApiEndpoints.adolescentDashboard);
    return DashboardData.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
DashboardService dashboardService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardService(client);
}
