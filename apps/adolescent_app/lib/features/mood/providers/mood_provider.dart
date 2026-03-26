import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';

part 'mood_provider.freezed.dart';
part 'mood_provider.g.dart';

@freezed
abstract class MoodState with _$MoodState {
  const MoodState._();
  const factory MoodState({
    @Default(false) bool isSubmitting,
    @Default(false) bool showSuccess,
    MoodType? selectedMood,
    @Default(3) int intensity,
    @Default('') String notes,
    String? error,
  }) = _MoodState;
}

@riverpod
class MoodController extends _$MoodController {
  @override
  MoodState build() => const MoodState();

  void selectMood(MoodType mood) {
    state = state.copyWith(selectedMood: mood);
  }

  void updateIntensity(double intensity) {
    state = state.copyWith(intensity: intensity.toInt());
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void reset() {
    state = const MoodState();
  }

  Future<void> submitMood() async {
    if (state.selectedMood == null) return;

    state = state.copyWith(isSubmitting: true, error: null);

    try {


      // In a real app, this would call a repository
      // final record = MoodRecord(
      //   moodId: DateTime.now().millisecondsSinceEpoch.toString(),
      //   adolescentId: user.userId,
      //   moodType: state.selectedMood!,
      //   intensity: state.intensity,
      //   recordedAt: DateTime.now(),
      //   contextNotes: state.notes,
      // );
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isSubmitting: false,
        showSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }
}
