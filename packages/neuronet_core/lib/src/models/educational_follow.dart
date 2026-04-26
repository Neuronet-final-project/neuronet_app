import 'package:freezed_annotation/freezed_annotation.dart';

part 'educational_follow.freezed.dart';

@freezed
abstract class EducationalPageFollow with _$EducationalPageFollow {
  const factory EducationalPageFollow({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'page_slug') required String pageSlug,
    @JsonKey(name: 'page_title') required String pageTitle,
    @JsonKey(name: 'page_category') String? pageCategory,
    @JsonKey(name: 'followed_at') required DateTime followedAt,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _EducationalPageFollow;

  factory EducationalPageFollow.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? json['id'] ?? 'none';
    final followedAtStr = json['followed_at'] ?? json['created_at'];
    final followedAt = followedAtStr != null 
        ? DateTime.parse(followedAtStr as String) 
        : DateTime.now();

    return EducationalPageFollow(
      id: id as String,
      adolescentId: json['adolescent_id'] as String? ?? '',
      pageSlug: json['page_slug'] as String? ?? '',
      pageTitle: json['page_title'] as String? ?? '',
      pageCategory: json['page_category'] as String?,
      followedAt: followedAt,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

@freezed
abstract class EducationalPageWithFollowStatus with _$EducationalPageWithFollowStatus {
  const factory EducationalPageWithFollowStatus({
    @JsonKey(name: 'slug') required String slug,
    @JsonKey(name: 'title') required String title,
    @JsonKey(name: 'content') required String content,
    @JsonKey(name: 'category') String? category,
    @JsonKey(name: 'counselor_name') String? counselorName,
    @JsonKey(name: 'popularity_score') @Default(0) int popularityScore,
    @JsonKey(name: 'is_followed') @Default(false) bool isFollowed,
    @JsonKey(name: 'follow_count') @Default(0) int followCount,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _EducationalPageWithFollowStatus;

  factory EducationalPageWithFollowStatus.fromJson(Map<String, dynamic> json) {
    final updatedAtStr = json['updated_at'] ?? json['created_at'];
    final updatedAt = updatedAtStr != null 
        ? DateTime.parse(updatedAtStr as String) 
        : DateTime.now();

    return EducationalPageWithFollowStatus(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] as String?,
      counselorName: json['counselor_name'] as String?,
      popularityScore: json['popularity_score'] as int? ?? 0,
      isFollowed: json['is_followed'] as bool? ?? false,
      followCount: json['follow_count'] as int? ?? 0,
      updatedAt: updatedAt,
    );
  }
}

@freezed
abstract class FollowedPageSummary with _$FollowedPageSummary {
  const factory FollowedPageSummary({
    @JsonKey(name: 'page_slug') required String pageSlug,
    @JsonKey(name: 'page_title') required String pageTitle,
    @JsonKey(name: 'page_category') String? pageCategory,
    @JsonKey(name: 'counselor_name') String? counselorName,
    @JsonKey(name: 'followed_at') required DateTime followedAt,
  }) = _FollowedPageSummary;

  factory FollowedPageSummary.fromJson(Map<String, dynamic> json) {
    final followedAtStr = json['followed_at'] ?? json['created_at'];
    final followedAt = followedAtStr != null 
        ? DateTime.parse(followedAtStr as String) 
        : DateTime.now();

    return FollowedPageSummary(
      pageSlug: json['page_slug'] as String? ?? '',
      pageTitle: json['page_title'] as String? ?? '',
      pageCategory: json['page_category'] as String?,
      counselorName: json['counselor_name'] as String?,
      followedAt: followedAt,
    );
  }
}