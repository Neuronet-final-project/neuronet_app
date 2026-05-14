import 'package:adolescent_app/features/dashboard/providers/dashboard_provider.dart';
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
      
      // Enforce 12-hour gap: Max 2 moods per 12-hour rotating window
      final history = ref.read(moodHistoryControllerProvider);
      if (history.hasValue) {
        final records = history.value!.records;
        if (records.length >= 2) {
          final secondLast = records[1].createdAt.toUtc();
          final now = DateTime.now().toUtc();
          final diff = now.difference(secondLast);
          
          if (diff < const Duration(hours: 12)) {
            final remaining = const Duration(hours: 12) - diff;
            final waitHours = remaining.inHours;
            final waitMins = remaining.inMinutes % 60;
            String waitMsg = waitHours > 0 
                ? '$waitHours hours and $waitMins minutes' 
                : '$waitMins minutes';
                
            throw Exception('You can only log 2 moods every 12 hours. Please wait $waitMsg before logging another.');
          }
        }
      }

      final request = CreateMoodRequest(
        mood: state.selectedMood!,
        intensity: state.intensity,
        note: state.notes,
      );

      final result = await service.recordMood(request);
      if (result.isFailure) {
        throw Exception(result.failure.message);
      }

      state = state.copyWith(
        isSubmitting: false,
        showSuccess: true,
      );

      // Refresh dashboard stats and mood history
      ref.invalidate(adolescentDashboardControllerProvider);
      ref.invalidate(moodHistoryControllerProvider);
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

@Riverpod(keepAlive: true)
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
    if (state.isLoading) return;
    final current = state.hasValue ? state.value : null;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(isLoading: true, error: null));
    } else {
      state = const AsyncValue.loading();
    }
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
