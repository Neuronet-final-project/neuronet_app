import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'educational_follow_provider.freezed.dart';
part 'educational_follow_provider.g.dart';

@freezed
abstract class EducationalFollowState with _$EducationalFollowState {
  const factory EducationalFollowState({
    @Default([]) List<FollowedPageSummary> followedPages,
    @Default([]) List<EducationalPageWithFollowStatus> discoveredPages,
    @Default({}) Map<String, bool> followStatusCache,
    @Default(false) bool isLoading,
    String? error,
  }) = _EducationalFollowState;
}

/// Controller for managing followed educational pages
@riverpod
class EducationalFollowController extends _$EducationalFollowController {
  @override
  FutureOr<EducationalFollowState> build() async {
    final service = ref.watch(educationalFollowServiceProvider);
    final result = await service.getMyFollowedPages();
    
    return result.when(
      success: (pages) => EducationalFollowState(followedPages: pages),
      failure: (f) => EducationalFollowState(error: f.message),
    );
  }

  /// Follow a page
  Future<bool> followPage(String pageSlug) async {
    final service = ref.read(educationalFollowServiceProvider);
    final result = await service.followPage(pageSlug);
    
    return result.when(
      success: (_) {
        // Refresh the followed pages list
        ref.invalidateSelf();
        // Update cache
        state.whenData((data) {
          state = AsyncValue.data(
            data.copyWith(
              followStatusCache: {...data.followStatusCache, pageSlug: true},
            ),
          );
        });
        return true;
      },
      failure: (f) {
        state.whenData((data) {
          state = AsyncValue.data(data.copyWith(error: f.message));
        });
        return false;
      },
    );
  }

  /// Unfollow a page
  Future<bool> unfollowPage(String pageSlug) async {
    final service = ref.read(educationalFollowServiceProvider);
    final result = await service.unfollowPage(pageSlug);
    
    return result.when(
      success: (_) {
        // Refresh the followed pages list
        ref.invalidateSelf();
        // Update cache
        state.whenData((data) {
          state = AsyncValue.data(
            data.copyWith(
              followStatusCache: {...data.followStatusCache, pageSlug: false},
            ),
          );
        });
        return true;
      },
      failure: (f) {
        state.whenData((data) {
          state = AsyncValue.data(data.copyWith(error: f.message));
        });
        return false;
      },
    );
  }

  /// Check if a page is followed
  Future<bool> isPageFollowed(String pageSlug) async {
    // Check cache first
    final currentState = state.value;
    if (currentState != null && currentState.followStatusCache.containsKey(pageSlug)) {
      return currentState.followStatusCache[pageSlug]!;
    }

    // Fetch from API
    final service = ref.read(educationalFollowServiceProvider);
    final result = await service.isPageFollowed(pageSlug);
    
    return result.when(
      success: (isFollowed) {
        // Update cache
        state.whenData((data) {
          state = AsyncValue.data(
            data.copyWith(
              followStatusCache: {...data.followStatusCache, pageSlug: isFollowed},
            ),
          );
        });
        return isFollowed;
      },
      failure: (_) => false,
    );
  }

  /// Refresh followed pages
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(educationalFollowServiceProvider);
      final result = await service.getMyFollowedPages();
      return result.when(
        success: (pages) => EducationalFollowState(followedPages: pages),
        failure: (f) => EducationalFollowState(error: f.message),
      );
    });
  }
}

/// Controller for discovering educational pages
@riverpod
class PageDiscoveryController extends _$PageDiscoveryController {
  @override
  FutureOr<EducationalFollowState> build({String? category, String? search}) async {
    final service = ref.watch(educationalFollowServiceProvider);
    final result = await service.discoverPages(category: category, search: search);
    
    return result.when(
      success: (pages) => EducationalFollowState(discoveredPages: pages),
      failure: (f) => EducationalFollowState(error: f.message),
    );
  }

  /// Refresh discovered pages
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(educationalFollowServiceProvider);
      final result = await service.discoverPages(category: category, search: search);
      return result.when(
        success: (pages) => EducationalFollowState(discoveredPages: pages),
        failure: (f) => EducationalFollowState(error: f.message),
      );
    });
  }
}

/// Provider to get follow count for a specific page
@riverpod
Future<int> pageFollowCount(Ref ref, String pageSlug) async {
  final service = ref.watch(educationalFollowServiceProvider);
  final result = await service.getPageFollowCount(pageSlug);
  return result.when(
    success: (count) => count,
    failure: (_) => 0,
  );
}