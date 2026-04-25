import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'educational_follow_service.g.dart';

class EducationalFollowService {
  EducationalFollowService(this._client);
  final ApiClient _client;

  /// Follow an educational page by slug
  Future<Result<EducationalPageFollow>> followPage(String pageSlug) async {
    try {
      final response = await _client.post(
        ApiEndpoints.followEducationalPage(pageSlug),
        data: {},
      );
      final follow = EducationalPageFollow.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(follow);
    } catch (e) {
      debugPrint('[EducationalFollowService] followPage ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Unfollow an educational page by slug
  Future<Result<void>> unfollowPage(String pageSlug) async {
    try {
      await _client.delete(ApiEndpoints.unfollowEducationalPage(pageSlug));
      return const Result.success(null);
    } catch (e) {
      debugPrint('[EducationalFollowService] unfollowPage ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Get all pages followed by the current adolescent
  Future<Result<List<FollowedPageSummary>>> getMyFollowedPages() async {
    try {
      final response = await _client.get(ApiEndpoints.myFollowedPages);
      final list = response.data as List<dynamic>;
      final followedPages = list
          .map((json) => FollowedPageSummary.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(followedPages);
    } catch (e) {
      debugPrint('[EducationalFollowService] getMyFollowedPages ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Discover educational pages with follow status and popularity
  Future<Result<List<EducationalPageWithFollowStatus>>> discoverPages({
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _client.get(
        ApiEndpoints.discoverEducationalPages,
        queryParameters: queryParams,
      );
      final list = response.data as List<dynamic>;
      final pages = list
          .map((json) => EducationalPageWithFollowStatus.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(pages);
    } catch (e) {
      debugPrint('[EducationalFollowService] discoverPages ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Check if a specific page is followed by the current adolescent
  Future<Result<bool>> isPageFollowed(String pageSlug) async {
    try {
      final response = await _client.get(ApiEndpoints.isPageFollowed(pageSlug));
      final data = response.data as Map<String, dynamic>;
      final isFollowed = data['is_followed'] as bool? ?? false;
      return Result.success(isFollowed);
    } catch (e) {
      debugPrint('[EducationalFollowService] isPageFollowed ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Get the follow count for a specific page
  Future<Result<int>> getPageFollowCount(String pageSlug) async {
    try {
      final response = await _client.get(ApiEndpoints.pageFollowCount(pageSlug));
      final data = response.data as Map<String, dynamic>;
      final followCount = data['follow_count'] as int? ?? 0;
      return Result.success(followCount);
    } catch (e) {
      debugPrint('[EducationalFollowService] getPageFollowCount ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
EducationalFollowService educationalFollowService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return EducationalFollowService(client);
}