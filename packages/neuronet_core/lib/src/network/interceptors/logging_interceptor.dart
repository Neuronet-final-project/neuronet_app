import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Logging interceptor for API requests/responses.
class AppLoggingInterceptor extends Interceptor {
  final _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, printTime: true),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _logger.i(
      '← ${response.statusCode} ${response.requestOptions.uri}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e(
      '✗ ${err.response?.statusCode ?? 'UNKNOWN'} ${err.requestOptions.uri}',
      error: err.message,
    );
    handler.next(err);
  }
}
