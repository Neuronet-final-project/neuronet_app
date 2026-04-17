import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_provider.freezed.dart';
part 'profile_provider.g.dart';

@freezed
abstract class GuardianProfileState with _$GuardianProfileState {
  const factory GuardianProfileState({
    User? user,
    @Default(false) bool isLoading,
    String? error,
  }) = _GuardianProfileState;
}

@riverpod
class GuardianProfileController extends _$GuardianProfileController {
  @override
  FutureOr<GuardianProfileState> build() async {
    final authService = ref.watch(authServiceProvider);
    final result = await authService.getMe();
    
    return result.when(
      success: (user) => GuardianProfileState(user: user, isLoading: false),
      failure: (f) => GuardianProfileState(isLoading: false, error: f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      final result = await authService.getMe();
      return result.when(
        success: (user) => GuardianProfileState(user: user, isLoading: false),
        failure: (f) => GuardianProfileState(isLoading: false, error: f.message),
      );
    });
  }
}
