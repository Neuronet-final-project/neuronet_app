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
      print('DEBUG: [AuthService] Raw /auth/me response: $raw');

      // Some backend versions return 'id' instead of '_id'.
      // Normalise so User.fromJson always finds '_id'.
      if ((raw['_id'] == null || (raw['_id'] as String).isEmpty) &&
          raw['id'] != null) {
        raw['_id'] = raw['id'];
      }

      final user = User.fromJson(raw);
      print('DEBUG: [AuthService] Parsed User: id="${user.id}", adolescentId="${user.adolescentId}", email="${user.email}"');
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
      final data = response.data as List;
      final adolescents = data
          .map((e) => AdolescentResponse.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(adolescents);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}
