import 'package:flutter/foundation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

// Wraps the global ValueNotifier so Riverpod can watch it.
@riverpod
int sessionExpired(Ref ref) => sessionExpiredNotifier.value;

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
    // Listen for session expiry from AuthInterceptor
    ref.listen(sessionExpiredProvider, (_, __) {
      state = AuthState.unauthenticated();
    });
    _checkInitialAuth();
    return AuthState.initial();
  }

  Future<void> _checkInitialAuth() async {
    try {
      final storage = ref.read(tokenStorageProvider);
      final token = await storage.getAccessToken();
      // Minimum splash display time so the user doesn't see a single-frame flash
      await Future.wait([_resolveAuth(token), Future.delayed(const Duration(milliseconds: 500))]);
    } catch (e) {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> _resolveAuth(String? token) async {
    if (token != null) {
      final authService = ref.read(authServiceProvider);
      final result = await authService.getMe();
      if (result.isSuccess) {
        final user = result.value;
        if (user.role != UserRole.guardian) {
          debugPrint('[AuthController] SECURITY: Unauthorized role (${user.role}) for Guardian app.');
          final storage = ref.read(tokenStorageProvider);
          await storage.clearTokens();
          state = AuthState.unauthenticated();
          return;
        }
        state = AuthState.authenticated(user);
        // Trigger push notification registration
        ref.read(notificationServiceProvider.notifier).triggerRegistration();
      } else {
        state = AuthState.unauthenticated();
      }
    } else {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.login(email, password, role: UserRole.guardian);

      if (result.isFailure) {
        state = AuthState.error(result.failure.message);
        return;
      }

      final response = result.value;

      // SECURITY: Validate role matches the app
      if (response.role != UserRole.guardian) {
        state = AuthState.error('Unauthorized access: This account does not have Guardian privileges.');
        return;
      }

      // Save the token to storage!
      final storage = ref.read(tokenStorageProvider);
      await storage.saveTokens(
        accessToken: response.accessToken,
      );

      // Fetch real user profile instead of using hardcoded data
      final userResult = await authService.getMe();
      if (userResult.isSuccess) {
        final user = userResult.value;
        
        // Double check role from profile
        if (user.role != UserRole.guardian) {
          await storage.clearTokens();
          state = AuthState.error('Unauthorized access: Account role mismatch.');
          return;
        }

        state = AuthState.authenticated(user);
        // Trigger push notification registration
        ref.read(notificationServiceProvider.notifier).triggerRegistration();
      } else {
        // Fallback to email-based user if profile fetch fails
        state = AuthState.authenticated(User(
          id: 'current',
          fullName: email.split('@').first,
          email: email,
          role: response.role,
          accountStatus: AccountStatus.active,
        ));
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.register(GuardianRegisterRequest(
        fullName: fullName,
        email: email,
        password: password,
      ));
      if (result.isFailure) {
        state = AuthState.error(result.failure.message);
        return;
      }
      // After registration, we usually want them to login
      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> activate(String email, String token, String password) async {
    state = AuthState.loading();
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.activateAccount(ActivateAccountRequest(
        email: email,
        activationToken: token,
        password: password,
      ));
      if (result.isFailure) {
        state = AuthState.error(result.failure.message);
        return;
      }
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
