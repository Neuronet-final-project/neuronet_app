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
    final allJournals = getMockJournals();
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
      recentJournals: allJournals.take(3).toList(),
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
    return ConsentType.values.map((type) {
      return Consent(
        consentId: 'consent-${type.name}',
        adolescentId: 'user-123',
        guardianId: 'user-456',
        consentType: type,
        grantedToRole: GrantedToRole.both,
        consentStatus: type == ConsentType.dataSharing 
            ? ConsentStatus.revoked 
            : ConsentStatus.granted,
        grantedAt: DateTime.now().subtract(const Duration(days: 15)),
      );
    }).toList();
  }

  // ─── Chat Mocks ───

  static List<ChatMessage> getMockChatMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        messageId: 'msg-1',
        senderId: 'ai-counselor',
        receiverId: 'user-123',
        messageContent: "Hi Alex! I'm your AI counselor. How are you feeling today?",
        timestamp: now.subtract(const Duration(minutes: 30)),
        messageType: MessageType.aiChat,
        isRead: true,
      ),
      ChatMessage(
        messageId: 'msg-2',
        senderId: 'user-123',
        receiverId: 'ai-counselor',
        messageContent: "I'm feeling a bit overwhelmed with school work.",
        timestamp: now.subtract(const Duration(minutes: 25)),
        messageType: MessageType.aiChat,
        isRead: true,
      ),
      ChatMessage(
        messageId: 'msg-3',
        senderId: 'ai-counselor',
        receiverId: 'user-123',
        messageContent: "I understand. That sounds tough. Would you like to talk about what specifically is making you feel overwhelmed?",
        timestamp: now.subtract(const Duration(minutes: 20)),
        messageType: MessageType.aiChat,
        isRead: true,
      ),
    ];
  }

  static String getMockAiResponse(String userMessage) {
    if (userMessage.toLowerCase().contains('overwhelmed')) {
      return "It's completely normal to feel that way when things pile up. Let's try to break down your tasks together. What's the biggest thing on your plate right now?";
    } else if (userMessage.toLowerCase().contains('happy') || userMessage.toLowerCase().contains('good')) {
      return "That's wonderful to hear! I'm glad you're having a good day. What's been the highlight so far?";
    } else if (userMessage.toLowerCase().contains('sad') || userMessage.toLowerCase().contains('lonely')) {
      return "I'm here for you. It's okay to feel this way. Want to tell me more about what's on your mind?";
    }
    return "I hear you. Tell me more about that. I'm here to listen and help you reflect.";
  }
}
