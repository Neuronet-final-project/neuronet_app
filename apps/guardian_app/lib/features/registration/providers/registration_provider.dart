import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'registration_provider.freezed.dart';
part 'registration_provider.g.dart';

@freezed
abstract class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default('') String name,
    DateTime? dateOfBirth,
    @Default('') String email,
    @Default(RelationshipType.parent) RelationshipType relationship,
    @Default({}) Set<ConsentType> consents,
    @Default(false) bool isLoading,
    String? activationCode,
    String? error,
  }) = _RegistrationState;
}

@riverpod
class RegistrationController extends _$RegistrationController {
  @override
  RegistrationState build() {
    return const RegistrationState(
      consents: {
        ConsentType.shareAiSummaries,
        ConsentType.shareAlerts,
      },
    );
  }

  void updateName(String name) => state = state.copyWith(name: name, error: null);
  void updateEmail(String email) => state = state.copyWith(email: email, error: null);
  void updateDOB(DateTime dob) => state = state.copyWith(dateOfBirth: dob, error: null);
  void updateRelationship(RelationshipType type) => state = state.copyWith(relationship: type);
  
  void toggleConsent(ConsentType type) {
    final newConsents = Set<ConsentType>.from(state.consents);
    if (newConsents.contains(type)) {
      newConsents.remove(type);
    } else {
      newConsents.add(type);
    }
    state = state.copyWith(consents: newConsents);
  }

  Future<void> submit() async {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (state.name.isEmpty || state.email.isEmpty || state.dateOfBirth == null) {
      state = state.copyWith(error: 'pleaseFillRequiredFields');
      return;
    }
    if (!emailRegex.hasMatch(state.email)) {
      state = state.copyWith(error: 'pleaseEnterValidEmail');
      return;
    }
    if (RegExp(r'[0-9]').hasMatch(state.name)) {
      state = state.copyWith(error: 'nameCannotContainNumbers');
      return;
    }
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(state.name)) {
      state = state.copyWith(error: 'nameCannotContainSpecialCharacters');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);

      final result = await authService.createAdolescent(
        AdolescentCreateRequest(
          fullName: state.name,
          email: state.email,
          dateOfBirth: state.dateOfBirth!,
          relationship: state.relationship,
          consents: state.consents.toList(),
        ),
      );

      if (result.isFailure) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure.message,
        );
        return;
      }

      state = state.copyWith(isLoading: false, activationCode: result.value);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'failedToRegisterAdolescent|${e.toString()}');
    }
  }

  void reset() {
    state = build();
  }
}
