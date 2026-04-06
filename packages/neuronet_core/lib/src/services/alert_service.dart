import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'alert_service.g.dart';

class AlertService {
  AlertService(this._client);
  final ApiClient _client;

  /// Fetches all alerts for the authenticated guardian.
  Future<Result<List<Alert>>> getGuardianAlerts() async {
    try {
      final response = await _client.get(ApiEndpoints.guardianAlerts);
      final list = response.data as List<dynamic>;
      final alerts = list
          .map((json) => Alert.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(alerts);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches all alerts for a specific adolescent (self-facing).
  Future<Result<List<Alert>>> getAdolescentAlerts(String adolescentId) async {
    try {
      final response = await _client.get(
        ApiEndpoints.alertsByAdolescent(adolescentId),
      );
      final list = response.data as List<dynamic>;
      final alerts = list
          .map((json) => Alert.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(alerts);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Marks an alert as viewed.
  Future<Result<void>> markViewed(String alertId) async {
    try {
      await _client.put(ApiEndpoints.markViewed(alertId));
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Resolves an alert.
  Future<Result<Alert>> resolveAlert(String alertId, {String? notes}) async {
    try {
      final response = await _client.put(
        ApiEndpoints.resolveAlert(alertId),
        data: notes != null ? {'action_notes': notes} : null,
      );
      final alert = Alert.fromJson(response.data as Map<String, dynamic>);
      return Result.success(alert);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
AlertService alertService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return AlertService(client);
}
