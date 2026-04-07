import 'package:flutter/foundation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'educational_provider.g.dart';

@Riverpod(keepAlive: true)
EducationalService educationalService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return EducationalService(client);
}

/// Guardian-facing recommendations for a specific adolescent.
/// Returns `List<EducationalPage>` parsed from the guardian endpoint response.
@Riverpod(keepAlive: true)
Future<List<EducationalPage>> guardianRecommendations(
  Ref ref,
  String adolescentId,
) async {
  final service = ref.watch(educationalServiceProvider);
  debugPrint('[GuardianRecommendations] Fetching for adolescent: $adolescentId');
  final result = await service.getGuardianRecommendations(adolescentId);

  return result.when(
    success: (map) {
      debugPrint('[GuardianRecommendations] SUCCESS — keys: ${map.keys.toList()}');
      final rawList = map['recommendations'];
      if (rawList == null || rawList is! List) {
        debugPrint('[GuardianRecommendations] No recommendations list found');
        return [];
      }
      debugPrint('[GuardianRecommendations] ${rawList.length} raw items');

      final pages = <EducationalPage>[];
      for (var i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        debugPrint('[GuardianRecommendations]   [$i] keys: ${item.keys.toList()}');
        try {
          // Normalize: the guardian response uses the same fields as EducationalPage
          // but may have 'updated_at' instead of 'created_at'
          final normalized = Map<String, dynamic>.from(item);
          if (normalized['id'] == null && normalized['_id'] == null) {
            normalized['id'] = 'page-${normalized['slug'] ?? i}';
          }
          if (normalized['created_at'] == null && normalized['updated_at'] != null) {
            normalized['created_at'] = normalized['updated_at'];
          }
          if (normalized['content'] == null) normalized['content'] = '';
          pages.add(EducationalPage.fromJson(normalized));
        } catch (e, st) {
          debugPrint('[GuardianRecommendations]   [$i] parse error: $e');
          debugPrint('[GuardianRecommendations]       stack: $st');
        }
      }

      debugPrint('[GuardianRecommendations] Parsed ${pages.length} EducationalPage objects');
      for (var p in pages) {
        debugPrint('[GuardianRecommendations]   - "${p.title}" (slug: ${p.slug}, category: ${p.category})');
      }
      return pages;
    },
    failure: (f) {
      debugPrint('[GuardianRecommendations] FAILURE: ${f.message}');
      debugPrint('[GuardianRecommendations] Type: ${f.runtimeType}');
      throw Exception('[GuardianRecommendations] ${f.message}');
    },
  );
}
