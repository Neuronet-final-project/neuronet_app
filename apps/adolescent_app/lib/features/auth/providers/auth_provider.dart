import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.freezed.dart';
part 'auth_provider.g.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.authenticated() = _Authenticated;
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
    state = const AuthState.initial();
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple mock logic
    if (email.isNotEmpty && password.length >= 6) {
      state = const AuthState.authenticated();
    } else {
      state = const AuthState.error('Invalid email or password');
    }
  }

  Future<void> activate(String code, String password) async {
    state = const AuthState.initial();
    await Future.delayed(const Duration(seconds: 1));

    if (code == 'NEURO-2026' && password.length >= 6) {
      state = const AuthState.authenticated();
    } else {
      state = const AuthState.error('Invalid activation code or password');
    }
  }

  Future<void> logout() async {
    state = const AuthState.initial();
    await Future.delayed(const Duration(milliseconds: 500));
    state = const AuthState.unauthenticated();
  }
}
