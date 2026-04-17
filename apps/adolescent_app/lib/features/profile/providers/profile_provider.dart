import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.freezed.dart';
part 'profile_provider.g.dart';

@freezed
abstract class AdolescentProfileState with _$AdolescentProfileState {
  const factory AdolescentProfileState({
    User? user,
    @Default(false) bool isLoading,
    String? error,
  }) = _AdolescentProfileState;
}

@riverpod
class AdolescentProfileController extends _$AdolescentProfileController {
  @override
  FutureOr<AdolescentProfileState> build() async {
    final authService = ref.watch(authServiceProvider);
    final result = await authService.getMe();
    
    return result.when(
      success: (value) => AdolescentProfileState(user: value, isLoading: false),
      failure: (f) {
        debugPrint('[Profile] Failed to fetch profile from server: ${f.message}');
        // Fallback user to prevent total app failure
        final fallback = User(
          id: 'fallback',
          fullName: 'Member',
          email: '...',
          role: UserRole.adolescent,
          accountStatus: AccountStatus.active,
        );
        return AdolescentProfileState(user: fallback, isLoading: false, error: f.message);
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      final result = await authService.getMe();
      
      return result.when(
        success: (value) => AdolescentProfileState(user: value, isLoading: false),
        failure: (f) => AdolescentProfileState(
          user: state.value?.user,
          isLoading: false,
          error: f.message,
        ),
      );
    });
  }
}
