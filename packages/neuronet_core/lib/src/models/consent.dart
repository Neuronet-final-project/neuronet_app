import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'consent.freezed.dart';
part 'consent.g.dart';

@freezed
class Consent with _$Consent {
  const factory Consent({
    required String consentId,
    required String adolescentId,
    required String guardianId,
    required ConsentType consentType,
    required GrantedToRole grantedToRole,
    required ConsentStatus consentStatus,
    required DateTime grantedAt,
    DateTime? revokedAt,
    DateTime? expiryDate,
    String? notes,
  }) = _Consent;

  factory Consent.fromJson(Map<String, dynamic> json) =>
      _$ConsentFromJson(json);
}

@freezed
class UpdateConsentRequest with _$UpdateConsentRequest {
  const factory UpdateConsentRequest({
    required ConsentStatus status,
    String? notes,
  }) = _UpdateConsentRequest;

  factory UpdateConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateConsentRequestFromJson(json);
}
