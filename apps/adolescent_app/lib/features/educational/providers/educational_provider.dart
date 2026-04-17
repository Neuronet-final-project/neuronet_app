import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/providers/profile_provider.dart';

part 'educational_provider.freezed.dart';
part 'educational_provider.g.dart';

@freezed
abstract class EducationalState with _$EducationalState {
  const factory EducationalState({
    @Default([]) List<EducationalPage> pages,
    @Default([]) List<Recommendation> recommendations,
    @Default(false) bool isLoading,
    String? error,
  }) = _EducationalState;
}

@riverpod
class EducationalPagesController extends _$EducationalPagesController {
  @override
  FutureOr<EducationalState> build() async {
    final service = ref.watch(educationalServiceProvider);
    final result = await service.listPages();
    
    return result.when(
      success: (value) => EducationalState(pages: value, isLoading: false),
      failure: (f) => EducationalState(isLoading: false, error: f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(educationalServiceProvider);
      final result = await service.listPages();
      return result.when(
        success: (value) => EducationalState(pages: value, isLoading: false),
        failure: (f) => EducationalState(
          pages: state.value?.pages ?? [],
          isLoading: false,
          error: f.message,
        ),
      );
    });
  }
}

@riverpod
class AdolescentRecommendationsController extends _$AdolescentRecommendationsController {
  @override
  FutureOr<EducationalState> build() async {
    final profileState = await ref.watch(adolescentProfileControllerProvider.future);
    final service = ref.watch(educationalServiceProvider);

    final id = profileState.user?.id ?? '';
    if (id.isEmpty || id == 'fallback') {
      return const EducationalState(recommendations: [], isLoading: false);
    }

    final result = await service.getRecommendations(id);
    return result.when(
      success: (value) => EducationalState(recommendations: value, isLoading: false),
      failure: (f) => EducationalState(isLoading: false, error: f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profileState = await ref.read(adolescentProfileControllerProvider.future);
      final service = ref.read(educationalServiceProvider);

      final id = profileState.user?.id ?? '';
      if (id.isEmpty || id == 'fallback') {
        return const EducationalState(recommendations: [], isLoading: false);
      }

      final result = await service.getRecommendations(id);
      return result.when(
        success: (value) => EducationalState(recommendations: value, isLoading: false),
        failure: (f) => EducationalState(
          recommendations: state.value?.recommendations ?? [],
          isLoading: false,
          error: f.message,
        ),
      );
    });
  }
}

@riverpod
Future<EducationalPage> educationalPage(Ref ref, String slug) async {
  final service = ref.watch(educationalServiceProvider);
  final result = await service.getPage(slug);
  return result.when(
    success: (value) => value,
    failure: (f) => throw Exception(f.message),
  );
}
