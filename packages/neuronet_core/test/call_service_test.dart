import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:neuronet_core/neuronet_core.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient apiClient;
  late CallService callService;

  setUp(() {
    apiClient = MockApiClient();
    callService = CallService(apiClient);
  });

  final dt = DateTime(2026, 4, 6, 12, 0, 0, 0, 0).toUtc();
  final callJson = {
    'call_id': 'c1',
    'conversation_id': 'conv1',
    'call_type': 'voice',
    'status': 'ringing',
    'caller_email': 'test@test.com',
    'created_at': dt.toIso8601String(),
  };

  group('CallService - initiateCall', () {
    test('returns call on success', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.initiateCall,
          data: {'conversation_id': 'conv1', 'call_type': 'voice'},
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.initiateCall),
          statusCode: 201,
          data: callJson,
        ),
      );

      final result = await callService.initiateCall(conversationId: 'conv1');

      expect(result.isSuccess, true);
      expect(result.value.id, 'c1');
      expect(result.value.conversationId, 'conv1');
      expect(result.value.callType, CallType.voice);
    });

    test('returns failure on network error', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.initiateCall,
          data: any(named: 'data'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.initiateCall),
          type: DioExceptionType.connectionError,
        ),
      );

      final result = await callService.initiateCall(conversationId: 'conv1');

      expect(result.isFailure, true);
      expect(result.failure, isA<NetworkFailure>());
    });
  });

  group('CallService - getIncomingCalls', () {
    test('returns list of calls for raw list response', () async {
      when(() => apiClient.get(ApiEndpoints.incomingCalls)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.incomingCalls),
          statusCode: 200,
          data: [callJson],
        ),
      );

      final result = await callService.getIncomingCalls();

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.id, 'c1');
    });

    test('returns list of calls for "calls" nested map', () async {
      when(() => apiClient.get(ApiEndpoints.incomingCalls)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.incomingCalls),
          statusCode: 200,
          data: {'calls': [callJson]},
        ),
      );

      final result = await callService.getIncomingCalls();

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.id, 'c1');
    });

    test('returns list of calls for single "call" wrapper', () async {
      when(() => apiClient.get(ApiEndpoints.incomingCalls)).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.incomingCalls),
          statusCode: 200,
          data: {'call': callJson},
        ),
      );

      final result = await callService.getIncomingCalls();

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.id, 'c1');
    });

    test('silently returns empty list on network error', () async {
      when(() => apiClient.get(ApiEndpoints.incomingCalls)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.incomingCalls),
        ),
      );

      final result = await callService.getIncomingCalls();

      expect(result.isSuccess, true);
      expect(result.value, isEmpty);
    });
  });

  group('CallService - getCallDetails', () {
    test('returns call details on success', () async {
      when(() => apiClient.get(ApiEndpoints.callDetails('c1'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.callDetails('c1')),
          statusCode: 200,
          data: callJson,
        ),
      );

      final result = await callService.getCallDetails('c1');

      expect(result.isSuccess, true);
      expect(result.value.id, 'c1');
    });

    test('returns failure on error', () async {
      when(() => apiClient.get(ApiEndpoints.callDetails('c1'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.callDetails('c1')),
          response: Response(
            requestOptions: RequestOptions(path: ApiEndpoints.callDetails('c1')),
            statusCode: 404,
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      final result = await callService.getCallDetails('c1');

      expect(result.isFailure, true);
      expect(result.failure, isA<ServerFailure>());
    });
  });

  group('CallService - sendSignal', () {
    final offerSignal = SignalRequestExt.sdpOffer('v=0...');

    test('returns success when signal is posted', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.callSignal('c1'),
          data: offerSignal.toJson(),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.callSignal('c1')),
          statusCode: 200,
        ),
      );

      final result = await callService.sendSignal(
        callId: 'c1',
        signal: offerSignal,
      );

      expect(result.isSuccess, true);
    });

    test('returns failure on server error', () async {
      when(
        () => apiClient.post(
          ApiEndpoints.callSignal('c1'),
          data: any(named: 'data'),
        ),
      ).thenThrow(
        Exception('Connection closed'),
      );

      final result = await callService.sendSignal(
        callId: 'c1',
        signal: offerSignal,
      );

      expect(result.isFailure, true);
    });
  });

  group('CallService - getSignals', () {
    final signalJson = {
      'type': 'answer',
      'data': {'sdp': 'v=0...', 'type': 'answer'}
    };

    test('returns signals if present in "signals" field', () async {
      when(() => apiClient.get(ApiEndpoints.callDetails('c1'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.callDetails('c1')),
          statusCode: 200,
          data: {
            ...callJson,
            'signals': [signalJson],
          },
        ),
      );

      final result = await callService.getSignals('c1');

      expect(result.isSuccess, true);
      expect(result.value.length, 1);
      expect(result.value.first.type, 'answer');
    });

    test('returns empty if "signals" is absent', () async {
      when(() => apiClient.get(ApiEndpoints.callDetails('c1'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.callDetails('c1')),
          statusCode: 200,
          data: callJson,
        ),
      );

      final result = await callService.getSignals('c1');

      expect(result.isSuccess, true);
      expect(result.value, isEmpty);
    });

    test('returns empty on error (silently handled)', () async {
      when(() => apiClient.get(ApiEndpoints.callDetails('c1'))).thenThrow(
        Exception('Network drop'),
      );

      final result = await callService.getSignals('c1');

      expect(result.isSuccess, true);
      expect(result.value, isEmpty);
    });
  });

  group('CallService - actions (answer/active/end)', () {
    test('answerCall hits endpoint successfully', () async {
      when(() => apiClient.post(ApiEndpoints.callAnswer('c1'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.callAnswer('c1')),
          statusCode: 200,
        ),
      );

      final result = await callService.answerCall('c1');
      expect(result.isSuccess, true);
      verify(() => apiClient.post(ApiEndpoints.callAnswer('c1'))).called(1);
    });

    test('setCallActive hits endpoint successfully', () async {
      when(() => apiClient.post(ApiEndpoints.callActive('c1'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.callActive('c1')),
          statusCode: 200,
        ),
      );

      final result = await callService.setCallActive('c1');
      expect(result.isSuccess, true);
      verify(() => apiClient.post(ApiEndpoints.callActive('c1'))).called(1);
    });

    test('endCall hits endpoint successfully', () async {
      when(() => apiClient.post(ApiEndpoints.callEnd('c1'))).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ApiEndpoints.callEnd('c1')),
          statusCode: 200,
        ),
      );

      final result = await callService.endCall('c1');
      expect(result.isSuccess, true);
      verify(() => apiClient.post(ApiEndpoints.callEnd('c1'))).called(1);
    });

    test('endCall returns failure on network error', () async {
      when(() => apiClient.post(ApiEndpoints.callEnd('c1'))).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: ApiEndpoints.callEnd('c1')),
          type: DioExceptionType.connectionTimeout,
        ),
      );

      final result = await callService.endCall('c1');
      expect(result.isFailure, true);
      expect(result.failure, isA<NetworkFailure>());
    });
  });
}
