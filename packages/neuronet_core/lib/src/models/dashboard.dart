import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

// ─── Shared sub-models ────────────────────────────────────────────────────────

/// A single mood + count, returned by mood_distribution.
@freezed
abstract class MoodCount with _$MoodCount {
  const factory MoodCount({
    String? mood,
    required int count,
  }) = _MoodCount;

  factory MoodCount.fromJson(Map<String, dynamic> json) =>
      _$MoodCountFromJson(json);
}

/// A trend data point for emotional charts.
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

/// Risk summary for one adolescent, inside the guardian dashboard.
@freezed
abstract class AdolescentRisk with _$AdolescentRisk {
  const factory AdolescentRisk({
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'adolescent_name') required String adolescentName,
    @JsonKey(name: 'current_risk_level') required String currentRiskLevel,
    @JsonKey(name: 'last_journal_date') DateTime? lastJournalDate,
    @Default([]) List<Map<String, dynamic>> educationalRecommendations,
  }) = _AdolescentRisk;

  factory AdolescentRisk.fromJson(Map<String, dynamic> json) =>
      _$AdolescentRiskFromJson(json);
}

// ─── Guardian Dashboard ───────────────────────────────────────────────────────

/// Matches GuardianDashboardResponse from the backend + Redesign UX fields.
@freezed
abstract class GuardianDashboardData with _$GuardianDashboardData {
  const factory GuardianDashboardData({
    @JsonKey(name: 'total_adolescents_linked') @Default(0) int totalAdolescentsLinked,
    @JsonKey(name: 'total_journal_count') @Default(0) int totalJournalCount,
    @JsonKey(name: 'recent_activity_count') @Default(0) int recentActivityCount,
    @JsonKey(name: 'adolescent_risks') @Default([]) List<AdolescentRisk> adolescentRisks,
    @JsonKey(name: 'alert_list') @Default([]) List<AlertBrief> alertList,
    @JsonKey(name: 'unviewed_alerts_count') @Default(0) int unviewedAlertsCount,
    @JsonKey(name: 'mood_distribution') @Default([]) List<MoodCount> moodDistribution,
    @JsonKey(name: 'adolescentId') @Default('') String adolescentId,
    @JsonKey(name: 'adolescentName') @Default('Adolescent') String adolescentName,
    @JsonKey(name: 'weekly_trends') @Default([]) List<EmotionalTrend> weeklyTrends,
    @JsonKey(name: 'generated_at') DateTime? generatedAt,
  }) = _GuardianDashboardData;

  factory GuardianDashboardData.fromJson(Map<String, dynamic> json) =>
      _$GuardianDashboardDataFromJson(json);
}

// ─── Adolescent Dashboard ─────────────────────────────────────────────────────

@freezed
abstract class RecentJournal with _$RecentJournal {
  const factory RecentJournal({
    required String id,
    required DateTime createdAt,
    String? mood,
    String? title,
  }) = _RecentJournal;

  factory RecentJournal.fromJson(Map<String, dynamic> json) =>
      _$RecentJournalFromJson(json);
}

/// Matches AdolescentDashboardResponse from the backend + Redesign UX fields.
@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    required List<RecentJournal> recentJournals,
    required List<MoodCount> moodDistribution,
    @Default([]) List<Map<String, dynamic>> educationalRecommendations,
    required List<EmotionalTrend> trends,
    required int totalJournals,
    required int totalMoodEntries,
    required int activeAlerts,
    required int unreadMessages,
    DateTime? generatedAt,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}
