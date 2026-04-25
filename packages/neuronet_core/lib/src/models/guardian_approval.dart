import 'package:freezed_annotation/freezed_annotation.dart';

part 'guardian_approval.freezed.dart';

@freezed
abstract class GuardianApproval with _$GuardianApproval {
  const factory GuardianApproval({
    @JsonKey(name: 'approval_id') required String approvalId,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'adolescent_name') String? adolescentName,
    @JsonKey(name: 'counselor_email') required String counselorEmail,
    @JsonKey(name: 'counselor_name') String? counselorName,
    @JsonKey(name: 'request_reason') String? requestReason,
    @JsonKey(name: 'requested_by') String? requestedBy,
    @JsonKey(name: 'requested_by_role') String? requestedByRole,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'responded_by') String? respondedBy,
    @JsonKey(name: 'response_reason') String? responseReason,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'responded_at') DateTime? respondedAt,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
  }) = _GuardianApproval;

  factory GuardianApproval.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['created_at'];
    final createdAt = createdAtStr != null 
        ? DateTime.parse(createdAtStr as String) 
        : DateTime.now();

    DateTime? respondedAt;
    if (json['responded_at'] != null) {
      respondedAt = DateTime.parse(json['responded_at'] as String);
    }

    DateTime? expiresAt;
    if (json['expires_at'] != null) {
      expiresAt = DateTime.parse(json['expires_at'] as String);
    }

    return GuardianApproval(
      approvalId: json['approval_id'] as String? ?? '',
      adolescentId: json['adolescent_id'] as String? ?? '',
      adolescentName: json['adolescent_name'] as String?,
      counselorEmail: json['counselor_email'] as String? ?? '',
      counselorName: json['counselor_name'] as String?,
      requestReason: json['request_reason'] as String?,
      requestedBy: json['requested_by'] as String?,
      requestedByRole: json['requested_by_role'] as String?,
      status: json['status'] as String? ?? 'pending',
      respondedBy: json['responded_by'] as String?,
      responseReason: json['response_reason'] as String?,
      createdAt: createdAt,
      respondedAt: respondedAt,
      expiresAt: expiresAt,
    );
  }
}

@freezed
abstract class ApprovalRequest with _$ApprovalRequest {
  const factory ApprovalRequest({
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'counselor_email') required String counselorEmail,
    @JsonKey(name: 'request_reason') required String requestReason,
  }) = _ApprovalRequest;

  const ApprovalRequest._();

  Map<String, dynamic> toJson() => {
    'adolescent_id': adolescentId,
    'counselor_email': counselorEmail,
    'request_reason': requestReason,
  };
}

@freezed
abstract class ApprovalResponse with _$ApprovalResponse {
  const factory ApprovalResponse({
    @JsonKey(name: 'response') required String response, // "approved" or "denied"
    @JsonKey(name: 'response_reason') String? responseReason,
  }) = _ApprovalResponse;

  const ApprovalResponse._();

  Map<String, dynamic> toJson() => {
    'response': response,
    if (responseReason != null) 'response_reason': responseReason,
  };
}

@freezed
abstract class ApprovalRequestResult with _$ApprovalRequestResult {
  const factory ApprovalRequestResult({
    @JsonKey(name: 'approval_id') required String approvalId,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'guardian_emails') required List<String> guardianEmails,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'message') required String message,
  }) = _ApprovalRequestResult;

  factory ApprovalRequestResult.fromJson(Map<String, dynamic> json) {
    DateTime? expiresAt;
    if (json['expires_at'] != null) {
      expiresAt = DateTime.parse(json['expires_at'] as String);
    }

    final guardianEmailsJson = json['guardian_emails'] as List<dynamic>? ?? [];
    final guardianEmails = guardianEmailsJson.cast<String>();

    return ApprovalRequestResult(
      approvalId: json['approval_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      guardianEmails: guardianEmails,
      expiresAt: expiresAt,
      message: json['message'] as String? ?? '',
    );
  }
}

@freezed
abstract class ApprovalStatus with _$ApprovalStatus {
  const factory ApprovalStatus({
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'counselor_email') required String counselorEmail,
    @JsonKey(name: 'is_approved') required bool isApproved,
  }) = _ApprovalStatus;

  factory ApprovalStatus.fromJson(Map<String, dynamic> json) {
    return ApprovalStatus(
      adolescentId: json['adolescent_id'] as String? ?? '',
      counselorEmail: json['counselor_email'] as String? ?? '',
      isApproved: json['is_approved'] as bool? ?? false,
    );
  }
}