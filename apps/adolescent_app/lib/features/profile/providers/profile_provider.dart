import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class AdolescentProfileController extends _$AdolescentProfileController {
  @override
  FutureOr<User> build() async {
    final authService = ref.watch(authServiceProvider);
    final result = await authService.getMe();
    if (result.isSuccess) {
      return result.value;
    }
    // ignore: avoid_print
    print('PROFILE ERROR: Failed to fetch profile from server. Falling back to generic user.');
    // return a fallback user so we don't break the entire app shell
    return User(
      id: 'fallback',
      fullName: 'Member',
      email: '...',
      role: UserRole.adolescent,
      accountStatus: AccountStatus.active,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      final result = await authService.getMe();
      if (result.isFailure) {
        throw Exception(result.failure.message);
      }
      return result.value;
    });
  }
}
