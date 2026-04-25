import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'guardian_approval_service.g.dart';

class GuardianApprovalService {
  GuardianApprovalService(this._client);
  final ApiClient _client;

  /// Request guardian approval for counselor communication
  Future<Result<ApprovalRequestResult>> requestCommunicationApproval(
    ApprovalRequest request,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.requestCommunicationApproval,
        data: request.toJson(),
      );
      final result = ApprovalRequestResult.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(result);
    } catch (e) {
      debugPrint('[GuardianApprovalService] requestCommunicationApproval ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Respond to an approval request (guardian only)
  Future<Result<Map<String, dynamic>>> respondToApproval(
    String approvalId,
    ApprovalResponse response,
  ) async {
    try {
      final apiResponse = await _client.post(
        ApiEndpoints.respondToApproval(approvalId),
        data: response.toJson(),
      );
      return Result.success(apiResponse.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[GuardianApprovalService] respondToApproval ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Get pending approval requests (guardian only)
  Future<Result<List<GuardianApproval>>> getPendingApprovals() async {
    try {
      final response = await _client.get(ApiEndpoints.pendingApprovals);
      final list = response.data as List<dynamic>;
      final approvals = list
          .map((json) => GuardianApproval.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(approvals);
    } catch (e) {
      debugPrint('[GuardianApprovalService] getPendingApprovals ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Get approval history (guardian only)
  Future<Result<List<GuardianApproval>>> getApprovalHistory() async {
    try {
      final response = await _client.get(ApiEndpoints.approvalHistory);
      final list = response.data as List<dynamic>;
      final approvals = list
          .map((json) => GuardianApproval.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(approvals);
    } catch (e) {
      debugPrint('[GuardianApprovalService] getApprovalHistory ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Check if counselor has approval to communicate with adolescent
  Future<Result<ApprovalStatus>> checkApprovalStatus(
    String adolescentId,
    String counselorEmail,
  ) async {
    try {
      final response = await _client.get(
        ApiEndpoints.checkApprovalStatus(adolescentId, counselorEmail),
      );
      final status = ApprovalStatus.fromJson(
        response.data as Map<String, dynamic>,
      );
      return Result.success(status);
    } catch (e) {
      debugPrint('[GuardianApprovalService] checkApprovalStatus ERROR: $e');
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
GuardianApprovalService guardianApprovalService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return GuardianApprovalService(client);
}