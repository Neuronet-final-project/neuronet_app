import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'guardian_approval_provider.freezed.dart';
part 'guardian_approval_provider.g.dart';

@freezed
abstract class GuardianApprovalUIState with _$GuardianApprovalUIState {
  const factory GuardianApprovalUIState({
    @Default([]) List<GuardianApproval> pendingRequests,
    @Default([]) List<GuardianApproval> historyRequests,
    @Default({}) Map<String, bool> approvalCache,
    @Default(false) bool isLoading,
    String? error,
  }) = _GuardianApprovalUIState;
}

/// Controller for managing guardian approval requests
@riverpod
class GuardianApprovalController extends _$GuardianApprovalController {
  @override
  FutureOr<GuardianApprovalUIState> build() async {
    // Adolescents don't need to load pending/history lists
    // They only need to check approval status for specific counselors
    return const GuardianApprovalUIState();
  }

  /// Request approval to communicate with a counselor
  Future<bool> requestApproval({
    required String adolescentId,
    required String counselorEmail,
    required String reason,
  }) async {
    final service = ref.read(guardianApprovalServiceProvider);
    final request = ApprovalRequest(
      adolescentId: adolescentId,
      counselorEmail: counselorEmail,
      requestReason: reason,
    );
    
    final result = await service.requestCommunicationApproval(request);
    
    return result.when(
      success: (requestResult) {
        // Refresh the state
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

  /// Check if approval exists for a specific counselor
  Future<bool> checkApproval(String adolescentId, String counselorEmail) async {
    // Check cache first
    final cacheKey = '$adolescentId:$counselorEmail';
    final currentState = state.value;
    if (currentState != null && currentState.approvalCache.containsKey(cacheKey)) {
      return currentState.approvalCache[cacheKey]!;
    }

    // Fetch from API
    final service = ref.read(guardianApprovalServiceProvider);
    final result = await service.checkApprovalStatus(adolescentId, counselorEmail);
    
    return result.when(
      success: (status) {
        // Update cache
        state.whenData((data) {
          state = AsyncValue.data(
            data.copyWith(
              approvalCache: {...data.approvalCache, cacheKey: status.isApproved},
            ),
          );
        });
        return status.isApproved;
      },
      failure: (_) => false,
    );
  }

  /// Refresh approval data
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Adolescents don't need to refresh pending/history lists
      return const GuardianApprovalUIState();
    });
  }

  /// Get count of pending approvals
  int getPendingCount() {
    return state.value?.pendingRequests.length ?? 0;
  }

  /// Check if can message counselor (has approved status)
  bool canMessageCounselor(String adolescentId, String counselorEmail) {
    final cacheKey = '$adolescentId:$counselorEmail';
    final currentState = state.value;
    if (currentState == null) return false;
    
    return currentState.approvalCache[cacheKey] ?? false;
  }
}

