import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'api_client.dart';
import 'interceptors/auth_interceptor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'providers.g.dart';

@riverpod
TokenStorage tokenStorage(Ref ref) {
  return SecureTokenStorage();
}

@riverpod
ApiClient apiClient(Ref ref) {
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: storage);
}

class SecureTokenStorage implements TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  @override
  Future<void> saveTokens({required String accessToken, String? refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
