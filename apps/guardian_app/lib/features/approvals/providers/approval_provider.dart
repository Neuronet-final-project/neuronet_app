import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'approval_provider.freezed.dart';
part 'approval_provider.g.dart';

@freezed
abstract class GuardianApprovalUIState with _$GuardianApprovalUIState {
  const factory GuardianApprovalUIState({
    @Default([]) List<GuardianApproval> pendingApprovals,
    @Default([]) List<GuardianApproval> historyApprovals,
    @Default(false) bool isLoading,
    String? error,
  }) = _GuardianApprovalUIState;
}

@riverpod
class GuardianApprovalController extends _$GuardianApprovalController {
  @override
  FutureOr<GuardianApprovalUIState> build() async {
    final service = ref.watch(guardianApprovalServiceProvider);
    
    final pendingResult = await service.getPendingApprovals();
    final historyResult = await service.getApprovalHistory();
    
    final pending = pendingResult.when(
      success: (approvals) => approvals,
      failure: (_) => <GuardianApproval>[],
    );
    
    final history = historyResult.when(
      success: (approvals) => approvals,
      failure: (_) => <GuardianApproval>[],
    );
    
    return GuardianApprovalUIState(
      pendingApprovals: pending,
      historyApprovals: history,
    );
  }

  Future<bool> respondToApproval(String approvalId, bool approved, String? reason) async {
    final service = ref.read(guardianApprovalServiceProvider);
    final response = ApprovalResponse(
      response: approved ? 'approved' : 'denied',
      responseReason: reason,
    );
    
    final result = await service.respondToApproval(approvalId, response);
    
    return result.when(
      success: (_) {
        ref.invalidateSelf();
        return true;
      },
      failure: (f) {
        state.whenData((data) {
          state = AsyncValue.data(data.copyWith(error: f.message));
        });
        return false;
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(guardianApprovalServiceProvider);
      
      final pendingResult = await service.getPendingApprovals();
      final historyResult = await service.getApprovalHistory();
      
      final pending = pendingResult.when(
        success: (approvals) => approvals,
        failure: (_) => <GuardianApproval>[],
      );
      
      final history = historyResult.when(
        success: (approvals) => approvals,
        failure: (_) => <GuardianApproval>[],
      );
      
      return GuardianApprovalUIState(
        pendingApprovals: pending,
        historyApprovals: history,
      );
    });
  }
}
