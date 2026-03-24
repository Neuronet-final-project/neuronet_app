import 'package:neuronet_core/neuronet_core.dart';

void main() {
  try {
    final journals = MockDataService.getMockJournals();
    for (var journal in journals) {
      print('Journal ID: ${journal.journalId}');
      print('Content: ${journal.content}');
      print('Sentiment: ${journal.sentimentScore}');
      print('---');
    }
  } catch (e, stack) {
    print('Error: $e');
    print(stack);
  }
}
