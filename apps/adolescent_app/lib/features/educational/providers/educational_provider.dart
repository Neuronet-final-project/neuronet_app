import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/providers/profile_provider.dart';

part 'educational_provider.g.dart';

@riverpod
Future<List<EducationalPage>> educationalPages(Ref ref) async {
  final service = ref.watch(educationalServiceProvider);
  final result = await service.listPages();
  return result.when(
    success: (value) => value,
    failure: (f) => throw Exception(f.message),
  );
}

@riverpod
Future<EducationalPage> educationalPage(Ref ref, String slug) async {
  final service = ref.watch(educationalServiceProvider);
  final result = await service.getPage(slug);
  return result.when(
    success: (value) => value,
    failure: (f) => throw Exception(f.message),
  );
}

@riverpod
Future<List<Recommendation>> adolescentRecommendations(Ref ref) async {
  final profile = await ref.watch(adolescentProfileControllerProvider.future);
  final service = ref.watch(educationalServiceProvider);

  // Guard: backend requires a real adolescent ID — there is no 'me' variant.
  // If the profile has no real ID yet, return empty to avoid a 404.
  final id = profile.id;
  if (id.isEmpty || id == 'fallback') return [];

  final result = await service.getRecommendations(id);
  if (result.isFailure) {
    return [];
  }
  return result.value;
}
