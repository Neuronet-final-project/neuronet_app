import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'journal_service.g.dart';

class JournalService {
  JournalService(this._client);
  final ApiClient _client;

  /// Fetches all journal entries for the authenticated adolescent.
  Future<List<JournalEntry>> getMyJournals() async {
    final response = await _client.get(ApiEndpoints.journals);
    final list = response.data as List<dynamic>;
    return list.map((json) => JournalEntry.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Creates a new journal entry.
  Future<JournalEntry> createJournal(CreateJournalRequest request) async {
    final response = await _client.post(
      ApiEndpoints.journals,
      data: request.toJson(),
    );
    return JournalEntry.fromJson(response.data as Map<String, dynamic>);
  }

  /// Fetches all mood records for the authenticated adolescent.
  Future<List<MoodRecord>> getMyMoods() async {
    final response = await _client.get(ApiEndpoints.myMoods);
    final list = response.data as List<dynamic>;
    return list.map((json) => MoodRecord.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// Records a new mood.
  Future<MoodRecord> recordMood(CreateMoodRequest request) async {
    final response = await _client.post(
      ApiEndpoints.moods,
      data: request.toJson(),
    );
    return MoodRecord.fromJson(response.data as Map<String, dynamic>);
  }
}

@riverpod
JournalService journalService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return JournalService(client);
}
