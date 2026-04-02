import 'package:neuronet_core/neuronet_core.dart';
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
      (a) => a.id == adolescentId,
      orElse: () => throw Exception('Adolescent not found'),
    );
    
    // 3. Fetch consents for this adolescent
    final consents = await dashboardService.getAdolescentConsents(profile.email);
    
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
        (a) => a.id == adolescentId,
        orElse: () => throw Exception('Adolescent not found'),
      );
      final consents = await dashboardService.getAdolescentConsents(profile.email);
      return AdolescentDetailState(profile: profile, consents: consents);
    });
  }
}
