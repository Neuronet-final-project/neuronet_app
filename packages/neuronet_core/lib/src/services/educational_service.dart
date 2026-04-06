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
    // ignore: avoid_print
    print('📚 EducationalService: Fetching pages from ${ApiEndpoints.educationalPages}');
    try {
      final response = await _client.get(ApiEndpoints.educationalPages);
      // ignore: avoid_print
      print('📚 EducationalService: Raw response type=${response.data.runtimeType}');
      // ignore: avoid_print
      print('📚 EducationalService: Raw data=${response.data}');
      final list = response.data as List<dynamic>;
      final pages = list.map((json) => EducationalPage.fromJson(json as Map<String, dynamic>)).toList();
      // ignore: avoid_print
      print('📚 EducationalService: Parsed ${pages.length} pages successfully');
      return pages;
    } catch (e, st) {
      // ignore: avoid_print
      print('📚 EducationalService ERROR in listPages: $e');
      // ignore: avoid_print
      print('📚 EducationalService STACK: $st');
      rethrow;
    }
  }

  /// Gets a specific educational page by its slug.
  Future<EducationalPage> getPage(String slug) async {
    // ignore: avoid_print
    print('📚 EducationalService: Fetching page for slug="$slug"');
    try {
      final response = await _client.get(ApiEndpoints.educationalPageBySlug(slug));
      // ignore: avoid_print
      print('📚 EducationalService: Raw page data=${response.data}');
      final page = EducationalPage.fromJson(response.data as Map<String, dynamic>);
      // ignore: avoid_print
      print('📚 EducationalService: Parsed page id=${page.id} title="${page.title}"');
      return page;
    } catch (e, st) {
      // ignore: avoid_print
      print('📚 EducationalService ERROR in getPage(slug=$slug): $e');
      // ignore: avoid_print
      print('📚 EducationalService STACK: $st');
      rethrow;
    }
  }

  /// Gets personalized recommendations for an adolescent.
  Future<List<Recommendation>> getRecommendations(String adolescentId) async {
    final url = ApiEndpoints.educationalRecommendations(adolescentId);
    // ignore: avoid_print
    print('📚 EducationalService: Fetching recommendations from $url');
    try {
      final response = await _client.get(url);
      // ignore: avoid_print
      print('📚 EducationalService: Raw recommendations type=${response.data.runtimeType}');
      // ignore: avoid_print
      print('📚 EducationalService: Raw data=${response.data}');
      final list = response.data as List<dynamic>;
      final recs = list.map((json) => Recommendation.fromJson(json as Map<String, dynamic>)).toList();
      // ignore: avoid_print
      print('📚 EducationalService: Parsed ${recs.length} recommendations successfully');
      return recs;
    } catch (e, st) {
      // ignore: avoid_print
      print('📚 EducationalService ERROR in getRecommendations($adolescentId): $e');
      // ignore: avoid_print
      print('📚 EducationalService STACK: $st');
      rethrow;
    }
  }
}

@riverpod
EducationalService educationalService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return EducationalService(client);
}
