import 'package:faker/faker.dart';
import '../models/models.dart';

/// A service that provides mock data for UI development and testing.
/// This allows building screens without a functional backend.
class MockDataService {
  static final Faker _faker = Faker();

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
    return List.generate(
      5,
      (index) => JournalEntry(
        journalId: 'journal-$index',
        adolescentId: 'user-123',
        content: _faker.lorem.sentences(3).join(' '),
        createdAt: DateTime.now().subtract(Duration(days: index)),
        sentimentScore: _faker.randomGenerator.decimal(),
      ),
    );
  }

  static List<MoodRecord> getMockMoods() {
    return List.generate(
      10,
      (index) => MoodRecord(
        moodId: 'mood-$index',
        adolescentId: 'user-123',
        moodType: MoodType.values[_faker.randomGenerator.integer(MoodType.values.length)],
        intensity: _faker.randomGenerator.integer(5, min: 1),
        recordedAt: DateTime.now().subtract(Duration(hours: index * 4)),
        contextNotes: _faker.lorem.sentence(),
      ),
    );
  }

  static DashboardData getMockAdolescentDashboard() {
    return DashboardData(
      trends: List.generate(
        7,
        (index) => EmotionalTrend(
          date: DateTime.now().subtract(Duration(days: 6 - index)),
          sentimentScore: _faker.randomGenerator.decimal(),
          dominantMood: 'Happy',
          journalCount: _faker.randomGenerator.integer(2),
          moodEntryCount: _faker.randomGenerator.integer(3),
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
          sentimentScore: _faker.randomGenerator.decimal(),
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
