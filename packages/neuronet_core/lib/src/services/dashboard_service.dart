import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'dashboard_service.g.dart';

class DashboardService {
  DashboardService(this._client);
  final ApiClient _client;

  /// Fetches the dashboard data for the currently authenticated guardian.
  Future<Result<GuardianDashboardData>> getGuardianDashboard() async {
    try {
      final response = await _client.get(ApiEndpoints.guardianDashboard);
      if (response.data == null) {
        return Result.success(GuardianDashboardData.empty());
      }
      if (response.data is! Map<String, dynamic>) {
        return Result.failure(
          const UnknownFailure(message: 'Unexpected response format'),
        );
      }
      final data = GuardianDashboardData.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(data);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches the dashboard data for the currently authenticated adolescent.
  Future<Result<DashboardData>> getAdolescentDashboard() async {
    try {
      final response = await _client.get(ApiEndpoints.adolescentDashboard);
      if (response.data == null) {
        return Result.success(DashboardData.empty());
      }
      if (response.data is! Map<String, dynamic>) {
        return Result.failure(
          const UnknownFailure(message: 'Unexpected response format'),
        );
      }
      final data = DashboardData.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(data);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches the list of linked adolescents for the current guardian.
  Future<Result<List<AdolescentResponse>>> getLinkedAdolescents() async {
    try {
      final response = await _client.get(ApiEndpoints.guardianAdolescents);
      final rawMap = response.data as Map<String, dynamic>;
      debugPrint(
        '[DIAGNOSTIC_LOG] getLinkedAdolescents raw response: $rawMap',
      );
      final data = rawMap['adolescents'] as List;
      final adolescents = data.map((e) {
        debugPrint('[DashboardService] Parsing adolescent: $e');
        return AdolescentResponse.fromJson(e as Map<String, dynamic>);
      }).toList();
      debugPrint(
        '[DashboardService] ✓ Parsed ${adolescents.length} adolescents',
      );
      return Result.success(adolescents);
    } catch (e) {
      debugPrint('[DashboardService] ✗ getLinkedAdolescents failed: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches consents for a specific adolescent by email.
  Future<Result<List<Consent>>> getAdolescentConsents(String email) async {
    try {
      final response = await _client.get(ApiEndpoints.consentByEmail(email));
      final data = response.data as Map<String, dynamic>;
      final adolescentEmail = data['adolescent_email'] as String;
      final consents = [
        Consent(
          consentId: 'ai-$adolescentEmail',
          adolescentId: adolescentEmail,
          guardianId: data['guardian_email'] as String? ?? '',
          consentType: ConsentType.shareAiSummaries,
          grantedToRole: GrantedToRole.guardian,
          consentStatus: (data['share_ai_summaries'] as bool? ?? false)
              ? ConsentStatus.granted
              : ConsentStatus.revoked,
          grantedAt: DateTime.now(),
        ),
        Consent(
          consentId: 'alerts-$adolescentEmail',
          adolescentId: adolescentEmail,
          guardianId: data['guardian_email'] as String? ?? '',
          consentType: ConsentType.shareAlerts,
          grantedToRole: GrantedToRole.guardian,
          consentStatus: (data['share_alerts'] as bool? ?? false)
              ? ConsentStatus.granted
              : ConsentStatus.revoked,
          grantedAt: DateTime.now(),
        ),
      ];
      return Result.success(consents);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.success([]);
      }
      return Result.failure(failureFromException(e));
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
DashboardService dashboardService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return DashboardService(client);
}
