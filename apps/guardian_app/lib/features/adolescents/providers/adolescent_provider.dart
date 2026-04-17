import 'package:neuronet_core/neuronet_core.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'adolescent_provider.freezed.dart';
part 'adolescent_provider.g.dart';

@freezed
abstract class AdolescentDetailState with _$AdolescentDetailState {
  const factory AdolescentDetailState({
    AdolescentResponse? profile,
    @Default([]) List<Consent> consents,
    @Default(false) bool isLoading,
    String? error,
  }) = _AdolescentDetailState;
}

@riverpod
class AdolescentDetailController extends _$AdolescentDetailController {
  @override
  FutureOr<AdolescentDetailState> build(String adolescentId) async {
    final dashboardService = ref.watch(dashboardServiceProvider);

    final linkedResult = await dashboardService.getLinkedAdolescents();
    if (linkedResult.isFailure) {
      return AdolescentDetailState(isLoading: false, error: linkedResult.failure.message);
    }

    final linkedAdolescents = linkedResult.value;
    final profile = linkedAdolescents.cast<AdolescentResponse?>().firstWhere(
      (a) => a?.effectiveId == adolescentId,
      orElse: () => null,
    );

    if (profile == null) {
      return const AdolescentDetailState(isLoading: false, error: 'Adolescent not found');
    }

    List<Consent> consents = [];
    final consentsResult = await dashboardService.getAdolescentConsents(profile.email);
    if (consentsResult.isSuccess) {
      consents = consentsResult.value;
    }

    return AdolescentDetailState(
      profile: profile,
      consents: consents,
      isLoading: false,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dashboardService = ref.read(dashboardServiceProvider);
      final linkedResult = await dashboardService.getLinkedAdolescents();
      
      if (linkedResult.isFailure) {
        return AdolescentDetailState(isLoading: false, error: linkedResult.failure.message);
      }

      final profile = linkedResult.value.cast<AdolescentResponse?>().firstWhere(
        (a) => a?.effectiveId == adolescentId,
        orElse: () => null,
      );

      if (profile == null) {
        return const AdolescentDetailState(isLoading: false, error: 'Adolescent not found');
      }

      List<Consent> consents = [];
      final consentsResult = await dashboardService.getAdolescentConsents(profile.email);
      if (consentsResult.isSuccess) {
        consents = consentsResult.value;
      }

      return AdolescentDetailState(profile: profile, consents: consents, isLoading: false);
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
    return result.value;
  } else {
    debugPrint('[LinkedAdolescents] ✗ Failed: ${result.failure.message}');
    return []; // Return empty list instead of throwing
  }
}

@riverpod
Future<List<AdolescentResponse>> pendingAdolescents(Ref ref) async {
  debugPrint('[PendingAdolescents] ── Fetching pending/inactive adolescents ──');
  final authService = ref.watch(authServiceProvider);
  final result = await authService.getPendingAdolescents();
  
  return result.when(
    success: (value) {
      final needsActivation = value
          .where((a) => 
            a.accountStatus == AccountStatus.pendingActivation || 
            a.accountStatus == AccountStatus.inactive
          )
          .toList();
      return needsActivation;
    },
    failure: (f) {
      debugPrint('[PendingAdolescents] ✗ Failed: ${f.message}');
      return []; // Return empty list instead of throwing
    },
  );
}
