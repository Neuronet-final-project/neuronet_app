import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'educational_service.g.dart';

class EducationalService {
  EducationalService(this._client);
  final ApiClient _client;

  /// Lists all educational pages.
  Future<List<EducationalPage>> listPages() async {
    final response = await _client.get(ApiEndpoints.educationalPages);
    final list = response.data as List<dynamic>;
    return list.map((json) => EducationalPage.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Gets a specific educational page by its slug.
  Future<EducationalPage> getPage(String slug) async {
    final response = await _client.get(ApiEndpoints.educationalPageBySlug(slug));
    return EducationalPage.fromJson(response.data as Map<String, dynamic>);
  }

  /// Gets personalized recommendations for an adolescent.
  Future<List<Recommendation>> getRecommendations(String adolescentId) async {
    final response = await _client.get(ApiEndpoints.educationalRecommendations(adolescentId));
    final list = response.data as List<dynamic>;
    return list.map((json) => Recommendation.fromJson(json as Map<String, dynamic>)).toList();
  }
}

@riverpod
EducationalService educationalService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return EducationalService(client);
}
