import '../models/models.dart';

/// A service that provides mock data for UI development and testing.
/// This allows building screens without a functional backend.
class MockDataService {
  // ─── User Mocks ───

  static User getMockAdolescent() {
    return User(
      id: 'user-123',
      fullName: 'Alex Johnson',
      email: 'alex@example.com',
      role: UserRole.adolescent,
      accountStatus: AccountStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  static User getMockGuardian() {
    return User(
      id: 'user-456',
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
        id: 'journal-$index',
        adolescentId: 'user-123',
        content: contents[index],
        createdAt: DateTime.now().subtract(Duration(days: index)),
        updatedAt: DateTime.now().subtract(Duration(days: index)),
        sentimentScore: 0.5 + (index * 0.1), // Varies from 0.5 to 0.9
      ),
    );
  }

  static List<MoodRecord> getMockMoods() {
    return List.generate(
      10,
      (index) => MoodRecord(
        id: 'mood-$index',
        adolescentId: 'user-123',
        mood: MoodType.values[index % MoodType.values.length],
        intensity: (index % 5) + 1,
        createdAt: DateTime.now().subtract(Duration(hours: index * 4)),
        note: 'Mock mood entry $index',
      ),
    );
  }

  static DashboardData getMockAdolescentDashboard() {
    final allJournals = getMockJournals();
    return DashboardData(
      recentJournals: allJournals
          .take(3)
          .map((j) => RecentJournal(
                id: j.id,
                createdAt: j.createdAt,
                mood: j.mood,
                title: j.title,
              ))
          .toList(),
      moodDistribution: {
        'Happy': 12,
        'Calm': 8,
      },
      educationalRecommendations: [],
    );
  }

  static GuardianDashboardData getMockGuardianDashboard() {
    return GuardianDashboardData(
      totalAdolescentsLinked: 2,
      totalJournalCount: 15,
      recentActivityCount: 5,
      adolescentRisks: {
        'user-123': 'Medium',
      },
      alertList: [],
      unviewedAlertsCount: 1,
      moodDistribution: {
        'Stable': 10,
        'Variable': 5,
      },
      generatedAt: DateTime.now(),
    );
  }

  static List<Alert> getMockAlerts() {
    return [
      Alert(
        alertId: 'alert-1',
        adolescentId: 'user-123',
        adolescentName: 'Alex Johnson',
        alertType: 'mood_drop',
        severityLevel: 'medium',
        triggerDescription: 'Significant drop in mood detected over the last 48 hours.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        viewedStatus: false,
      ),
      Alert(
        alertId: 'alert-2',
        adolescentId: 'user-123',
        adolescentName: 'Alex Johnson',
        alertType: 'emotional_pattern',
        severityLevel: 'high',
        triggerDescription: 'High frequency of negative sentiment in recent journals.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        viewedStatus: true,
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

  // ─── Channel Mocks ───

  static List<Channel> getMockChannels() {
    return [
      Channel(
        channelId: 'ch-1',
        counselorId: 'c-1',
        channelName: 'Mindfulness & Growth',
        description: 'Daily tips for emotional balance and personal development.',
        channelType: ChannelType.educational,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        isFeatured: true,
        subscriberCount: 120,
      ),
      Channel(
        channelId: 'ch-2',
        counselorId: 'c-2',
        channelName: 'Teen Support Network',
        description: 'A safe space to discuss common challenges and share experiences.',
        channelType: ChannelType.supportive,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        isFeatured: false,
        isFollowed: true,
        subscriberCount: 450,
      ),
      Channel(
        channelId: 'ch-3',
        counselorId: 'c-1',
        channelName: 'Wellness Library',
        description: 'Curated resources for mental health and stress management.',
        channelType: ChannelType.resourceLibrary,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        isFeatured: false,
        subscriberCount: 85,
      ),
    ];
  }

  static List<ChannelPost> getMockPosts(String channelId) {
    return [
      ChannelPost(
        postId: 'p-1',
        channelId: channelId,
        counselorId: 'c-1',
        title: '5 Minutes to Calm',
        content:
            'Try this simple breathing exercise: Inhale for 4, Hold for 4, Exhale for 4. Repeat 4 times. This helps regulate your nervous system and bring your focus back to the present moment.',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        viewCount: 156,
        reactionCount: 24,
        isReacted: true,
      ),
      ChannelPost(
        postId: 'p-2',
        channelId: channelId,
        counselorId: 'c-1',
        title: 'Developing a Growth Mindset',
        content:
            'Challenges are opportunities to learn. Instead of saying "I can\'t do this," try "I can\'t do this yet." Your brain is a muscle that grows stronger with every challenge you tackle.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        viewCount: 432,
        reactionCount: 85,
        isPinned: true,
      ),
    ];
  }

  static List<ChannelInteraction> getMockComments(String postId) {
    return [
      ChannelInteraction(
        interactionId: 'i-1',
        postId: postId,
        adolescentId: 'user-123',
        interactionType: InteractionType.comment,
        content: 'This was really helpful! I tried it and feel much better.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChannelInteraction(
        interactionId: 'i-2',
        postId: postId,
        adolescentId: 'user-456',
        interactionType: InteractionType.comment,
        content: 'Thanks for sharing this, counselor!',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  // ─── Guardian Specific Mocks ───

  /// Simulates registering an adolescent and returns an activation code.
  static String registerAdolescent({
    required String name,
    required DateTime dateOfBirth,
    required String email,
    required RelationshipType relationship,
    required List<ConsentType> initialConsents,
  }) {
    // In a real app, this would call an API and return a code from the backend.
    // Here we just return a random-looking 6-digit code.
    return '528-914';
  }

  /// Returns mock conversation history between guardian and counselor.
  static List<ChatMessage> getGuardianCounselorMessages() {
    final now = DateTime.now();
    return [
      ChatMessage(
        messageId: 'gmsg-1',
        senderId: 'counselor-1',
        receiverId: 'user-456',
        messageContent: "Hello Mrs. Johnson, I'm Dr. Smith, Alex's assigned counselor. How are things going at home?",
        timestamp: now.subtract(const Duration(days: 2)),
        messageType: MessageType.guardianChat,
        isRead: true,
      ),
      ChatMessage(
        messageId: 'gmsg-2',
        senderId: 'user-456',
        receiverId: 'counselor-1',
        messageContent: "Hello Dr. Smith. Alex seems a bit more withdrawn lately. I noticed the alert about his mood drop.",
        timestamp: now.subtract(const Duration(days: 1, hours: 22)),
        messageType: MessageType.guardianChat,
        isRead: true,
      ),
      ChatMessage(
        messageId: 'gmsg-3',
        senderId: 'counselor-1',
        receiverId: 'user-456',
        messageContent: "I've noticed that too in our sessions. I'm working with him on some coping strategies. Please keep me updated if you notice any specific triggers.",
        timestamp: now.subtract(const Duration(days: 1, hours: 20)),
        messageType: MessageType.guardianChat,
        isRead: true,
      ),
    ];
  }
}
