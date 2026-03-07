import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String userId,
    required String fullName,
    required String email,
    required UserRole role,
    required AccountStatus accountStatus,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String token,
    required String refreshToken,
    required UserRole role,
    required int expiresIn,
    required User user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class ActivateAccountRequest with _$ActivateAccountRequest {
  const factory ActivateAccountRequest({
    required String activationCode,
    required String password,
    required String confirmPassword,
  }) = _ActivateAccountRequest;

  factory ActivateAccountRequest.fromJson(Map<String, dynamic> json) =>
      _$ActivateAccountRequestFromJson(json);
}
