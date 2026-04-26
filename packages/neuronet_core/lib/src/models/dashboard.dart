import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

/// Converts either a `List<{mood, count}>` or a `Map<String, int>` from the API
/// into a uniform `Map<String, int>` for local use.
Map<String, int> _moodDistributionFromJson(dynamic json) {
  if (json is List) {
    return {
      for (final item in json)
        (item as Map<String, dynamic>)['mood'] as String:
            ((item['count']) as num).toInt(),
    };
  }
  if (json is Map) {
    return json.map((k, v) => MapEntry(k.toString(), (v as num).toInt()));
  }
  return {};
}

dynamic _moodDistributionToJson(Map<String, int> map) => map;

// ─── Shared sub-models ────────────────────────────────────────────────────────

/// Trend data is currently not provided by the aggregate dashboard endpoints.
@freezed
abstract class EmotionalTrend with _$EmotionalTrend {
  const factory EmotionalTrend({
    required DateTime date,
    @JsonKey(name: 'sentiment_score') required double sentimentScore,
    @JsonKey(name: 'dominant_mood') required String dominantMood,
    @JsonKey(name: 'journal_count') required int journalCount,
    @JsonKey(name: 'mood_entry_count') required int moodEntryCount,
  }) = _EmotionalTrend;

  factory EmotionalTrend.fromJson(Map<String, dynamic> json) =>
      _$EmotionalTrendFromJson(json);
}

/// One adolescent's risk entry as returned inside GuardianDashboardResponse.adolescent_risks.
@freezed
abstract class AdolescentRisk with _$AdolescentRisk {
  const factory AdolescentRisk({
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'adolescent_name') required String adolescentName,
    @JsonKey(name: 'current_risk_level') required String currentRiskLevel,
    @JsonKey(name: 'last_journal_date') DateTime? lastJournalDate,
    @JsonKey(name: 'educational_recommendations') @Default([]) List<Map<String, dynamic>> educationalRecommendations,
  }) = _AdolescentRisk;

  factory AdolescentRisk.fromJson(Map<String, dynamic> json) =>
      _$AdolescentRiskFromJson(json);
}

/// Brief alert info as returned inside GuardianDashboardResponse.alert_list.
@freezed
abstract class AlertBrief with _$AlertBrief {
  const factory AlertBrief({
    @JsonKey(name: 'alert_id') required String alertId,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'adolescent_name') required String adolescentName,
    @JsonKey(name: 'severity_level') required String severityLevel,
    @JsonKey(name: 'alert_type') required String alertType,
    @JsonKey(name: 'trigger_description') required String triggerDescription,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'viewed_status') required bool viewedStatus,
  }) = _AlertBrief;

  factory AlertBrief.fromJson(Map<String, dynamic> json) =>
      _$AlertBriefFromJson(json);
}

// ─── Guardian Dashboard ───────────────────────────────────────────────────────

/// Matches GuardianDashboardResponse from the production backend.
@freezed
abstract class GuardianDashboardData with _$GuardianDashboardData {
  const factory GuardianDashboardData({
    @JsonKey(name: 'total_adolescents_linked') @Default(0) int totalAdolescentsLinked,
    @JsonKey(name: 'total_journal_count') @Default(0) int totalJournalCount,
    @JsonKey(name: 'recent_activity_count') @Default(0) int recentActivityCount,
    @JsonKey(name: 'adolescent_risks') @Default([]) List<AdolescentRisk> adolescentRisks,
    @JsonKey(name: 'alert_list') @Default([]) List<AlertBrief> alertList,
    @JsonKey(name: 'unviewed_alerts_count') @Default(0) int unviewedAlertsCount,
    @JsonKey(name: 'mood_distribution', fromJson: _moodDistributionFromJson, toJson: _moodDistributionToJson) @Default({}) Map<String, int> moodDistribution,
    @JsonKey(name: 'generated_at') DateTime? generatedAt,
  }) = _GuardianDashboardData;

  factory GuardianDashboardData.fromJson(Map<String, dynamic> json) =>
      _$GuardianDashboardDataFromJson(json);

  factory GuardianDashboardData.empty() => const GuardianDashboardData();
}

// ─── Adolescent Dashboard ─────────────────────────────────────────────────────

@freezed
abstract class RecentJournal with _$RecentJournal {
  const factory RecentJournal({
    required String id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    MoodType? mood,
    String? title,
  }) = _RecentJournal;

  factory RecentJournal.fromJson(Map<String, dynamic> json) =>
      _$RecentJournalFromJson(json);
}

/// Matches AdolescentDashboardResponse from the production backend.
@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    @JsonKey(name: 'recent_journals') required List<RecentJournal> recentJournals,
    @JsonKey(name: 'total_journals') @Default(0) int totalJournals,
    @JsonKey(name: 'mood_distribution', fromJson: _moodDistributionFromJson, toJson: _moodDistributionToJson) @Default({}) Map<String, int> moodDistribution,
    @JsonKey(name: 'total_moods') @Default(0) int totalMoods,
    @JsonKey(name: 'educational_recommendations') @Default([]) List<Map<String, dynamic>> educationalRecommendations,
    @JsonKey(name: 'generated_at') DateTime? generatedAt,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);

  factory DashboardData.empty() => const DashboardData(recentJournals: []);
}
