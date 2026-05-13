import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that retries failed requests due to timeouts or server errors.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 5),
    ],
  });

  final Dio dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Don't retry if it's not a timeout or server error
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    final options = err.requestOptions;
    int attempt = (options.extra['retry_attempt'] as int? ?? 0);

    if (attempt < maxRetries) {
      attempt++;
      options.extra['retry_attempt'] = attempt;
      
      final delay = retryDelays[attempt - 1];
      debugPrint('[RetryInterceptor] Retrying ${options.path} (Attempt $attempt/$maxRetries) in ${delay.inSeconds}s...');
      
      await Future.delayed(delay);

      try {
        // We use a fresh Dio instance or ensure we don't infinitely recurse
        // Actually, dio.fetch will re-run ALL interceptors.
        // The 'attempt' check prevents infinite loops.
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } on DioException catch (e) {
        // The error will be handled by the next Interceptor's onError or 
        // will bubble up to this interceptor again if it's the first one in the list.
        return handler.next(e);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on timeouts
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on 5xx server errors
    if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
      return true;
    }

    return false;
  }
}
