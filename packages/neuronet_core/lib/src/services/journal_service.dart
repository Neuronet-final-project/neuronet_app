import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'journal_service.g.dart';

class JournalService {
  JournalService(this._client);
  final ApiClient _client;

  /// Fetches all journal entries for the authenticated adolescent.
  Future<Result<List<JournalEntry>>> getMyJournals() async {
    try {
      final response = await _client.get(ApiEndpoints.journals);
      final list = response.data as List<dynamic>;
      final entries = list
          .map((json) => JournalEntry.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(entries);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Creates a new journal entry.
  Future<Result<JournalEntry>> createJournal(
    CreateJournalRequest request,
  ) async {
    try {
      final response = await _client.post(
        ApiEndpoints.journals,
        data: request.toJson(),
      );
      final entry = JournalEntry.fromJson(response.data as Map<String, dynamic>);
      return Result.success(entry);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Fetches all mood records for the authenticated adolescent.
  Future<Result<List<MoodRecord>>> getMyMoods() async {
    try {
      final response = await _client.get(ApiEndpoints.myMoods);
      final list = response.data as List<dynamic>;
      final moods = list
          .map((json) => MoodRecord.fromJson(json as Map<String, dynamic>))
          .toList();
      return Result.success(moods);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }

  /// Records a new mood.
  Future<Result<MoodRecord>> recordMood(CreateMoodRequest request) async {
    try {
      final response = await _client.post(
        ApiEndpoints.moods,
        data: request.toJson(),
      );
      final record = MoodRecord.fromJson(response.data as Map<String, dynamic>);
      return Result.success(record);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
JournalService journalService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return JournalService(client);
}
