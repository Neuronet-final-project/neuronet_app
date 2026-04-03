import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../profile/providers/profile_provider.dart';

part 'alerts_provider.g.dart';

@riverpod
Future<List<Alert>> adolescentAlerts(Ref ref) async {
  final profile = await ref.watch(adolescentProfileControllerProvider.future);
  final alertService = ref.watch(alertServiceProvider);
  
  // Use the real ID from the profile if it's not the fallback
  // The backend endpoint might support 'me' or require the actual ID
  final id = profile.id == 'fallback' ? 'me' : profile.id;
  
  try {
    return await alertService.getAdolescentAlerts(id);
  } catch (e) {
    // Return empty list on failure for dashboard resiliency
    return [];
  }
}
