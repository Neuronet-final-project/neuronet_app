import 'package:neuronet_core/neuronet_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    
    // 1. Fetch linked adolescents
    final linkedAdolescents = await dashboardService.getLinkedAdolescents();
    
    // 2. Find the specific adolescent
    final profile = linkedAdolescents.firstWhere(
      (a) => a.effectiveId == adolescentId,
      orElse: () => throw Exception('Adolescent not found'),
    );
    
    // 3. Fetch consents for this adolescent (Gracefully handle 404/Not Found)
    List<Consent> consents = [];
    try {
      consents = await dashboardService.getAdolescentConsents(profile.email);
    } catch (e) {
      // Log for debugging if needed, but don't fail the entire build
      debugPrint('AdolescentDetailController: No consents found or error fetching for ${profile.email}: $e');
    }
    
    return AdolescentDetailState(
      profile: profile,
      consents: consents,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dashboardService = ref.read(dashboardServiceProvider);
      final linkedAdolescents = await dashboardService.getLinkedAdolescents();
      final profile = linkedAdolescents.firstWhere(
        (a) => a.effectiveId == adolescentId,
        orElse: () => throw Exception('Adolescent not found'),
      );
      
      List<Consent> consents = [];
      try {
        consents = await dashboardService.getAdolescentConsents(profile.email);
      } catch (e) {
        debugPrint('AdolescentDetailController refresh: No consents found or error: $e');
      }
      
      return AdolescentDetailState(profile: profile, consents: consents);
    });
  }
}
@riverpod
Future<List<AdolescentResponse>> linkedAdolescents(Ref ref) async {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getLinkedAdolescents();
}
