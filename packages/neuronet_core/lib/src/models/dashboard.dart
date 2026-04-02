import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

// ─── Shared sub-models ────────────────────────────────────────────────────────

/// Trend data is currently not provided by the aggregate dashboard endpoints.
/// This model remains for potential future use or specific trend endpoints.
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
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'adolescent_name') required String adolescentName,
    @JsonKey(name: 'severity') required String severity,
    @JsonKey(name: 'type') required String type,
    @JsonKey(name: 'description') required String description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'is_viewed') required bool isViewed,
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
    @JsonKey(name: 'adolescent_risks') @Default({}) Map<String, String> adolescentRisks,
    @JsonKey(name: 'alert_list') @Default([]) List<AlertBrief> alertList,
    @JsonKey(name: 'unviewed_alerts_count') @Default(0) int unviewedAlertsCount,
    @JsonKey(name: 'mood_distribution') @Default({}) Map<String, int> moodDistribution,
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
    @JsonKey(name: 'mood_distribution') @Default({}) Map<String, int> moodDistribution,
    @JsonKey(name: 'educational_recommendations') @Default([]) List<Map<String, dynamic>> educationalRecommendations,
    @JsonKey(name: 'generated_at') DateTime? generatedAt,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);

  factory DashboardData.empty() => const DashboardData(recentJournals: []);
}

