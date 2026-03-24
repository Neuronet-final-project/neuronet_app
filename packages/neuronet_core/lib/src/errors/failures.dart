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
