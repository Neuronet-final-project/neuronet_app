import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_recommendation.freezed.dart';

@freezed
abstract class AIRecommendation with _$AIRecommendation {
  const factory AIRecommendation({
    @JsonKey(name: 'recommendation_id') required String recommendationId,
    @JsonKey(name: 'recommendation_type') required String recommendationType,
    @JsonKey(name: 'trigger_reason') required String triggerReason,
    @JsonKey(name: 'recommended_pages') required List<RecommendedPage> recommendedPages,
    @JsonKey(name: 'is_viewed') @Default(false) bool isViewed,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AIRecommendation;

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['created_at'];
    final createdAt = createdAtStr != null 
        ? DateTime.parse(createdAtStr as String) 
        : DateTime.now();

    final recommendedPagesJson = json['recommended_pages'] as List<dynamic>? ?? [];
    final recommendedPages = recommendedPagesJson
        .map((pageJson) => RecommendedPage.fromJson(pageJson as Map<String, dynamic>))
        .toList();

    return AIRecommendation(
      recommendationId: json['recommendation_id'] as String? ?? '',
      recommendationType: json['recommendation_type'] as String? ?? '',
      triggerReason: json['trigger_reason'] as String? ?? '',
      recommendedPages: recommendedPages,
      isViewed: json['is_viewed'] as bool? ?? false,
      createdAt: createdAt,
    );
  }
}

@freezed
abstract class RecommendedPage with _$RecommendedPage {
  const factory RecommendedPage({
    @JsonKey(name: 'slug') required String slug,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'content') String? content,
    @JsonKey(name: 'category') String? category,
    @JsonKey(name: 'counselor_name') String? counselorName,
    @JsonKey(name: 'relevance_score') @Default(0) int relevanceScore,
    @JsonKey(name: 'follow_count') @Default(0) int followCount,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _RecommendedPage;

  factory RecommendedPage.fromJson(Map<String, dynamic> json) {
    return RecommendedPage(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String?,
      category: json['category'] as String?,
      counselorName: json['counselor_name'] as String?,
      relevanceScore: json['relevance_score'] as int? ?? 0,
      followCount: json['follow_count'] as int? ?? 0,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

@freezed
abstract class AIRecommendationAnalysis with _$AIRecommendationAnalysis {
  const factory AIRecommendationAnalysis({
    @JsonKey(name: 'message') required String message,
    @JsonKey(name: 'recommendations_created') required bool recommendationsCreated,
    @JsonKey(name: 'recommendation') AIRecommendationResult? recommendation,
  }) = _AIRecommendationAnalysis;

  factory AIRecommendationAnalysis.fromJson(Map<String, dynamic> json) {
    AIRecommendationResult? recommendation;
    if (json['recommendation'] != null) {
      recommendation = AIRecommendationResult.fromJson(
        json['recommendation'] as Map<String, dynamic>
      );
    }

    return AIRecommendationAnalysis(
      message: json['message'] as String? ?? '',
      recommendationsCreated: json['recommendations_created'] as bool? ?? false,
      recommendation: recommendation,
    );
  }
}

@freezed
abstract class AIRecommendationResult with _$AIRecommendationResult {
  const factory AIRecommendationResult({
    @JsonKey(name: 'recommendation_id') required String recommendationId,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'recommended_pages') required List<RecommendedPage> recommendedPages,
    @JsonKey(name: 'trigger_reason') required String triggerReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AIRecommendationResult;

  factory AIRecommendationResult.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['created_at'];
    final createdAt = createdAtStr != null 
        ? DateTime.parse(createdAtStr as String) 
        : DateTime.now();

    final recommendedPagesJson = json['recommended_pages'] as List<dynamic>? ?? [];
    final recommendedPages = recommendedPagesJson
        .map((pageJson) => RecommendedPage.fromJson(pageJson as Map<String, dynamic>))
        .toList();

    return AIRecommendationResult(
      recommendationId: json['recommendation_id'] as String? ?? '',
      adolescentId: json['adolescent_id'] as String? ?? '',
      recommendedPages: recommendedPages,
      triggerReason: json['trigger_reason'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}