import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/providers/profile_provider.dart';

part 'alerts_provider.g.dart';

@riverpod
Future<List<Alert>> adolescentAlerts(Ref ref) async {
  final profile = await ref.watch(adolescentProfileControllerProvider.future);
  final alertService = ref.watch(alertServiceProvider);

  // Guard: the backend has no generic 'me' endpoint for adolescent alerts.
  // If the profile has no real ID yet, skip the request entirely.
  final id = profile.id;
  if (id.isEmpty || id == 'fallback') return [];

  final result = await alertService.getAdolescentAlerts(id);
  if (result.isFailure) {
    return [];
  }
  return result.value;
}
