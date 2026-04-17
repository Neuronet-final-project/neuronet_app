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
      final service = ref.read(journalServiceProvider);

      final request = CreateMoodRequest(
        mood: state.selectedMood!,
        intensity: state.intensity,
        note: state.notes,
      );

      await service.recordMood(request);

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

@freezed
abstract class MoodHistoryState with _$MoodHistoryState {
  const factory MoodHistoryState({
    @Default([]) List<MoodRecord> records,
    @Default(false) bool isLoading,
    String? error,
  }) = _MoodHistoryState;
}

@riverpod
class MoodHistoryController extends _$MoodHistoryController {
  @override
  FutureOr<MoodHistoryState> build() async {
    final service = ref.read(journalServiceProvider);
    final result = await service.getMyMoods();
    
    return result.when(
      success: (value) => MoodHistoryState(records: value, isLoading: false),
      failure: (f) => MoodHistoryState(isLoading: false, error: f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(journalServiceProvider);
      final result = await service.getMyMoods();
      return result.when(
        success: (value) => MoodHistoryState(records: value, isLoading: false),
        failure: (f) => MoodHistoryState(isLoading: false, error: f.message),
      );
    });
  }
}
