import '../models/models.dart';

/// A service that provides mock data for UI development and testing.
/// This allows building screens without a functional backend.
class MockDataService {
  // ─── User Mocks ───

  static User getMockAdolescent() {
    return User(
      userId: 'user-123',
      fullName: 'Alex Johnson',
      email: 'alex@example.com',
      role: UserRole.adolescent,
      accountStatus: AccountStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  static User getMockGuardian() {
    return User(
      userId: 'user-456',
      fullName: 'Sarah Johnson',
      email: 'sarah@example.com',
      role: UserRole.guardian,
      accountStatus: AccountStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  static List<JournalEntry> getMockJournals() {
    final contents = [
      'Today I felt quite productive. I managed to finish my homework early and even had time to play some video games.',
      'I had a bit of an argument with my mom today about cleaning my room. It made me feel a bit frustrated.',
      'Sometimes I feel like I am just going through the motions. I wonder if things will ever feel exciting again.',
      'I saw a beautiful sunset today. It reminded me that there is still beauty in the world, even when things are tough.',
      'I am looking forward to the weekend. I plan to hang out with my friends and just relax.',
    ];
    
    return List.generate(
      contents.length,
      (index) => JournalEntry(
        journalId: 'journal-$index',
        adolescentId: 'user-123',
        content: contents[index],
        createdAt: DateTime.now().subtract(Duration(days: index)),
        sentimentScore: 0.5 + (index * 0.1), // Varies from 0.5 to 0.9
      ),
    );
  }

  static List<MoodRecord> getMockMoods() {
    return List.generate(
      10,
      (index) => MoodRecord(
        moodId: 'mood-$index',
        adolescentId: 'user-123',
        moodType: MoodType.values[index % MoodType.values.length],
        intensity: (index % 5) + 1,
        recordedAt: DateTime.now().subtract(Duration(hours: index * 4)),
        contextNotes: 'Mock mood entry $index',
      ),
    );
  }

  static DashboardData getMockAdolescentDashboard() {
    return DashboardData(
      trends: List.generate(
        7,
        (index) => EmotionalTrend(
          date: DateTime.now().subtract(Duration(days: 6 - index)),
          sentimentScore: 0.3 + (index * 0.1),
          dominantMood: 'Stable',
          journalCount: index % 2,
          moodEntryCount: index % 3,
        ),
      ),
      totalJournals: 45,
      totalMoodEntries: 120,
      activeAlerts: 0,
      unreadMessages: 2,
    );
  }

  static GuardianDashboardData getMockGuardianDashboard() {
    return GuardianDashboardData(
      adolescentId: 'user-123',
      adolescentName: 'Alex Johnson',
      weeklyTrends: List.generate(
        7,
        (index) => EmotionalTrend(
          date: DateTime.now().subtract(Duration(days: 6 - index)),
          sentimentScore: 0.6,
          dominantMood: 'Stable',
        ),
      ),
      activeAlerts: 1,
      recentActivities: 5,
      currentMood: 'Calm',
    );
  }

  static List<Alert> getMockAlerts() {
    return [
      Alert(
        alertId: 'alert-1',
        adolescentId: 'user-123',
        alertType: AlertType.moodDrop,
        severityLevel: AlertSeverity.medium,
        triggerDescription: 'Significant drop in mood detected over the last 48 hours.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        viewedStatus: false,
        actionStatus: AlertActionStatus.pending,
      ),
      Alert(
        alertId: 'alert-2',
        adolescentId: 'user-123',
        alertType: AlertType.emotionalPattern,
        severityLevel: AlertSeverity.high,
        triggerDescription: 'High frequency of negative sentiment in recent journals.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        viewedStatus: true,
        actionStatus: AlertActionStatus.resolved,
      ),
    ];
  }

  static List<Consent> getMockConsents() {
    return [
      Consent(
        consentId: 'consent-1',
        adolescentId: 'user-123',
        guardianId: 'user-456',
        consentType: ConsentType.journalAnalysis,
        grantedToRole: GrantedToRole.guardian,
        consentStatus: ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
    ];
  }
}
