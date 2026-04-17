import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuronet_core/src/errors/failures.dart';

void main() {
  group('Failure Mapping Tests', () {
    test('DioException connection error maps to NetworkFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
        error: 'No internet',
        message: 'The connection errored',
      );

      final failure = failureFromException(dioError);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('No internet connection'));
    });

    test('DioException timeout maps to NetworkFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      final failure = failureFromException(dioError);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('Connection timed out'));
    });

    test('DioException 401 maps to AuthFailure', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'message': 'Unauthorized'},
        ),
      );

      final failure = failureFromException(dioError);

      expect(failure, isA<AuthFailure>());
      expect(failure.statusCode, 401);
    });
  });
}
