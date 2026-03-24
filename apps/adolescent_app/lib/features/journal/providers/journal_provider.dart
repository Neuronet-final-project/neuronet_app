import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'journal_provider.g.dart';

@riverpod
class JournalController extends _$JournalController {
  @override
  FutureOr<List<JournalEntry>> build() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return MockDataService.getMockJournals();
  }

  Future<void> addEntry(String content) async {
    final currentState = state.value ?? [];
    state = const AsyncLoading();
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final newEntry = JournalEntry(
      journalId: DateTime.now().millisecondsSinceEpoch.toString(),
      adolescentId: 'user-123', // Static mock ID
      content: content,
      createdAt: DateTime.now(),
      sentimentScore: null, // Not analyzed yet
    );

    state = AsyncData([newEntry, ...currentState]);
  }
}
