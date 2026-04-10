import 'package:neuronet_core/neuronet_core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adolescent_provider.freezed.dart';
part 'adolescent_provider.g.dart';

@freezed
abstract class AdolescentDetailState with _$AdolescentDetailState {
  const factory AdolescentDetailState({
    required AdolescentResponse profile,
    @Default([]) List<Consent> consents,
  }) = _AdolescentDetailState;
}

@riverpod
class AdolescentDetailController extends _$AdolescentDetailController {
  @override
  FutureOr<AdolescentDetailState> build(String adolescentId) async {
    final dashboardService = ref.watch(dashboardServiceProvider);

    debugPrint('[AdolescentDetail] ── Fetching details for adolescent ID: $adolescentId ──');

    // 1. Fetch linked adolescents
    debugPrint('[AdolescentDetail] Step 1: Fetching linked adolescents');
    final linkedResult = await dashboardService.getLinkedAdolescents();
    if (linkedResult.isFailure) {
      debugPrint('[AdolescentDetail] ✗ Failed to fetch linked adolescents: ${linkedResult.failure.message}');
      throw Exception(linkedResult.failure.message);
    }
    final linkedAdolescents = linkedResult.value;
    debugPrint('[AdolescentDetail] ✓ Found ${linkedAdolescents.length} linked adolescent(s)');

    // 2. Find the specific adolescent
    debugPrint('[AdolescentDetail] Step 2: Searching for adolescent with ID: $adolescentId');
    final profile = linkedAdolescents.firstWhere(
      (a) => a.effectiveId == adolescentId,
      orElse: () => throw Exception('Adolescent not found'),
    );
    debugPrint('[AdolescentDetail] ✓ Found: ${profile.fullName} (${profile.email})');

    // 3. Fetch consents for this adolescent
    debugPrint('[AdolescentDetail] Step 3: Fetching consents for ${profile.email}');
    List<Consent> consents = [];
    final consentsResult = await dashboardService.getAdolescentConsents(profile.email);
    if (consentsResult.isSuccess) {
      consents = consentsResult.value;
      debugPrint('[AdolescentDetail] ✓ Fetched ${consents.length} consent(s)');
    } else {
      debugPrint('[AdolescentDetail] ⚠ Consents fetch failed: ${consentsResult.failure.message} (using empty list)');
    }

    debugPrint('[AdolescentDetail] ── Details loaded ──');
    return AdolescentDetailState(
      profile: profile,
      consents: consents,
    );
  }

  Future<void> refresh() async {
    debugPrint('[AdolescentDetail] ── Refreshing ──');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dashboardService = ref.read(dashboardServiceProvider);
      final linkedResult = await dashboardService.getLinkedAdolescents();
      if (linkedResult.isFailure) {
        debugPrint('[AdolescentDetail] ✗ Refresh failed: ${linkedResult.failure.message}');
        throw Exception(linkedResult.failure.message);
      }
      final linkedAdolescents = linkedResult.value;
      final profile = linkedAdolescents.firstWhere(
        (a) => a.effectiveId == adolescentId,
        orElse: () => throw Exception('Adolescent not found'),
      );

      List<Consent> consents = [];
      final consentsResult = await dashboardService.getAdolescentConsents(profile.email);
      if (consentsResult.isSuccess) {
        consents = consentsResult.value;
      }

      debugPrint('[AdolescentDetail] ✓ Refreshed: ${profile.fullName}');
      return AdolescentDetailState(profile: profile, consents: consents);
    });
  }
}

@riverpod
Future<List<AdolescentResponse>> linkedAdolescents(Ref ref) async {
  debugPrint('[LinkedAdolescents] ── Fetching linked adolescents ──');
  final dashboardService = ref.watch(dashboardServiceProvider);
  final result = await dashboardService.getLinkedAdolescents();
  if (result.isSuccess) {
    debugPrint('[LinkedAdolescents] ✓ Found ${result.value.length} linked adolescent(s)');
    for (int i = 0; i < result.value.length; i++) {
      final a = result.value[i];
      debugPrint('[LinkedAdolescents]   [$i] ${a.fullName} | ${a.email} | status: ${a.inferredStatus}');
    }
  } else {
    debugPrint('[LinkedAdolescents] ✗ Failed: ${result.failure.message}');
  }
  return result.value;
}

@riverpod
Future<List<AdolescentResponse>> pendingAdolescents(Ref ref) async {
  debugPrint('[PendingAdolescents] ── Fetching pending adolescents ──');
  final authService = ref.watch(authServiceProvider);
  debugPrint('[PendingAdolescents] Step 1: Calling authService.getPendingAdolescents()');
  final result = await authService.getPendingAdolescents();
  return result.when(
    success: (value) {
      debugPrint('[PendingAdolescents] ✓ Found ${value.length} pending adolescent(s)');
      for (int i = 0; i < value.length; i++) {
        final a = value[i];
        final dateStr = a.createdAt?.toIso8601String().split('T').first ?? 'unknown';
        final relStr = a.relationship?.name ?? 'none';
        debugPrint('[PendingAdolescents]   [$i] ${a.fullName} | ${a.email} | created: $dateStr | relationship: $relStr');
      }
      debugPrint('[PendingAdolescents] ── Pending list loaded ──');
      return value;
    },
    failure: (f) {
      debugPrint('[PendingAdolescents] ✗ Failed: ${f.message}');
      throw Exception(f.message);
    },
  );
}
