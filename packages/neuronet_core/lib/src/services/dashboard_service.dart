import 'package:dio/dio.dart';
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
      // ignore: avoid_print
      print('DEBUG: /dashboard/guardian raw: ${response.data}');
      if (response.data == null) return GuardianDashboardData.empty();
      if (response.data is! Map<String, dynamic>) {
        // ignore: avoid_print
        print('DEBUG: /dashboard/guardian unexpected type: ${response.data.runtimeType}');
        return GuardianDashboardData.empty();
      }
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
      // ignore: avoid_print
      print('DEBUG: /dashboard/adolescent raw: ${response.data}');
      if (response.data == null) return DashboardData.empty();
      if (response.data is! Map<String, dynamic>) {
        // ignore: avoid_print
        print('DEBUG: /dashboard/adolescent unexpected type: ${response.data.runtimeType}');
        return DashboardData.empty();
      }
      return DashboardData.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: /dashboard/adolescent error: $e');
      return DashboardData.empty();
    }
  }
  
  /// Fetches the list of linked adolescents for the current guardian.
  Future<List<AdolescentResponse>> getLinkedAdolescents() async {
    final response = await _client.get(ApiEndpoints.guardianAdolescents);
    // ignore: avoid_print
    print('DEBUG: /guardians/me/adolescents raw: ${response.data}');
    final rawMap = response.data as Map<String, dynamic>;
    final data = rawMap['adolescents'] as List;
    return data.map((e) => AdolescentResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetches consents for a specific adolescent by email.
  Future<List<Consent>> getAdolescentConsents(String email) async {
    try {
      final response = await _client.get(ApiEndpoints.consentByEmail(email));
      // ignore: avoid_print
      print('DEBUG: /consents/$email raw: ${response.data}');
      final data = response.data as List;
      return data.map((e) => Consent.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // ignore: avoid_print
        print('DEBUG: No consents found for $email (404), returning empty list.');
        return [];
      }
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('DEBUG: Unexpected error fetching consents for $email: $e');
      rethrow;
    }
  }
}

@riverpod
DashboardService dashboardService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardService(client);
}
