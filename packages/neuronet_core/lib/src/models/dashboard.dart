import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard.freezed.dart';
part 'dashboard.g.dart';

/// Aggregated emotional trend data for dashboards.
@freezed
abstract class EmotionalTrend with _$EmotionalTrend {
  const factory EmotionalTrend({
    required DateTime date,
    required double sentimentScore,
    String? dominantMood,
    int? journalCount,
    int? moodEntryCount,
  }) = _EmotionalTrend;

  factory EmotionalTrend.fromJson(Map<String, dynamic> json) =>
      _$EmotionalTrendFromJson(json);
}

/// Dashboard overview data (used by both apps with role-appropriate filtering).
@freezed
abstract class DashboardData with _$DashboardData {
  const factory DashboardData({
    required List<EmotionalTrend> trends,
    @Default(0) int totalJournals,
    @Default(0) int totalMoodEntries,
    @Default(0) int activeAlerts,
    @Default(0) int unreadMessages,
  }) = _DashboardData;

  factory DashboardData.fromJson(Map<String, dynamic> json) =>
      _$DashboardDataFromJson(json);
}

/// Guardian-specific dashboard with aggregated adolescent data.
@freezed
abstract class GuardianDashboardData with _$GuardianDashboardData {
  const factory GuardianDashboardData({
    required String adolescentId,
    required String adolescentName,
    required List<EmotionalTrend> weeklyTrends,
    @Default(0) int activeAlerts,
    @Default(0) int recentActivities,
    String? currentMood,
  }) = _GuardianDashboardData;

  factory GuardianDashboardData.fromJson(Map<String, dynamic> json) =>
      _$GuardianDashboardDataFromJson(json);
}
