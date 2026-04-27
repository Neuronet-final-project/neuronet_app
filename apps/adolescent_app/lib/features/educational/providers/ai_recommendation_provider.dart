import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_recommendation_provider.freezed.dart';
part 'ai_recommendation_provider.g.dart';

@freezed
abstract class AIRecommendationState with _$AIRecommendationState {
  const factory AIRecommendationState({
    @Default([]) List<AIRecommendation> recommendations,
    @Default(false) bool isLoading,
    @Default(false) bool isAnalyzing,
    String? error,
  }) = _AIRecommendationState;
}

/// Controller for managing AI recommendations
@riverpod
class AIRecommendationController extends _$AIRecommendationController {
  @override
  FutureOr<AIRecommendationState> build() async {
    final service = ref.watch(aiRecommendationServiceProvider);
    final result = await service.getMyRecommendations();
    
    return result.when(
      success: (recommendations) => AIRecommendationState(
        recommendations: recommendations,
      ),
      failure: (f) => AIRecommendationState(error: f.message),
    );
  }

  /// Trigger AI analysis to generate new recommendations
  Future<bool> triggerAnalysis() async {
    state.whenData((data) {
      state = AsyncValue.data(data.copyWith(isAnalyzing: true));
    });

    final service = ref.read(aiRecommendationServiceProvider);
    final result = await service.analyzeAndRecommend();
    
    return result.when(
      success: (analysis) {
        // Refresh recommendations after analysis
        ref.invalidateSelf();
        return analysis.recommendationsCreated;
      },
      failure: (f) {
        state.whenData((data) {
          state = AsyncValue.data(
            data.copyWith(
              isAnalyzing: false,
              error: f.message,
            ),
          );
        });
        return false;
      },
    );
  }

  /// Mark a recommendation as viewed
  Future<bool> markAsViewed(String recommendationId) async {
    final service = ref.read(aiRecommendationServiceProvider);
    final result = await service.markRecommendationViewed(recommendationId);
    
    return result.when(
      success: (_) {
        // Update local state
        state.whenData((data) {
          final updatedRecommendations = data.recommendations.map((rec) {
            if (rec.recommendationId == recommendationId) {
              return rec.copyWith(isViewed: true);
            }
            return rec;
          }).toList();
          
          state = AsyncValue.data(
            data.copyWith(recommendations: updatedRecommendations),
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

  /// Refresh recommendations
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(aiRecommendationServiceProvider);
      final result = await service.getMyRecommendations();
      return result.when(
        success: (recommendations) => AIRecommendationState(
          recommendations: recommendations,
        ),
        failure: (f) => AIRecommendationState(error: f.message),
      );
    });
  }

  /// Get unviewed recommendations count
  int getUnviewedCount() {
    return state.value?.recommendations
        .where((rec) => !rec.isViewed)
        .length ?? 0;
  }
}
