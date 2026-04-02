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
    try {
      final response = await _client.get(ApiEndpoints.guardianDashboard);
      if (response.data == null) return GuardianDashboardData.empty();
      return GuardianDashboardData.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: /dashboard/guardian error: $e');
      return GuardianDashboardData.empty();
    }
  }

  /// Fetches the dashboard data for the currently authenticated adolescent.
  Future<DashboardData> getAdolescentDashboard() async {
    try {
      final response = await _client.get(ApiEndpoints.adolescentDashboard);
      if (response.data == null) return DashboardData.empty();
      return DashboardData.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: /dashboard/adolescent/me error: $e');
      return DashboardData.empty();
    }
  }
  
  /// Fetches the list of linked adolescents for the current guardian.
  Future<List<AdolescentResponse>> getLinkedAdolescents() async {
    final response = await _client.get(ApiEndpoints.guardianAdolescents);
    final data = response.data as List;
    return data.map((e) => AdolescentResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches consents for a specific adolescent by email.
  Future<List<Consent>> getAdolescentConsents(String email) async {
    final response = await _client.get(ApiEndpoints.consentByEmail(email));
    final data = response.data as List;
    return data.map((e) => Consent.fromJson(e as Map<String, dynamic>)).toList();
  }
}

@riverpod
DashboardService dashboardService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardService(client);
}
