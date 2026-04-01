import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'journal_provider.g.dart';

@riverpod
class JournalController extends _$JournalController {
  @override
  FutureOr<List<JournalEntry>> build() async {
    final service = ref.watch(journalServiceProvider);
    return service.getMyJournals();
  }

  Future<void> addEntry(String content, {String? title, MoodType? moodType}) async {
    final service = ref.read(journalServiceProvider);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final request = CreateJournalRequest(
        title: title,
        content: content,
        moodType: moodType,
      );
      
      await service.createJournal(request);
      return service.getMyJournals();
    });
  }
}
