import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/logging_interceptor.dart';

/// Configured Dio instance for NEURONET API.
class ApiClient {
  ApiClient({
    String? baseUrl,
    TokenStorage? tokenStorage,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage: tokenStorage ?? InMemoryTokenStorage()),
      AppLoggingInterceptor(),
    ]);
  }

  final Dio _dio;

  Dio get dio => _dio;

  /// GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  /// POST request.
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, options: options);

  /// PUT request.
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, options: options);

  /// DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    Options? options,
  }) =>
      _dio.delete<T>(path, options: options);
}
