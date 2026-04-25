import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'ai_recommendation_service.g.dart';

class AIRecommendationService {
  AIRecommendationService(this._client);
  final ApiClient _client;

  /// Trigger AI analysis and create recommendations for the current adolescent
  Future<Result<AIRecommendationAnalysis>> analyzeAndRecommend() async {
    try {
      final response = await _client.post(
        ApiEndpoints.analyzeAndRecommend,
        data: {},
      );
      final analysis = AIRecommendationAnalysis.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(analysis);
    } catch (e) {
      debugPrint('[AIRecommendationService] analyzeAndRecommend ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Get active AI recommendations for the current adolescent
  Future<Result<List<AIRecommendation>>> getMyRecommendations() async {
    try {
      final response = await _client.get(ApiEndpoints.myAIRecommendations);
      final list = response.data as List<dynamic>;
      final recommendations = list
          .map((json) => AIRecommendation.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(recommendations);
    } catch (e) {
      debugPrint('[AIRecommendationService] getMyRecommendations ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Mark a recommendation as viewed by the adolescent
  Future<Result<void>> markRecommendationViewed(String recommendationId) async {
    try {
      await _client.post(
        ApiEndpoints.markRecommendationViewed(recommendationId),
        data: {},
      );
      return const Result.success(null);
    } catch (e) {
      debugPrint('[AIRecommendationService] markRecommendationViewed ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
AIRecommendationService aiRecommendationService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return AIRecommendationService(client);
}