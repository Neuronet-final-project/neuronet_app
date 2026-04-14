import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'call_service.g.dart';

@riverpod
CallService callService(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CallService(apiClient);
}

/// Service for managing voice and video calls via the backend API.
/// Uses HTTP-based WebRTC signaling (no WebSockets).
class CallService {
  CallService(this._apiClient);
  final ApiClient _apiClient;

  /// Initiates a new call (voice or video) in the given conversation.
  /// Returns the created [Call] with a `call_id`.
  Future<Result<Call>> initiateCall({
    required String conversationId,
    CallType callType = CallType.voice,
  }) async {
    try {
      final payload = {
        'conversation_id': conversationId,
        'call_type': callType.toJson(),
      };

      final response = await _apiClient.post(
        ApiEndpoints.initiateCall,
        data: payload,
      );

      final call = Call.fromJson(response.data as Map<String, dynamic>);
      return Result.success(call);
    } catch (e) {
      debugPrint('[CallService] Failed to initiate call: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Checks for incoming call notifications.
  /// Poll this endpoint to detect incoming calls.
  Future<Result<List<Call>>> getIncomingCalls() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.incomingCalls);
      final dynamic rawData = response.data;

      // debugPrint('[CallService] Raw incoming calls response: $rawData');

      List<dynamic> data;
      if (rawData is List) {
        data = rawData;
      } else if (rawData is Map<String, dynamic>) {
        // Handle wrapped responses: {"calls": [...]} or {"data": [...]} or {"call": {...}}
        final callsList = rawData['calls'] ?? rawData['data'];
        if (callsList is List) {
          data = callsList;
        } else if (rawData['call'] is Map<String, dynamic>) {
          // Single call object wrapped: {"call": {...}}
          data = [rawData['call'] as Map<String, dynamic>];
        } else {
          data = [];
        }
      } else {
        debugPrint('[CallService] Unexpected response format for incoming calls: ${rawData.runtimeType}');
        return const Result.success([]);
      }

      final calls = data
          .map((e) => Call.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(calls);
    } catch (e) {
      // Silently return empty list — polling endpoint, errors are expected
      // occasionally when no calls are incoming.
      debugPrint('[CallService] Failed to check incoming calls: $e');
      return Result.success([]);
    }
  }

  /// Gets details about a specific call by ID.
  Future<Result<Call>> getCallDetails(String callId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.callDetails(callId));
      final call = Call.fromJson(response.data as Map<String, dynamic>);
      return Result.success(call);
    } catch (e) {
      debugPrint('[CallService] Failed to get call details: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Exchanges a WebRTC signaling message (offer, answer, or ICE candidate).
  Future<Result<void>> sendSignal({
    required String callId,
    required SignalRequest signal,
  }) async {
    try {
      // Only log signal sends for offers and answers (not ICE candidates)
      if (signal.type != 'ice-candidate') {
        debugPrint('[CallService] Sending signal: ${signal.type}');
      }

      await _apiClient.post(
        ApiEndpoints.callSignal(callId),
        data: signal.toJson(),
      );

      return const Result.success(null);
    } catch (e) {
      debugPrint('[CallService] Failed to send signal: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Retrieves pending signals for a call (for polling-based signaling).
  Future<Result<List<SignalRequest>>> getSignals(String callId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.callDetails(callId));
      // Backend may return signals in a 'signals' field or embedded in the call object.
      // If not present, return empty list.
      final data = response.data as Map<String, dynamic>;
      final signalsRaw = data['signals'] as List?;
      if (signalsRaw == null) return Result.success([]);

      final signals = signalsRaw
          .map((e) => SignalRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.success(signals);
    } catch (e) {
      debugPrint('[CallService] Failed to get signals: $e');
      return Result.success([]);
    }
  }

  /// Answers an incoming call.
  Future<Result<void>> answerCall(String callId) async {
    try {

      await _apiClient.post(ApiEndpoints.callAnswer(callId));
      return const Result.success(null);
    } catch (e) {
      debugPrint('[CallService] Failed to answer call: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Marks a call as active (both peers connected via WebRTC).
  Future<Result<void>> setCallActive(String callId) async {
    try {

      await _apiClient.post(ApiEndpoints.callActive(callId));
      return const Result.success(null);
    } catch (e) {
      debugPrint('[CallService] Failed to set call active: $e');
      return Result.failure(failureFromException(e));
    }
  }

  /// Ends an active call.
  Future<Result<void>> endCall(String callId) async {
    try {

      await _apiClient.post(ApiEndpoints.callEnd(callId));
      return const Result.success(null);
    } catch (e) {
      debugPrint('[CallService] Failed to end call: $e');
      return Result.failure(failureFromException(e));
    }
  }
}
