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
    final currentState = state.value ?? [];
    state = const AsyncLoading();
    
    // In a real app, this would be an API call
    final newEntry = JournalEntry(
      journalId: DateTime.now().millisecondsSinceEpoch.toString(),
      adolescentId: 'user-123',
      title: title,
      content: content,
      moodType: moodType,
      createdAt: DateTime.now(),
      sentimentScore: moodType != null ? _getSentimentFromMood(moodType) : null,
    );

    state = AsyncData([newEntry, ...currentState]);
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
