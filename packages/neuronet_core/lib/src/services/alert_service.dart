import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'alert_service.g.dart';

class AlertService {
  AlertService(this._client);
  final ApiClient _client;

  /// Fetches all alerts for the authenticated guardian.
  Future<List<Alert>> getGuardianAlerts() async {
    final response = await _client.get(ApiEndpoints.guardianAlerts);
    final list = response.data as List<dynamic>;
    return list.map((json) => Alert.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Fetches all alerts for a specific adolescent (self-facing).
  Future<List<Alert>> getAdolescentAlerts(String adolescentId) async {
    final response = await _client.get(ApiEndpoints.alertsByAdolescent(adolescentId));
    final list = response.data as List<dynamic>;
    return list.map((json) => Alert.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Marks an alert as viewed.
  Future<void> markViewed(String alertId) async {
    await _client.put(ApiEndpoints.markViewed(alertId));
  }

  /// Resolves an alert.
  Future<Alert> resolveAlert(String alertId, {String? notes}) async {
    final response = await _client.put(
      ApiEndpoints.resolveAlert(alertId),
      data: notes != null ? {'action_notes': notes} : null,
    );
    return Alert.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
AlertService alertService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return AlertService(client);
}
