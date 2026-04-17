import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'journal_provider.freezed.dart';
part 'journal_provider.g.dart';

@freezed
abstract class JournalState with _$JournalState {
  const factory JournalState({
    @Default([]) List<JournalEntry> entries,
    @Default(false) bool isLoading,
    String? error,
  }) = _JournalState;
}

@riverpod
class JournalController extends _$JournalController {
  @override
  FutureOr<JournalState> build() async {
    final service = ref.read(journalServiceProvider);
    final result = await service.getMyJournals();
    
    return result.when(
      success: (value) => JournalState(entries: value, isLoading: false),
      failure: (f) => JournalState(isLoading: false, error: f.message),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(journalServiceProvider);
      final result = await service.getMyJournals();
      return result.when(
        success: (value) => JournalState(entries: value, isLoading: false),
        failure: (f) => JournalState(isLoading: false, error: f.message),
      );
    });
  }

  Future<void> addEntry(String content, {String? title, MoodType? mood}) async {
    final service = ref.read(journalServiceProvider);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final request = CreateJournalRequest(
        title: title,
        content: content,
        mood: mood ?? MoodType.neutral,
        deviceType: 'mobile',
      );

      final createResult = await service.createJournal(request);
      if (createResult.isFailure) {
        return JournalState(entries: state.value?.entries ?? [], error: createResult.failure.message);
      }

      final getResult = await service.getMyJournals();
      return getResult.when(
        success: (value) => JournalState(entries: value, isLoading: false),
        failure: (f) => JournalState(entries: state.value?.entries ?? [], error: f.message),
      );
    });
  }
}
