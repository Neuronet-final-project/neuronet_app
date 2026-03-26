import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'journal_provider.g.dart';

@riverpod
class JournalController extends _$JournalController {
  @override
  FutureOr<List<JournalEntry>> build() async {
    // Simulate initial fetch
    return MockDataService.getMockJournals();
  }

  Future<void> addEntry(String content, {String? title, MoodType? moodType}) async {
    state = const AsyncLoading();
    
    state = await AsyncValue.guard(() async {
      const userId = 'adolescent-1'; // Constant ID for pilot/demo

      final newEntry = JournalEntry(
        journalId: DateTime.now().millisecondsSinceEpoch.toString(),
        adolescentId: userId,
        title: title,
        content: content,
        moodType: moodType,
        createdAt: DateTime.now(),
        sentimentScore: moodType != null ? _getSentimentFromMood(moodType) : null,
      );

      final currentList = state.value ?? [];
      return [newEntry, ...currentList];
    });
  }

  double _getSentimentFromMood(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
      case MoodType.excited:
      case MoodType.hopeful:
        return 0.9;
      case MoodType.calm:
      case MoodType.neutral:
        return 0.5;
      case MoodType.sad:
      case MoodType.anxious:
      case MoodType.stressed:
      case MoodType.angry:
      case MoodType.tired:
        return 0.2;
    }
  }
}
