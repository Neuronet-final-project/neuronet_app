import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart';

@riverpod
class GuardianProfileController extends _$GuardianProfileController {
  @override
  FutureOr<User> build() async {
    final authService = ref.watch(authServiceProvider);
    try {
      final user = await authService.getMe();
      // ignore: avoid_print
      print('DEBUG: GuardianProfileController loaded user: ${user.fullName}');
      return user;
    } catch (e, stack) {
      // ignore: avoid_print
      print('DEBUG: GuardianProfileController error: $e');
      // ignore: avoid_print
      print('DEBUG: Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authService = ref.read(authServiceProvider);
      return authService.getMe();
    });
  }
}
