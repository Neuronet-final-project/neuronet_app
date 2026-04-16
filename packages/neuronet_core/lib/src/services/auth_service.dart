import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient);
}

class AuthService {
  AuthService(this._apiClient);
  final ApiClient _apiClient;

  Future<Result<AuthResponse>> login(String email, String password) async {
    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _apiClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(authResponse);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  Future<Result<void>> register(GuardianRegisterRequest request) async {
    try {
      await _apiClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  Future<Result<void>> activateAccount(ActivateAccountRequest request) async {
    try {
      await _apiClient.post(
        ApiEndpoints.activateAccount,
        data: request.toJson(),
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  Future<Result<User>> getMe() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.me);
      final raw = Map<String, dynamic>.from(
        response.data as Map<String, dynamic>,
      );

      // DEBUG: Log raw /auth/me response
      debugPrint('[AuthService] Raw /auth/me response: $raw');

      // Some backend versions return 'id' instead of '_id'.
      // Normalise so User.fromJson always finds '_id'.
      if ((raw['_id'] == null || (raw['_id'] as String).isEmpty) &&
          raw['id'] != null) {
        raw['_id'] = raw['id'];
      }

      final user = User.fromJson(raw);
      debugPrint('[AuthService] Parsed User: id="${user.id}", adolescentId="${user.adolescentId}", email="${user.email}"');
      return Result.success(user);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  Future<Result<String>> createAdolescent(
    AdolescentCreateRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.createAdolescent,
        data: request.toJson(),
      );
      final token = response.data['activation_token'] as String;
      return Result.success(token);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  Future<Result<List<AdolescentResponse>>> getPendingAdolescents() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.pendingAdolescents);
      
      // Log raw response for debugging
      debugPrint('[AuthService] getPendingAdolescents raw response: ${response.data}');
      
      // Handle both wrapped and unwrapped response formats
      final List<dynamic> data;
      if (response.data is Map<String, dynamic>) {
        // Wrapped format: {adolescents: [...]}
        final wrapped = response.data as Map<String, dynamic>;
        data = wrapped['adolescents'] as List? ?? [];
        debugPrint('[AuthService] Extracted ${data.length} adolescents from wrapped response');
      } else if (response.data is List) {
        // Direct list format
        data = response.data as List;
        debugPrint('[AuthService] Direct list with ${data.length} adolescents');
      } else {
        debugPrint('[AuthService] Unexpected response format: ${response.data.runtimeType}');
        return const Result.failure(
          UnknownFailure(message: 'Unexpected response format from pending adolescents endpoint'),
        );
      }
      
      final adolescents = data
          .map((e) {
            debugPrint('[AuthService] Parsing pending adolescent: $e');
            return AdolescentResponse.fromJson(e as Map<String, dynamic>);
          })
          .toList();
      
      debugPrint('[AuthService] ✓ Parsed ${adolescents.length} pending adolescent(s)');
      return Result.success(adolescents);
    } catch (e) {
      debugPrint('[AuthService] ✗ getPendingAdolescents failed: $e');
      return Result.failure(failureFromException(e));
    }
  }

  Future<Result<void>> registerDeviceToken(String deviceToken) async {
    try {
      await _apiClient.post(
        ApiEndpoints.deviceToken,
        data: {'device_token': deviceToken},
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  Future<Result<void>> unregisterDeviceToken() async {
    try {
      await _apiClient.delete(ApiEndpoints.deviceToken);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}
