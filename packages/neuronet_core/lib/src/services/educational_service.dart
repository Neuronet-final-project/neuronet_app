import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'educational_service.g.dart';

class EducationalService {
  EducationalService(this._client);
  final ApiClient _client;

  /// Lists all educational pages.
  Future<Result<List<EducationalPage>>> listPages() async {
    try {
      final response = await _client.get(ApiEndpoints.educationalPages);
      final list = response.data as List<dynamic>;
      final pages = list
          .map((json) => EducationalPage.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(pages);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Gets a specific educational page by its slug.
  Future<Result<EducationalPage>> getPage(String slug) async {
    try {
      final response = await _client.get(
        ApiEndpoints.educationalPageBySlug(slug),
      );
      final page = EducationalPage.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(page);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Gets personalized recommendations for an adolescent.
  Future<Result<List<Recommendation>>> getRecommendations(
    String adolescentId,
  ) async {
    try {
      final response = await _client.get(
        ApiEndpoints.educationalRecommendations(adolescentId),
      );
      final mapData = response.data as Map<String, dynamic>;
      final list = mapData['recommendations'] as List<dynamic>? ?? [];
      final recs = list
          .map((json) {
            final pageMap = json as Map<String, dynamic>;
            final id = pageMap['_id'] ?? pageMap['id'] ?? 'none';
            return Recommendation(
              id: id as String,
              adolescentId: adolescentId,
              page: EducationalPage.fromJson(pageMap),
              reason: 'Recommended based on your recent check-ins',
              createdAt: DateTime.now(),
            );
          })
          .toList();
      return Result.success(recs);
    } catch (e, st) {
      debugPrint('[EducationalService] getRecommendations ERROR: $e');
      debugPrint('[EducationalService] Stack: $st');
      return Result.failure(failureFromException(e));
    }
  }

  /// Gets educational recommendations for a guardian's linked adolescent.
  ///
  /// Returns a wrapped object containing `adolescent_id`, `risk_level`,
  /// and a list of `EducationalPage` recommendations.
  Future<Result<Map<String, dynamic>>> getGuardianRecommendations(
    String adolescentId,
  ) async {
    try {
      final response = await _client.get(
        ApiEndpoints.guardianEducationalRecommendations(adolescentId),
      );
      final raw = response.data;
      debugPrint('[EducationalService] Raw response type: ${raw.runtimeType}');
      debugPrint('[EducationalService] Raw response: $raw');
      final map = raw as Map<String, dynamic>;
      debugPrint('[EducationalService] Keys: ${map.keys.toList()}');
      return Result.success(map);
    } catch (e, st) {
      debugPrint('[EducationalService] getGuardianRecommendations ERROR: $e');
      debugPrint('[EducationalService] Stack: $st');
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
EducationalService educationalService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return EducationalService(client);
}
