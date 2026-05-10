import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'journal_entry.freezed.dart';
part 'journal_entry.g.dart';

@freezed
abstract class JournalEntry with _$JournalEntry {
  const factory JournalEntry({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    String? title,
    required String content,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'mood', fromJson: _nullableMoodFromString, toJson: _nullableMoodToJson) MoodType? mood,
    @JsonKey(name: 'sentiment_score') double? sentimentScore,
    @JsonKey(name: 'risk_level') String? riskLevel,
    @JsonKey(name: 'keywords_detected') List<String>? keywordsDetected,
    @JsonKey(name: 'translated_content') String? translatedContent,
  }) = _JournalEntry;

  factory JournalEntry.fromJson(Map<String, dynamic> json) =>
      _$JournalEntryFromJson(json);
}

@freezed
abstract class CreateJournalRequest with _$CreateJournalRequest {
  const factory CreateJournalRequest({
    String? title,
    required String content,
    @JsonKey(name: 'mood', fromJson: _moodFromString, toJson: _moodToJson) required MoodType mood,
    @JsonKey(name: 'device_type') required String deviceType,
  }) = _CreateJournalRequest;

  factory CreateJournalRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateJournalRequestFromJson(json);
}

@freezed
abstract class MoodRecord with _$MoodRecord {
  const factory MoodRecord({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'mood', fromJson: _moodFromString, toJson: _moodToJson) required MoodType mood,
    int? intensity,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    String? note,
  }) = _MoodRecord;

  factory MoodRecord.fromJson(Map<String, dynamic> json) =>
      _$MoodRecordFromJson(json);
}

MoodType _moodFromString(String s) {
  try {
    return MoodType.values.byName(s.toLowerCase());
  } catch (_) {
    return MoodType.neutral;
  }
}

String _moodToJson(MoodType m) => m.toJson();

MoodType? _nullableMoodFromString(dynamic s) {
  if (s == null) return null;
  return _moodFromString(s.toString());
}

String? _nullableMoodToJson(MoodType? m) => m?.toJson();

@freezed
abstract class CreateMoodRequest with _$CreateMoodRequest {
  const factory CreateMoodRequest({
    required MoodType mood,
    int? intensity,
    String? note,
  }) = _CreateMoodRequest;

  factory CreateMoodRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateMoodRequestFromJson(json);
}
