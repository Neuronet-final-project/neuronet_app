import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation.freezed.dart';
part 'translation.g.dart';

@freezed
abstract class TranslationRequest with _$TranslationRequest {
  const factory TranslationRequest({
    required String text,
    @JsonKey(name: 'source_lang') required String sourceLang,
  }) = _TranslationRequest;

  factory TranslationRequest.fromJson(Map<String, dynamic> json) =>
      _$TranslationRequestFromJson(json);
}

@freezed
abstract class TranslationResponse with _$TranslationResponse {
  const factory TranslationResponse({
    @JsonKey(name: 'original_text') required String originalText,
    @JsonKey(name: 'translated_text') required String translatedText,
    @JsonKey(name: 'source_language') required String sourceLanguage,
    @JsonKey(name: 'detected_language') String? detectedLanguage,
    @JsonKey(name: 'model_used') @Default('gemini-2.5-flash') String modelUsed,
  }) = _TranslationResponse;

  factory TranslationResponse.fromJson(Map<String, dynamic> json) =>
      _$TranslationResponseFromJson(json);
}
