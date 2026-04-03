import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class GuardianProfileController extends _$GuardianProfileController {
  @override
  FutureOr<User> build() async {
    final authService = ref.watch(authServiceProvider);
    return authService.getMe();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      return authService.getMe();
    });
  }
}
