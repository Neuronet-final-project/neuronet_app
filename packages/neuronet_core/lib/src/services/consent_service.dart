import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'consent_service.g.dart';

class ConsentService {
  ConsentService(this._client);
  final ApiClient _client;

  /// Fetches all consents for the currently authenticated guardian's adolescents.
  Future<List<Consent>> getGuardianConsents() async {
    try {
      print('DEBUG: [ConsentService] Fetching linked adolescents list...');
      final response = await _client.get(ApiEndpoints.guardianAdolescents);
      print('DEBUG: [ConsentService] Adolescents response: ${response.data}');
      
      if (response.data == null || response.data['adolescents'] == null) {
        print('DEBUG: [ConsentService] No adolescents found.');
        return [];
      }
      
      final rawAdolescents = response.data['adolescents'] as List<dynamic>;
      final adolescents = rawAdolescents.map((e) => AdolescentResponse.fromJson(e as Map<String, dynamic>)).toList();
      print('DEBUG: [ConsentService] Found ${adolescents.length} adolescents.');

      final allConsents = <Consent>[];
      for (final adolescent in adolescents) {
        print('DEBUG: [ConsentService] Fetching consents for ${adolescent.email}...');
        final consents = await getAdolescentConsents(adolescent.email);
        allConsents.addAll(consents);
      }
      
      print('DEBUG: [ConsentService] Total consents fetched: ${allConsents.length}');
      return allConsents;
    } catch (e) {
      print('DEBUG: [ConsentService] getGuardianConsents error: $e');
      rethrow;
    }
  }

  /// Fetches consents for a specific adolescent by email.
  Future<List<Consent>> getAdolescentConsents(String email) async {
    try {
      final endpoint = ApiEndpoints.consentByEmail(email);
      print('DEBUG: [ConsentService] getAdolescentConsents($email) calling $endpoint');
      final response = await _client.get(endpoint);
      print('DEBUG: [ConsentService] getAdolescentConsents($email) response data: ${response.data}');
      
      if (response.data == null) {
        return _provideDefaultConsents(email);
      }
      
      return _mapBackendResponseToConsents(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        print('DEBUG: [ConsentService] No consents found for $email (404), providing defaults.');
        return _provideDefaultConsents(email);
      }
      print('DEBUG: [ConsentService] getAdolescentConsents($email) dio error: $e');
      rethrow;
    } catch (e) {
      print('DEBUG: [ConsentService] getAdolescentConsents($email) unexpected error: $e');
      rethrow;
    }
  }

  /// Updates a consent status using POST /consents/{email}.
  /// Since the backend uses a single object with multiple flags, we pass everything.
  Future<void> updateConsent({
    required String email,
    required bool shareAiSummaries,
    required bool shareAlerts,
  }) async {
    try {
      print('DEBUG: [ConsentService] Updating consents for $email: AI=$shareAiSummaries, Alerts=$shareAlerts');
      await _client.post(
        '/consents/$email',
        data: {
          'share_ai_summaries': shareAiSummaries,
          'share_alerts': shareAlerts,
        },
      );
      print('DEBUG: [ConsentService] updateConsent successful');
    } catch (e) {
      print('DEBUG: [ConsentService] updateConsent error: $e');
      rethrow;
    }
  }

  /// Map the backend's single-object response into a list of Consent objects for the UI.
  List<Consent> _mapBackendResponseToConsents(Map<String, dynamic> data) {
    final email = data['adolescent_email'] as String;
    return [
      Consent(
        consentId: 'fake-ai-${email}', // Virtual ID
        adolescentId: email,
        guardianId: data['guardian_email'] ?? '',
        consentType: ConsentType.shareAiSummaries,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: (data['share_ai_summaries'] as bool? ?? false) ? ConsentStatus.granted : ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
      Consent(
        consentId: 'fake-alerts-${email}', // Virtual ID
        adolescentId: email,
        guardianId: data['guardian_email'] ?? '',
        consentType: ConsentType.shareAlerts,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: (data['share_alerts'] as bool? ?? false) ? ConsentStatus.granted : ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
    ];
  }

  /// Provide a default (revoked) set of consents if the adolescent has none.
  List<Consent> _provideDefaultConsents(String email) {
    return [
      Consent(
        consentId: 'empty-ai-${email}',
        adolescentId: email,
        guardianId: '',
        consentType: ConsentType.shareAiSummaries,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: ConsentStatus.revoked, // Default to revoked
        grantedAt: DateTime.now(),
      ),
      Consent(
        consentId: 'empty-alerts-${email}',
        adolescentId: email,
        guardianId: '',
        consentType: ConsentType.shareAlerts,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: ConsentStatus.revoked, // Default to revoked
        grantedAt: DateTime.now(),
      ),
    ];
  }
}

@riverpod
ConsentService consentService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return ConsentService(client);
}
