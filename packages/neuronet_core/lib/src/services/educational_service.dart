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
      final list = response.data as List<dynamic>;
      final recs = list
          .map((json) => Recommendation.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(recs);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
EducationalService educationalService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return EducationalService(client);
}
