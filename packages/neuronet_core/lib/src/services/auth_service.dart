import 'package:riverpod_annotation/riverpod_annotation.dart';
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

  Future<AuthResponse> login(String email, String password) async {
    final request = LoginRequest(email: email, password: password);
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> register(GuardianRegisterRequest request) async {
    await _apiClient.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
  }

  Future<void> activateAccount(ActivateAccountRequest request) async {
    await _apiClient.post(
      ApiEndpoints.activateAccount,
      data: request.toJson(),
    );
  }

  Future<User> getMe() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return User.fromJson(response.data as Map<String, dynamic>);
  }

  Future<String> createAdolescent(AdolescentCreateRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.createAdolescent,
      data: request.toJson(),
    );
    // Backend returns the activation token directly or in a field
    return response.data['activation_token'] as String;
  }

  Future<List<AdolescentResponse>> getPendingAdolescents() async {
    final response = await _apiClient.get(ApiEndpoints.pendingAdolescents);
    final data = response.data as List;
    return data.map((e) => AdolescentResponse.fromJson(e as Map<String, dynamic>)).toList();
  }
}
