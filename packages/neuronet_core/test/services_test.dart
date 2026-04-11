import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuronet_core/neuronet_core.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockApiClient extends Mock implements ApiClient {}

// ── Auth Service Tests ────────────────────────────────────────────────────────

void main() {
  late MockApiClient apiClient;
  late AuthService authService;

  setUp(() {
    apiClient = MockApiClient();
    authService = AuthService(apiClient);
  });

  group('AuthService', () {
    test('login returns success with valid response', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.login,
          data: {'email': 'test@test.com', 'password': 'pass'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          statusCode: 200,
          data: {
            'access_token': 'token123',
            'token_type': 'Bearer',
            'role': 'adolescent',
          },
        ),
      );

      final result = await authService.login('test@test.com', 'pass');

      expect(result.isSuccess, true);
      expect(result.value.accessToken, 'token123');
      expect(result.value.role, UserRole.adolescent);
    });

    test('login returns failure on error', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.login,
          data: {'email': 'bad@test.com', 'password': 'wrong'},
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.login),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.login),
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await authService.login('bad@test.com', 'wrong');

      expect(result.isFailure, true);
      expect(result.failure, isA<AuthFailure>());
    });

    test('getMe returns user on success', () async {
      when(() => apiClient.get(ApiEndpoints.me)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.me),
          statusCode: 200,
          data: {
            '_id': 'u1',
            'full_name': 'Test User',
            'email': 'test@test.com',
            'role': 'adolescent',
            'account_status': 'active',
          },
        ),
      );

      final result = await authService.getMe();

      expect(result.isSuccess, true);
      expect(result.value.email, 'test@test.com');
    });
  });

  // ── Alert Service Tests ─────────────────────────────────────────────────────

  group('AlertService', () {
    late AlertService alertService;

    setUp(() {
      alertService = AlertService(apiClient);
    });

    test('getGuardianAlerts returns alerts on success', () async {
      when(() => apiClient.get(ApiEndpoints.guardianAlerts)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.guardianAlerts),
          statusCode: 200,
          data: [
            {
              '_id': 'a1',
              'adolescent_id': 'u1',
              'adolescent_name': 'Teen',
              'severity_level': 'high',
              'alert_type': 'moodDrop',
              'trigger_description': 'Mood dropped',
              'created_at': '2026-04-06T08:00:00Z',
              'viewed_status': false,
            }
          ],
        ),
      );

      final result = await alertService.getGuardianAlerts();

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.adolescentName, 'Teen');
    });

    test('getGuardianAlerts returns failure on network error', () async {
      when(() => apiClient.get(ApiEndpoints.guardianAlerts)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.guardianAlerts),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await alertService.getGuardianAlerts();

      expect(result.isFailure, true);
      expect(result.failure, isA<NetworkFailure>());
    });

    test('resolveAlert returns updated alert on success', () async {
      when(
        () => apiClient.put(
          ApiEndpoints.resolveAlert('a1'),
          data: {'action_notes': 'Reviewed'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.resolveAlert('a1'),
          ),
          statusCode: 200,
          data: {
            '_id': 'a1',
            'adolescent_id': 'u1',
            'adolescent_name': 'Teen',
            'severity_level': 'high',
            'alert_type': 'moodDrop',
            'trigger_description': 'Mood dropped',
            'created_at': '2026-04-06T08:00:00Z',
            'viewed_status': true,
          },
        ),
      );

      final result = await alertService.resolveAlert(
        'a1',
        notes: 'Reviewed',
      );

      expect(result.isSuccess, true);
      expect(result.value.viewedStatus, true);
    });
  });

  // ── Journal Service Tests ───────────────────────────────────────────────────

  group('JournalService', () {
    late JournalService journalService;

    setUp(() {
      journalService = JournalService(apiClient);
    });

    test('getMyJournals returns list on success', () async {
      when(() => apiClient.get(ApiEndpoints.journals)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.journals),
          statusCode: 200,
          data: [
            {
              '_id': 'j1',
              'adolescent_id': 'u1',
              'content': 'Good day',
              'created_at': '2026-04-06T10:00:00Z',
              'updated_at': '2026-04-06T10:00:00Z',
              'mood': 'happy',
            }
          ],
        ),
      );

      final result = await journalService.getMyJournals();

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.mood, MoodType.happy);
    });

    test('createJournal returns new entry on success', () async {
      final request = const CreateJournalRequest(
        content: 'New entry',
        mood: MoodType.neutral,
        deviceType: 'mobile',
      );

      when(
        () => apiClient.post(ApiEndpoints.journals, data: request.toJson()),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.journals),
          statusCode: 201,
          data: {
            '_id': 'j2',
            'adolescent_id': 'u1',
            'content': 'New entry',
            'created_at': '2026-04-06T12:00:00Z',
            'updated_at': '2026-04-06T12:00:00Z',
            'mood': 'neutral',
          },
        ),
      );

      final result = await journalService.createJournal(request);

      expect(result.isSuccess, true);
      expect(result.value.content, 'New entry');
    });
  });

  // ── Channel Service Tests ───────────────────────────────────────────────────

  group('ChannelService', () {
    late ChannelService channelService;

    setUp(() {
      channelService = ChannelService(apiClient);
    });

    test('getMyChannels returns channels on success', () async {
      when(() => apiClient.get(ApiEndpoints.myChannels)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.myChannels),
          statusCode: 200,
          data: [
            {
              'channelId': 'ch1',
              'counselorId': 'c1',
              'channelName': 'Wellness',
              'description': 'Wellness tips',
              'channelType': 'educational',
              'createdAt': '2026-04-06T09:00:00Z',
            }
          ],
        ),
      );

      final result = await channelService.getMyChannels();

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.channelName, 'Wellness');
    });

    test('subscribeToChannel returns success', () async {
      when(
        () => apiClient.post(ApiEndpoints.channelSubscribe('ch1')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.channelSubscribe('ch1'),
          ),
          statusCode: 200,
        ),
      );

      final result = await channelService.subscribeToChannel('ch1');

      expect(result.isSuccess, true);
    });
  });

  // ── Educational Service Tests ───────────────────────────────────────────────

  group('EducationalService', () {
    late EducationalService educationalService;

    setUp(() {
      educationalService = EducationalService(apiClient);
    });

    test('listPages returns pages on success', () async {
      when(
        () => apiClient.get(ApiEndpoints.educationalPages),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.educationalPages),
          statusCode: 200,
          data: [
            {
              'id': 'ep1',
              'title': 'Understanding Anxiety',
              'slug': 'understanding-anxiety',
              'content': 'Content',
              'created_at': '2026-04-06T10:00:00Z',
            }
          ],
        ),
      );

      final result = await educationalService.listPages();

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.title, 'Understanding Anxiety');
    });

    test('getPage returns failure on server error', () async {
      when(
        () => apiClient.get(ApiEndpoints.educationalPageBySlug('missing')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(
            path: ApiEndpoints.educationalPageBySlug('missing'),
          ),
          response: Response(
            requestOptions: RequestOptions(
              path: ApiEndpoints.educationalPageBySlug('missing'),
            ),
            statusCode: 500,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await educationalService.getPage('missing');

      expect(result.isFailure, true);
      expect(result.failure, isA<ServerFailure>());
      expect(result.failure.statusCode, 500);
    });
  });

  // ── Messaging Service Tests ─────────────────────────────────────────────────

  group('MessagingService', () {
    late MessagingService messagingService;

    setUp(() {
      messagingService = MessagingService(apiClient);
    });

    test('getMessages returns list on success', () async {
      when(
        () => apiClient.get(ApiEndpoints.conversationMessages('conv1')),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.conversationMessages('conv1'),
          ),
          statusCode: 200,
          data: [
            {
              'message_id': 'msg1',
              'conversation_id': 'conv1',
              'sender_email': 'counselor@test.com',
              'sender_role': 'counselor',
              'content': 'Hello!',
              'created_at': '2026-04-06T10:00:00Z',
            }
          ],
        ),
      );

      final result = await messagingService.getMessages('conv1');

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.content, 'Hello!');
    });

    test('sendMessage returns new message on success', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.conversationMessages('conv1'),
          data: {'content': 'Hi'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(
            path: ApiEndpoints.conversationMessages('conv1'),
          ),
          statusCode: 201,
          data: {
            'message_id': 'msg2',
            'conversation_id': 'conv1',
            'sender_email': 'guardian@test.com',
            'sender_role': 'guardian',
            'content': 'Hi',
            'created_at': '2026-04-06T11:00:00Z',
          },
        ),
      );

      final result = await messagingService.sendMessage(
        conversationId: 'conv1',
        content: 'Hi',
      );

      expect(result.isSuccess, true);
      expect(result.value.content, 'Hi');
    });
  });
}
