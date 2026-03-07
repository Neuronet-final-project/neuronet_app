import 'package:dio/dio.dart';

/// Storage abstraction for JWT tokens.
abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<void> clearTokens();
}

/// Simple in-memory token storage for development.
class InMemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<String?> getRefreshToken() async => _refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    _accessToken = accessToken;
    if (refreshToken != null) _refreshToken = refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
  }
}

/// Interceptor that attaches JWT tokens and handles 401 refresh.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.tokenStorage});

  final TokenStorage tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired — attempt refresh
      final refreshToken = await tokenStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await Dio().post<Map<String, dynamic>>(
            '${err.requestOptions.baseUrl}/api/v1/auth/refresh',
            data: {'refresh_token': refreshToken},
          );
          final newToken = response.data?['token'] as String?;
          if (newToken != null) {
            await tokenStorage.saveTokens(
              accessToken: newToken,
              refreshToken:
                  response.data?['refresh_token'] as String? ?? refreshToken,
            );
            // Retry original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final retryResponse = await Dio().fetch<dynamic>(
              err.requestOptions,
            );
            return handler.resolve(retryResponse);
          }
        } catch (_) {
          await tokenStorage.clearTokens();
        }
      }
    }
    handler.next(err);
  }
}
