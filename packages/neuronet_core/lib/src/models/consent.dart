import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'consent.freezed.dart';
part 'consent.g.dart';

@freezed
abstract class Consent with _$Consent {
  const factory Consent({
    @JsonKey(name: '_id') required String consentId,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'guardian_id') required String guardianId,
    @JsonKey(name: 'consent_type') required ConsentType consentType,
    @JsonKey(name: 'granted_to_role') required GrantedToRole grantedToRole,
    @JsonKey(name: 'consent_status') required ConsentStatus consentStatus,
    @JsonKey(name: 'granted_at') required DateTime grantedAt,
    @JsonKey(name: 'revoked_at') DateTime? revokedAt,
    @JsonKey(name: 'expiry_date') DateTime? expiryDate,
    String? notes,
  }) = _Consent;

  factory Consent.fromJson(Map<String, dynamic> json) =>
      _$ConsentFromJson(json);
}

@freezed
abstract class UpdateConsentRequest with _$UpdateConsentRequest {
  const factory UpdateConsentRequest({
    required ConsentStatus status,
    String? notes,
  }) = _UpdateConsentRequest;

  factory UpdateConsentRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateConsentRequestFromJson(json);
}
