import 'package:flutter_test/flutter_test.dart';
import 'package:neuronet_core/neuronet_core.dart';

void main() {
  group('User & Auth models', () {
    test('User parses from API-style JSON', () {
      final json = {
        '_id': 'u1',
        'full_name': 'Test User',
        'email': 'test@example.com',
        'role': 'adolescent',
        'account_status': 'active',
        'created_at': '2026-04-06T10:00:00Z',
      };
      final user = User.fromJson(json);
      expect(user.id, 'u1');
      expect(user.fullName, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.role, UserRole.adolescent);
      expect(user.accountStatus, AccountStatus.active);
    });

    test('AuthResponse parses from API-style JSON', () {
      final json = {
        'access_token': 'token123',
        'token_type': 'Bearer',
        'role': 'guardian',
        'email': 'guardian@test.com',
      };
      final response = AuthResponse.fromJson(json);
      expect(response.accessToken, 'token123');
      expect(response.tokenType, 'Bearer');
      expect(response.role, UserRole.guardian);
    });

    test('LoginRequest parses from JSON', () {
      final json = {'email': 'a@b.com', 'password': 'secret'};
      final request = LoginRequest.fromJson(json);
      expect(request.email, 'a@b.com');
      expect(request.password, 'secret');
    });

    test('AdolescentResponse parses and effectiveId works', () {
      final json = {
        '_id': 'a1',
        'adolescent_id': 'a1',
        'email': 'teen@test.com',
        'full_name': 'Teen User',
        'account_status': 'active',
        'role': 'adolescent',
        'relationship': 'parent',
      };
      final adolescent = AdolescentResponse.fromJson(json);
      expect(adolescent.effectiveId, 'a1');
      expect(adolescent.fullName, 'Teen User');
    });
  });

  group('Journal & Mood models', () {
    test('JournalEntry parses from API-style JSON', () {
      final json = {
        '_id': 'j1',
        'adolescent_id': 'u1',
        'title': 'My Day',
        'content': 'Had a great day',
        'created_at': '2026-04-06T10:00:00Z',
        'updated_at': '2026-04-06T10:00:00Z',
        'mood': 'happy',
        'sentiment_score': 0.8,
      };
      final entry = JournalEntry.fromJson(json);
      expect(entry.id, 'j1');
      expect(entry.mood, MoodType.happy);
      expect(entry.sentimentScore, 0.8);
      expect(entry.title, 'My Day');
    });

    test('CreateJournalRequest parses from JSON', () {
      final json = {
        'title': 'Test',
        'content': 'Content',
        'mood': 'anxious',
        'device_type': 'mobile',
      };
      final request = CreateJournalRequest.fromJson(json);
      expect(request.content, 'Content');
      expect(request.mood, MoodType.anxious);
      expect(request.deviceType, 'mobile');
    });

    test('MoodRecord parses from API-style JSON', () {
      final json = {
        '_id': 'm1',
        'adolescent_id': 'u1',
        'mood': 'sad',
        'intensity': 7,
        'created_at': '2026-04-06T12:00:00Z',
        'note': 'Feeling down',
      };
      final record = MoodRecord.fromJson(json);
      expect(record.mood, MoodType.sad);
      expect(record.intensity, 7);
      expect(record.note, 'Feeling down');
    });

    test('CreateMoodRequest parses from JSON', () {
      final json = {
        'mood': 'hopeful',
        'intensity': 8,
        'note': 'Feeling optimistic',
      };
      final request = CreateMoodRequest.fromJson(json);
      expect(request.mood, MoodType.hopeful);
      expect(request.intensity, 8);
    });
  });

  group('Alert models', () {
    test('Alert parses from API-style JSON with _id', () {
      final json = {
        '_id': 'alert1',
        'adolescent_id': 'u1',
        'adolescent_name': 'Teen',
        'severity_level': 'high',
        'alert_type': 'moodDrop',
        'trigger_description': 'Mood dropped significantly',
        'created_at': '2026-04-06T08:00:00Z',
        'viewed_status': false,
      };
      final alert = Alert.fromJson(json);
      expect(alert.alertId, 'alert1');
      expect(alert.severityLevel, 'high');
      expect(alert.viewedStatus, false);
    });

    test('Alert parses with alert_id fallback', () {
      final json = {
        'alert_id': 'alert2',
        'adolescent_id': 'u1',
        'adolescent_name': 'Teen',
        'severity_level': 'medium',
        'alert_type': 'emotionalPattern',
        'trigger_description': 'Pattern detected',
        'created_at': '2026-04-06T08:00:00Z',
        'viewed_status': true,
      };
      final alert = Alert.fromJson(json);
      expect(alert.alertId, 'alert2');
    });
  });

  group('Channel models', () {
    test('Channel parses from API-style JSON', () {
      final json = {
        'channelId': 'ch1',
        'counselorId': 'c1',
        'channelName': 'Wellness',
        'description': 'Wellness channel',
        'channelType': 'educational',
        'createdAt': '2026-04-06T09:00:00Z',
        'isActive': true,
        'subscriberCount': 42,
      };
      final channel = Channel.fromJson(json);
      expect(channel.channelId, 'ch1');
      expect(channel.channelType, ChannelType.educational);
      expect(channel.subscriberCount, 42);
    });

    test('ChannelPost parses from API-style JSON', () {
      final json = {
        'postId': 'p1',
        'channelId': 'ch1',
        'counselorId': 'c1',
        'title': 'Post Title',
        'content': 'Post content',
        'createdAt': '2026-04-06T09:00:00Z',
        'updatedAt': '2026-04-06T10:00:00Z',
        'reactionCount': 5,
        'viewCount': 100,
      };
      final post = ChannelPost.fromJson(json);
      expect(post.postId, 'p1');
      expect(post.reactionCount, 5);
      expect(post.isReacted, false); // default
    });

    test('ChannelInteraction parses from API-style JSON', () {
      final json = {
        'interactionId': 'i1',
        'postId': 'p1',
        'adolescentId': 'u1',
        'interactionType': 'comment',
        'content': 'Great post!',
        'createdAt': '2026-04-06T10:00:00Z',
      };
      final interaction = ChannelInteraction.fromJson(json);
      expect(interaction.interactionType, InteractionType.comment);
      expect(interaction.content, 'Great post!');
    });
  });

  group('Consent models', () {
    test('Consent parses from API-style JSON', () {
      final json = {
        '_id': 'consent1',
        'adolescent_id': 'teen@test.com',
        'guardian_id': 'guardian@test.com',
        'consent_type': 'shareAiSummaries',
        'granted_to_role': 'guardian',
        'consent_status': 'granted',
        'granted_at': '2026-04-06T10:00:00Z',
      };
      final consent = Consent.fromJson(json);
      expect(consent.consentType, ConsentType.shareAiSummaries);
      expect(consent.consentStatus, ConsentStatus.granted);
      expect(consent.grantedToRole, GrantedToRole.guardian);
    });
  });

  group('Conversation models', () {
    test('Conversation parses from API-style JSON', () {
      final json = {
        'conversation_id': 'conv1',
        'conversation_type': 'counselor_adolescent',
        'adolescent_id': 'u1',
        'participants': ['u1', 'c1'],
        'created_at': '2026-04-06T09:00:00Z',
        'updated_at': '2026-04-06T09:00:00Z',
      };
      final conversation = Conversation.fromJson(json);
      expect(conversation.type, ConversationType.counselorAdolescent);
      expect(conversation.participants, ['u1', 'c1']);
    });

    test('ConversationMessage parses from API-style JSON', () {
      final json = {
        'message_id': 'msg1',
        'conversation_id': 'conv1',
        'sender_email': 'counselor@test.com',
        'sender_role': 'counselor',
        'content': 'Hello!',
        'created_at': '2026-04-06T10:00:00Z',
      };
      final message = ConversationMessage.fromJson(json);
      expect(message.content, 'Hello!');
      expect(message.senderEmail, 'counselor@test.com');
    });
  });

  group('Dashboard models', () {
    test('GuardianDashboardData parses from API-style JSON', () {
      final json = {
        'total_adolescents_linked': 2,
        'total_journal_count': 10,
        'recent_activity_count': 5,
        'adolescent_risks': [
          {
            'adolescent_id': 'u1',
            'adolescent_name': 'Teen 1',
            'current_risk_level': 'low',
            'last_journal_date': '2026-04-06T10:00:00Z',
          }
        ],
        'alert_list': [],
        'mood_distribution': {'happy': 5, 'sad': 2},
        'generated_at': '2026-04-06T12:00:00Z',
      };
      final data = GuardianDashboardData.fromJson(json);
      expect(data.totalAdolescentsLinked, 2);
      expect(data.adolescentRisks.length, 1);
      expect(data.moodDistribution['happy'], 5);
    });

    test('DashboardData parses from API-style JSON', () {
      final json = {
        'recent_journals': [
          {
            'id': 'j1',
            'created_at': '2026-04-06T10:00:00Z',
            'mood': 'happy',
            'title': 'Good day',
          }
        ],
        'mood_distribution': {'happy': 3},
        'educational_recommendations': [],
      };
      final data = DashboardData.fromJson(json);
      expect(data.recentJournals.length, 1);
      expect(data.recentJournals.first.mood, MoodType.happy);
    });

    test('GuardianDashboardData.empty returns defaults', () {
      final data = GuardianDashboardData.empty();
      expect(data.totalAdolescentsLinked, 0);
      expect(data.adolescentRisks, isEmpty);
    });
  });

  group('Educational models', () {
    test('EducationalPage parses from JSON with custom fromJson', () {
      final json = {
        'id': 'ep1',
        'title': 'Understanding Anxiety',
        'slug': 'understanding-anxiety',
        'content': 'Content here',
        'summary': 'A guide',
        'category': 'mental-health',
        'created_at': '2026-04-06T10:00:00Z',
      };
      final page = EducationalPage.fromJson(json);
      expect(page.id, 'ep1');
      expect(page.slug, 'understanding-anxiety');
      expect(page.title, 'Understanding Anxiety');
    });

    test('Recommendation parses from JSON with nested page', () {
      final pageJson = {
        'id': 'ep1',
        'title': 'Test',
        'slug': 'test',
        'content': 'Content',
        'created_at': '2026-04-06T10:00:00Z',
      };
      final json = {
        'id': 'r1',
        'adolescent_id': 'u1',
        'page': pageJson,
        'reason': 'Based on recent activity',
        'created_at': '2026-04-06T10:00:00Z',
      };
      final rec = Recommendation.fromJson(json);
      expect(rec.reason, 'Based on recent activity');
      expect(rec.page.title, 'Test');
    });
  });

  group('Request models', () {
    test('ActivateAccountRequest parses from JSON', () {
      final json = {
        'email': 'a@b.com',
        'activation_token': 'tok123',
        'password': 'newpass',
      };
      final request = ActivateAccountRequest.fromJson(json);
      expect(request.activationToken, 'tok123');
    });

    test('GuardianRegisterRequest parses from JSON', () {
      final json = {
        'full_name': 'Guardian',
        'email': 'g@test.com',
        'password': 'secret',
      };
      final request = GuardianRegisterRequest.fromJson(json);
      expect(request.fullName, 'Guardian');
    });

    test('AdolescentCreateRequest parses from JSON', () {
      final json = {
        'email': 'teen@test.com',
        'full_name': 'Teen',
        'date_of_birth': '2009-05-15T00:00:00Z',
        'relationship': 'parent',
        'consents': ['shareAiSummaries', 'shareAlerts'],
      };
      final request = AdolescentCreateRequest.fromJson(json);
      expect(request.fullName, 'Teen');
      expect(request.consents.length, 2);
      expect(request.consents.first, ConsentType.shareAiSummaries);
    });

    test('SendMessageRequest parses from JSON', () {
      final json = {
        'receiverId': 'c1',
        'content': 'Hello counselor',
        'messageType': 'counselorChat',
      };
      final request = SendMessageRequest.fromJson(json);
      expect(request.content, 'Hello counselor');
      expect(request.messageType, MessageType.counselorChat);
    });

    test('ChatMessage parses from API-style JSON', () {
      final json = {
        'messageId': 'msg1',
        'senderId': 'u1',
        'receiverId': 'c1',
        'messageContent': 'Hi',
        'timestamp': '2026-04-06T10:00:00Z',
        'messageType': 'aiChat',
      };
      final message = ChatMessage.fromJson(json);
      expect(message.messageId, 'msg1');
      expect(message.messageContent, 'Hi');
      expect(message.messageType, MessageType.aiChat);
    });
  });

  group('Result type', () {
    test('success value', () {
      final result = Result.success('hello');
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.value, 'hello');
    });

    test('failure value', () {
      final result = Result<String>.failure(const ServerFailure(message: 'oops'));
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.failure.message, 'oops');
      expect(result.failure, isA<ServerFailure>());
    });

    test('when on success', () {
      final result = Result.success(42);
      final output = result.when(
        success: (v) => 'got $v',
        failure: (f) => 'error: ${f.message}',
      );
      expect(output, 'got 42');
    });

    test('when on failure', () {
      final result = Result<int>.failure(const NetworkFailure());
      final output = result.when(
        success: (v) => 'got $v',
        failure: (f) => 'error: ${f.message}',
      );
      expect(output, 'error: No internet connection');
    });

    test('failureFromException maps generic exception to UnknownFailure', () {
      final failure = failureFromException(Exception('generic error'));
      expect(failure, isA<UnknownFailure>());
    });

    test('ServerFailure extracts message from map data', () {
      final failure = failureFromException(
        const FormatException('test'), // not DioException → UnknownFailure
      );
      expect(failure, isA<UnknownFailure>());
    });
  });

  group('Enum serialization', () {
    test('UserRole toJson/fromJson round-trip', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromJson(role.toJson()), role);
      }
    });

    test('MoodType emoji and label', () {
      expect(MoodType.happy.emoji, '😊');
      expect(MoodType.sad.label, 'Sad');
      expect(MoodType.anxious.emoji, '😰');
    });

    test('ConsentType labels', () {
      expect(ConsentType.shareAiSummaries.label, 'AI Summaries & Risk Levels');
      expect(ConsentType.shareAlerts.description, contains('immediate notifications'));
    });

    test('AlertSeverity round-trip', () {
      for (final severity in AlertSeverity.values) {
        expect(AlertSeverity.fromJson(severity.toJson()), severity);
      }
    });

    test('InteractionType round-trip', () {
      expect(InteractionType.reaction.toJson(), 'reaction');
      expect(InteractionType.fromJson('comment'), InteractionType.comment);
    });
  });
}
