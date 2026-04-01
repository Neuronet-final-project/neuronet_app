import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

// ─── Shared sub-models ────────────────────────────────────────────────────────

/// A single mood + count, returned by mood_distribution.
@freezed
class MoodCount with _$MoodCount {
  const factory MoodCount({
    String? mood,
    required int count,
  }) = _MoodCount;

  factory MoodCount.fromJson(Map<String, dynamic> json) =>
      _$MoodCountFromJson(json);
}

/// A trend data point for emotional charts.
@freezed
class EmotionalTrend with _$EmotionalTrend {
  const factory EmotionalTrend({
    required DateTime date,
    required double sentimentScore,
    required String dominantMood,
    required int journalCount,
    required int moodEntryCount,
  }) = _EmotionalTrend;

  factory EmotionalTrend.fromJson(Map<String, dynamic> json) =>
      _$EmotionalTrendFromJson(json);
}

/// Brief alert info as returned inside GuardianDashboardResponse.alert_list.
@freezed
class AlertBrief with _$AlertBrief {
  const factory AlertBrief({
    required String alertId,
    required String adolescentId,
    required String adolescentName,
    required String severityLevel,
    required String alertType,
    required String triggerDescription,
    required DateTime createdAt,
    required bool viewedStatus,
  }) = _AlertBrief;

  factory AlertBrief.fromJson(Map<String, dynamic> json) =>
      _$AlertBriefFromJson(json);
}

/// Risk summary for one adolescent, inside the guardian dashboard.
@freezed
class AdolescentRisk with _$AdolescentRisk {
  const factory AdolescentRisk({
    required String adolescentId,
    required String adolescentName,
    required String currentRiskLevel,
    DateTime? lastJournalDate,
    @Default([]) List<Map<String, dynamic>> educationalRecommendations,
  }) = _AdolescentRisk;

  factory AdolescentRisk.fromJson(Map<String, dynamic> json) =>
      _$AdolescentRiskFromJson(json);
}

// ─── Guardian Dashboard ───────────────────────────────────────────────────────

/// Matches GuardianDashboardResponse from the backend + Redesign UX fields.
@freezed
class GuardianDashboardData with _$GuardianDashboardData {
  const factory GuardianDashboardData({
    required int totalAdolescentsLinked,
    required int totalJournalCount,
    required int recentActivityCount,
    required List<AdolescentRisk> adolescentRisks,
    required List<AlertBrief> alertList,
    required int unviewedAlertsCount,
    required List<MoodCount> moodDistribution,
    required String adolescentId,
    required String adolescentName,
    required List<EmotionalTrend> weeklyTrends,
    DateTime? generatedAt,
  }) = _GuardianDashboardData;

  factory GuardianDashboardData.fromJson(Map<String, dynamic> json) =>
      _$GuardianDashboardDataFromJson(json);
}

// ─── Adolescent Dashboard ─────────────────────────────────────────────────────

@freezed
class RecentJournal with _$RecentJournal {
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
class DashboardData with _$DashboardData {
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
