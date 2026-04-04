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
      state = state.copyWith(error: 'Please fill in all required fields');
      return;
    }
    if (!emailRegex.hasMatch(state.email)) {
      state = state.copyWith(error: 'Please enter a valid email address');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final authService = ref.read(authServiceProvider);
      
      final token = await authService.createAdolescent(
        AdolescentCreateRequest(
          fullName: state.name,
          email: state.email,
          dateOfBirth: state.dateOfBirth!,
          relationship: state.relationship,
          consents: state.consents.toList(),
        ),
      );

      state = state.copyWith(isLoading: false, activationCode: token);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to register adolescent. ${e.toString()}');
    }
  }

  void reset() {
    state = build();
  }
}
