import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'auth_provider.g.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  activating,
  error
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  const AuthState({
    required this.status,
    this.errorMessage,
    this.user,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => const AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(User user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.activating() => const AuthState(status: AuthStatus.activating);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, errorMessage: message);
}

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    return AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(email, password);
      
      final storage = ref.read(tokenStorageProvider);
      await storage.saveTokens(accessToken: response.accessToken);

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
    state = AuthState.activating();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.activateAccount(ActivateAccountRequest(
        email: email,
        activationToken: token,
        password: password,
      ));
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = AuthState.loading();
    final storage = ref.read(tokenStorageProvider);
    await storage.clearTokens();
    state = AuthState.unauthenticated();
  }
}
