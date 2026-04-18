import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'consent_service.g.dart';

class ConsentService {
  ConsentService(this._client);
  final ApiClient _client;

  /// Fetches all consents for the currently authenticated guardian's adolescents.
  Future<Result<List<Consent>>> getGuardianConsents() async {
    try {
      final adolescentsResult = await getLinkedAdolescents();
      if (adolescentsResult.isFailure) {
        return Result.failure(adolescentsResult.failure);
      }
      final adolescents = adolescentsResult.value;

      final allConsents = <Consent>[];
      for (final adolescent in adolescents) {
        final consentsResult = await getAdolescentConsents(adolescent.email);
        if (consentsResult.isSuccess) {
          allConsents.addAll(consentsResult.value);
        }
      }

      return Result.success(allConsents);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches consents for a specific adolescent by email.
  Future<Result<List<Consent>>> getAdolescentConsents(String email) async {
    try {
      final endpoint = ApiEndpoints.consentByEmail(email);
      final response = await _client.get(endpoint);

      if (response.data == null) {
        return Result.success(_provideDefaultConsents(email));
      }

      final consents = _mapBackendResponseToConsents(
        response.data as Map<String, dynamic>,
      );
      return Result.success(consents);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.success(_provideDefaultConsents(email));
      }
      return Result.failure(failureFromException(e));
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches the current user's (adolescent) own consent settings.
  /// Calls GET /consents/me — returns the consent object directly.
  Future<Result<Map<String, dynamic>>> getMyConsent() async {
    try {
      final response = await _client.get(ApiEndpoints.myConsent);
      final data = response.data as Map<String, dynamic>;
      return Result.success(data);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Updates a consent status using POST /consents/{email}.
  Future<Result<void>> updateConsent({
    required String email,
    required bool shareAiSummaries,
    required bool shareAlerts,
    required bool participation,
    required bool counselorChat,
  }) async {
    try {
      await _client.post(
        '/consents/$email',
        data: {
          'share_ai_summaries': shareAiSummaries,
          'share_alerts': shareAlerts,
          'participation': participation,
          'counselor_chat': counselorChat,
        },
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Map the backend's single-object response into a list of Consent objects for the UI.
  List<Consent> _mapBackendResponseToConsents(Map<String, dynamic> data) {
    final email = data['adolescent_email'] as String;
    return [
      Consent(
        consentId: 'fake-ai-$email',
        adolescentId: email,
        guardianId: data['guardian_email'] ?? '',
        consentType: ConsentType.shareAiSummaries,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: (data['share_ai_summaries'] as bool? ?? false)
            ? ConsentStatus.granted
            : ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
      Consent(
        consentId: 'fake-alerts-$email',
        adolescentId: email,
        guardianId: data['guardian_email'] ?? '',
        consentType: ConsentType.shareAlerts,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: (data['share_alerts'] as bool? ?? false)
            ? ConsentStatus.granted
            : ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
      Consent(
        consentId: 'fake-participation-$email',
        adolescentId: email,
        guardianId: data['guardian_email'] ?? '',
        consentType: ConsentType.participation,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: (data['participation'] as bool? ?? false)
            ? ConsentStatus.granted
            : ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
      Consent(
        consentId: 'fake-chat-$email',
        adolescentId: email,
        guardianId: data['guardian_email'] ?? '',
        consentType: ConsentType.counselorChat,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: (data['counselor_chat'] as bool? ?? false)
            ? ConsentStatus.granted
            : ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
    ];
  }

  /// Provide a default (revoked) set of consents if the adolescent has none.
  List<Consent> _provideDefaultConsents(String email) {
    return [
      Consent(
        consentId: 'empty-ai-$email',
        adolescentId: email,
        guardianId: '',
        consentType: ConsentType.shareAiSummaries,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
      Consent(
        consentId: 'empty-alerts-$email',
        adolescentId: email,
        guardianId: '',
        consentType: ConsentType.shareAlerts,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
      Consent(
        consentId: 'empty-participation-$email',
        adolescentId: email,
        guardianId: '',
        consentType: ConsentType.participation,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
      Consent(
        consentId: 'empty-chat-$email',
        adolescentId: email,
        guardianId: '',
        consentType: ConsentType.counselorChat,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: ConsentStatus.revoked,
        grantedAt: DateTime.now(),
      ),
    ];
  }

  Future<Result<List<AdolescentResponse>>> getLinkedAdolescents() async {
    try {
      final response = await _client.get(ApiEndpoints.guardianAdolescents);

      if (response.data == null || response.data['adolescents'] == null) {
        return Result.success([]);
      }

      final rawAdolescents = response.data['adolescents'] as List<dynamic>;
      final adolescents = rawAdolescents
          .map((e) => AdolescentResponse.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(adolescents);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}

@Riverpod(keepAlive: true)
ConsentService consentService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return ConsentService(client);
}
