import 'package:dio/dio.dart';

/// Unified failure hierarchy for the NEURONET system.
sealed class Failure {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'Failure($message, statusCode: $statusCode)';
}

/// Server returned an error (4xx/5xx).
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.statusCode,
    this.errorCode,
  });

  final String? errorCode;
}

/// Network error (no connection, timeout).
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection'});
}

/// Authentication failure (401/403).
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication required',
    super.statusCode,
  });
}

/// Validation failure (client-side input errors).
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;
}

/// Unknown/unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred'});
}

/// Convert an exception to a [Failure].
///
/// Handles [DioException] specifically, falling back to [UnknownFailure]
/// for all other exception types.
Failure failureFromException(Object exception) {
  if (exception is DioException) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(message: 'Connection timed out');
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return AuthFailure(statusCode: statusCode);
        }
        final message = _extractErrorMessage(exception.response?.data) ??
            'Server error ($statusCode)';
        return ServerFailure(message: message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'Request cancelled');
      case DioExceptionType.badCertificate:
        return const UnknownFailure(message: 'Certificate error');
      case DioExceptionType.unknown:
        return UnknownFailure(message: exception.message ?? 'Unknown error');
    }
  }
  return UnknownFailure(message: exception.toString());
}

String? _extractErrorMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    return data['message'] as String? ??
        data['error'] as String? ??
        data['detail'] as String?;
  }
  if (data is String) return data;
  return null;
}

/// Result type — Either a success value or a Failure.
class Result<T> {
  const Result.success(this._value) : _failure = null;
  const Result.failure(Failure failure) : _failure = failure, _value = null;

  final T? _value;
  final Failure? _failure;

  bool get isSuccess => _failure == null;
  bool get isFailure => _failure != null;

  T get value {
    if (_value == null && _failure != null) {
      throw StateError('Cannot get value from a failed Result: $_failure');
    }
    return _value as T;
  }

  Failure get failure {
    if (_failure == null) {
      throw StateError('Cannot get failure from a successful Result');
    }
    return _failure;
  }

  /// Pattern match on the result.
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    if (isSuccess) return success(value);
    return failure(this.failure);
  }
}
