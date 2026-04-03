import 'package:freezed_annotation/freezed_annotation.dart';

part 'educational.freezed.dart';
part 'educational.g.dart';

@freezed
abstract class EducationalPage with _$EducationalPage {
  const factory EducationalPage({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'slug') required String slug,
    @JsonKey(name: 'content') required String content,
    @JsonKey(name: 'summary') String? summary,
    @JsonKey(name: 'category') String? category,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _EducationalPage;

  factory EducationalPage.fromJson(Map<String, dynamic> json) => _$EducationalPageFromJson(json);
}

@freezed
abstract class Recommendation with _$Recommendation {
  const factory Recommendation({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'page') required EducationalPage page,
    @JsonKey(name: 'reason') required String reason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Recommendation;

  factory Recommendation.fromJson(Map<String, dynamic> json) => _$RecommendationFromJson(json);
}
