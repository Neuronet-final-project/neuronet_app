import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
abstract class User with _$User {
  const factory User({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    required UserRole role,
    @JsonKey(name: 'account_status') required AccountStatus accountStatus,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    required UserRole role,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
abstract class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
abstract class ActivateAccountRequest with _$ActivateAccountRequest {
  const factory ActivateAccountRequest({
    required String email,
    @JsonKey(name: 'activation_token') required String activationToken,
    required String password,
  }) = _ActivateAccountRequest;

  factory ActivateAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$ActivateAccountRequestFromJson(json);
}

@freezed
abstract class GuardianRegisterRequest with _$GuardianRegisterRequest {
  const factory GuardianRegisterRequest({
    @JsonKey(name: 'full_name') required String fullName,
    required String email,
    required String password,
    @Default(UserRole.guardian) UserRole role,
  }) = _GuardianRegisterRequest;

  factory GuardianRegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$GuardianRegisterRequestFromJson(json);
}

@freezed
abstract class AdolescentCreateRequest with _$AdolescentCreateRequest {
  const factory AdolescentCreateRequest({
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'date_of_birth') required DateTime dateOfBirth,
    required RelationshipType relationship,
    required List<ConsentType> consents,
  }) = _AdolescentCreateRequest;

  factory AdolescentCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$AdolescentCreateRequestFromJson(json);
}

@freezed
abstract class AdolescentResponse with _$AdolescentResponse {
  const factory AdolescentResponse({
    required String email,
    @JsonKey(name: 'full_name') required String fullName,
    @JsonKey(name: 'account_status') required AccountStatus accountStatus,
    required UserRole role,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _AdolescentResponse;

  factory AdolescentResponse.fromJson(Map<String, dynamic> json) =>
      _$AdolescentResponseFromJson(json);
}
