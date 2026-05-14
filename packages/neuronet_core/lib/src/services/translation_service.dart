import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../errors/failures.dart';
import '../models/models.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../network/providers.dart';

part 'translation_service.g.dart';

class TranslationService {
  TranslationService(this._client);
  final ApiClient _client;

  static final Options _translationHttpOptions = Options(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  );

  /// Translates text to a specific [targetLang].
  /// 
  /// [sourceLang] defaults to 'auto' for automatic language detection.
  Future<Result<TranslationResponse>> translate({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    try {
      final request = TranslationRequest(
        text: text,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
      final response = await _client.post(
        ApiEndpoints.translate,
        data: request.toJson(),
        options: _translationHttpOptions,
      );
      final translation = TranslationResponse.fromJson(response.data as Map<String, dynamic>);
      return Result.success(translation);
    } catch (e) {
      return Result.failure(failureFromException(e));
    }
  }
}

@riverpod
TranslationService translationService(Ref ref) {
  final client = ref.watch(apiClientProvider);
  return TranslationService(client);
}
