import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'journal_provider.g.dart';

@riverpod
class JournalController extends _$JournalController {
  @override
  FutureOr<List<JournalEntry>> build() async {
    final service = ref.watch(journalServiceProvider);
    final result = await service.getMyJournals();
    return result.when(
      success: (value) => value,
      failure: (f) => throw Exception(f.message),
    );
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
        throw Exception(createResult.failure.message);
      }

      final getResult = await service.getMyJournals();
      return getResult.when(
        success: (value) => value,
        failure: (f) => throw Exception(f.message),
      );
    });
  }
}
