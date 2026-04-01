import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.activating() = _Activating;
  const factory AuthState.error(String message) = _Error;
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    // Start as unauthenticated for the pilot/demo
    return const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(email, password);
      
      // For this pilot, use a dummy user with the role from response
      final user = User(
        id: 'current',
        fullName: 'Adolescent User',
        email: email,
        role: response.role,
        accountStatus: AccountStatus.active,
      );
      
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> activate(String email, String token, String password) async {
    state = const AuthState.activating();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.activateAccount(ActivateAccountRequest(
        email: email,
        activationToken: token,
        password: password,
      ));
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    final storage = ref.read(tokenStorageProvider);
    await storage.clearTokens();
    state = const AuthState.unauthenticated();
  }
}
