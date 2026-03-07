import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

@freezed
class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    required String journalId,
    required String adolescentId,
    required String content,
    required DateTime createdAt,
    double? sentimentScore,
    DateTime? lastAnalyzedAt,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);
}

@freezed
class CreateJournalRequest with _$CreateJournalRequest {
  const factory CreateJournalRequest({
    required String content,
    String? moodId,
  }) = _CreateJournalRequest;

  factory CreateJournalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateJournalRequestFromJson(json);
}

@freezed
class MoodRecord with _$MoodRecord {
  const factory MoodRecord({
    required String moodId,
    required String adolescentId,
    required MoodType moodType,
    int? intensity,
    required DateTime recordedAt,
    String? contextNotes,
  }) = _MoodRecord;

  factory MoodRecord.fromJson(Map<String, dynamic> json) =>
      _$MoodRecordFromJson(json);
}

@freezed
class CreateMoodRequest with _$CreateMoodRequest {
  const factory CreateMoodRequest({
    required MoodType moodType,
    int? intensity,
    String? contextNotes,
  }) = _CreateMoodRequest;

  factory CreateMoodRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMoodRequestFromJson(json);
}
