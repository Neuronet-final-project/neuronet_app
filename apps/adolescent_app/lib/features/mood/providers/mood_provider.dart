import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mood_provider.freezed.dart';
part 'mood_provider.g.dart';

@freezed
abstract class MoodState with _$MoodState {
  const factory MoodState({
    MoodType? selectedMood,
    @Default(3) int intensity,
    @Default('') String notes,
    @Default(false) bool isSubmitting,
    @Default(false) bool showSuccess,
  }) = _MoodState;
}

@riverpod
class MoodController extends _$MoodController {
  @override
  MoodState build() => const MoodState();

  void selectMood(MoodType mood) {
    state = state.copyWith(selectedMood: mood);
  }

  void updateIntensity(double value) {
    state = state.copyWith(intensity: value.toInt());
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<void> submitMood() async {
    if (state.selectedMood == null) return;

    state = state.copyWith(isSubmitting: true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, we would call a repository here
    // For now, we just reset and show success
    state = state.copyWith(
      isSubmitting: false,
      showSuccess: true,
      selectedMood: null,
      intensity: 3,
      notes: '',
    );

    // Hide success after delay
    await Future.delayed(const Duration(seconds: 2));
    if (state.showSuccess) {
      state = state.copyWith(showSuccess: false);
    }
  }

  void reset() {
    state = const MoodState();
  }
}
