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
    // We can also check if we are already logged in here by calling storage.hasToken
    return AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.login(email, password);
      // After login, we usually fetch the user profile
      // For now, we assume the backend might provide it or we can create a mock User from the token role
      // But the best is to call a 'getMe' if available. Let's assume we fetch it later or use response info.
      // Since LoginResponse currently only has tokens and role, we'll mark as authenticated.
      // Ideally AuthService should have a getMe()
      
      // For this pilot, we'll use a dummy user with the role from response
      final user = User(
        id: 'current',
        fullName: 'Guardian User',
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
    state = AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      await authService.activateAccount(ActivateAccountRequest(
        email: email,
        activationToken: token,
        password: password,
      ));
      state = AuthState.unauthenticated(); // Require login after activation
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
