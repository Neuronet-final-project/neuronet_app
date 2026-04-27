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
    @JsonKey(name: 'tags') @Default([]) List<String> tags,
    @JsonKey(name: 'difficulty_level') String? difficultyLevel,
    @JsonKey(name: 'author_name') String? authorName,
    @JsonKey(name: 'author_bio') String? authorBio,
    @JsonKey(name: 'author_credentials') String? authorCredentials,
    @JsonKey(name: 'featured_image_url') String? featuredImageUrl,
    @JsonKey(name: 'estimated_read_time') @Default(0) int estimatedReadTime,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'follow_count') @Default(0) int followCount,
    @JsonKey(name: 'engagement_score') @Default(0.0) double engagementScore,
    @JsonKey(name: 'is_following') @Default(false) bool isFollowing,
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

    // Parse tags
    final tagsList = json['tags'] as List<dynamic>?;
    final tags = tagsList?.map((e) => e.toString()).toList() ?? <String>[];

    return EducationalPage(
      id: id as String,
      title: json['title'] as String? ?? 'Untitled',
      slug: json['slug'] as String? ?? '',
      content: json['content'] as String? ?? '',
      summary: json['summary'] as String?,
      category: json['category'] as String?,
      tags: tags,
      difficultyLevel: json['difficulty_level'] as String?,
      authorName: json['author_name'] as String?,
      authorBio: json['author_bio'] as String?,
      authorCredentials: json['author_credentials'] as String?,
      featuredImageUrl: json['featured_image_url'] as String?,
      estimatedReadTime: json['estimated_read_time'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      followCount: json['follow_count'] as int? ?? 0,
      engagementScore: (json['engagement_score'] as num?)?.toDouble() ?? 0.0,
      isFollowing: json['is_following'] as bool? ?? false,
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

@freezed
abstract class Category with _$Category {
  const factory Category({
    @JsonKey(name: 'value') required String value,
    @JsonKey(name: 'label') required String label,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'article_count') @Default(0) int articleCount,
    @JsonKey(name: 'follower_count') @Default(0) int followerCount,
    @JsonKey(name: 'is_followed') @Default(false) bool isFollowed,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      value: json['value'] as String? ?? '',
      label: json['label'] as String? ?? '',
      description: json['description'] as String? ?? '',
      articleCount: json['article_count'] as int? ?? 0,
      followerCount: json['follower_count'] as int? ?? 0,
      isFollowed: json['is_followed'] as bool? ?? false,
    );
  }
}
