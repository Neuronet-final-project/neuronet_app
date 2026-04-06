import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/providers/profile_provider.dart';

part 'educational_provider.g.dart';

@riverpod
Future<List<EducationalPage>> educationalPages(Ref ref) async {
  final service = ref.watch(educationalServiceProvider);
  return service.listPages();
}

@riverpod
Future<EducationalPage> educationalPage(Ref ref, String slug) async {
  final service = ref.watch(educationalServiceProvider);
  return service.getPage(slug);
}

@riverpod
Future<List<Recommendation>> adolescentRecommendations(Ref ref) async {
  final profile = await ref.watch(adolescentProfileControllerProvider.future);
  final service = ref.watch(educationalServiceProvider);
  
  // Guard: backend requires a real adolescent ID — there is no 'me' variant.
  // If the profile has no real ID yet, return empty to avoid a 404.
  final id = profile.id;
  if (id.isEmpty || id == 'fallback') return [];

  try {
    return await service.getRecommendations(id);
  } catch (e) {
    return [];
  }
}
