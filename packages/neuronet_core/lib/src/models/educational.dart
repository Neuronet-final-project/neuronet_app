import 'package:freezed_annotation/freezed_annotation.dart';

part 'educational.freezed.dart';

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

  factory EducationalPage.fromJson(Map<String, dynamic> json) {
    // Normalise ID: check '_id' then 'id', fallback to 'none' if missing
    final id = json['_id'] ?? json['id'] ?? 'none';
    
    // Normalise Timestamp: check 'created_at' then 'updated_at', fallback to now if missing
    final createdAtStr = json['created_at'] ?? json['updated_at'];
    final createdAt = createdAtStr != null 
        ? DateTime.parse(createdAtStr as String) 
        : DateTime.now();

    return EducationalPage(
      id: id as String,
      title: json['title'] as String? ?? 'Untitled',
      slug: json['slug'] as String? ?? '',
      content: json['content'] as String? ?? '',
      summary: json['summary'] as String?,
      category: json['category'] as String?,
      createdAt: createdAt,
    );
  }
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

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? json['id'] ?? 'none';
    final createdAtStr = json['created_at'] ?? json['updated_at'];
    final createdAt = createdAtStr != null 
        ? DateTime.parse(createdAtStr as String) 
        : DateTime.now();

    return Recommendation(
      id: id as String,
      adolescentId: json['adolescent_id'] as String? ?? '',
      page: EducationalPage.fromJson(json['page'] as Map<String, dynamic>),
      reason: json['reason'] as String? ?? '',
      createdAt: createdAt,
    );
  }
}
