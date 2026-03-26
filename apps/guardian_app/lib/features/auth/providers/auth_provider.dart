import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  activating,
  error
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  factory AuthState.authenticated() => const AuthState(status: AuthStatus.authenticated);
  factory AuthState.unauthenticated() => const AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.activating() => const AuthState(status: AuthStatus.activating);
  factory AuthState.error(String message) => AuthState(status: AuthStatus.error, errorMessage: message);
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = AuthState.initial();
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock logic: allow any non-empty input for demo
    if (email.isNotEmpty && password.length >= 6) {
      state = AuthState.authenticated();
    } else {
      state = AuthState.error('Invalid email or password');
    }
  }

  Future<void> activate(String code, String password) async {
    state = AuthState.initial();
    await Future.delayed(const Duration(seconds: 1));

    if (code == 'NEURO-2026' && password.length >= 6) {
      state = AuthState.authenticated();
    } else {
      state = AuthState.error('Invalid activation code or password');
    }
  }

  Future<void> logout() async {
    state = AuthState.initial();
    await Future.delayed(const Duration(milliseconds: 500));
    state = AuthState.unauthenticated();
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
