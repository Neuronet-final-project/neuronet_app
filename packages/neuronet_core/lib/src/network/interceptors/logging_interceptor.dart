import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Logging interceptor for API requests/responses.
class AppLoggingInterceptor extends Interceptor {
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
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
    final statusCode = err.response?.statusCode ?? 'UNKNOWN';
    final url = err.requestOptions.uri;
    final method = err.requestOptions.method;
    
    String reason = 'Unexpected error';
    String suggestion = 'Check network and server status.';
    
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        reason = 'Timeout error';
        suggestion = 'Server might be overloaded or network is slow.';
        break;
      case DioExceptionType.badResponse:
        reason = 'Server returned $statusCode';
        suggestion = 'Verify API endpoint and request payload. Response: ${err.response?.data}';
        break;
      case DioExceptionType.cancel:
        reason = 'Request cancelled';
        suggestion = 'Request was explicitly aborted.';
        break;
      case DioExceptionType.connectionError:
        if (err.message?.contains('XMLHttpRequest') == true) {
          reason = 'Web/CORS or Server Crash';
          suggestion = '1. Verify backend handled the request (Status 500 crash often shows as XHR error).\n'
                       '2. Ensure backend has CORS enabled for this origin.\n'
                       '3. Check if the backend process is healthy and logs are clean.';
        } else {
          reason = 'Connection failed';
          suggestion = 'Ensure server is up and reachable from this device. Check firewall rules.';
        }
        break;
      case DioExceptionType.badCertificate:
        reason = 'SSL Certificate error';
        suggestion = 'Trust the server certificate or use a valid one.';
        break;
      default:
        reason = err.type.toString();
        suggestion = err.message ?? 'No additional details available.';
    }

    _logger.e(
        'FAILED REQUEST: $method $url\n'
        '──────────────────────────────────────────────────\n'
        'HTTP STATUS: $statusCode\n'
        'DIAGNOSIS:   $reason\n'
        'DETAILS:     ${err.message}\n'
        'SUGGESTION:  $suggestion\n'
        '──────────────────────────────────────────────────',
        error: err.error,
    );
    handler.next(err);
  }
}
