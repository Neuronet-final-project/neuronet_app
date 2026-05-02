import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../errors/failures.dart';

part 'l10n_service.g.dart';

@Riverpod(keepAlive: true)
class L10n extends _$L10n {
  static const String _localePrefKey = 'app_locale';

  /// Supported locales in the app.
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('am'), // Amharic
    Locale('om'), // Oromiffa
    Locale('es'), // Spanish
  ];

  /// Default locale for the app.
  static const Locale defaultLocale = Locale('en');

  /// Map of locale language codes to display names (in their own language).
  static const Map<String, String> localeDisplayNames = {
    'en': 'English',
    'am': 'አማርኛ',
    'om': 'Afaan Oromoo',
    'es': 'Español',
  };

  @override
  Locale build() {
    // We'll initialize this properly in an initialize method
    // For now, return default or what we can
    return defaultLocale;
  }

  /// Checks if RTL (right-to-left) layout is enabled for the current locale.
  bool get isRtl => _isRtlLocale(state);

  /// Checks if a locale is RTL.
  bool _isRtlLocale(Locale locale) {
    return const {'ar', 'ur', 'he', 'fa'}.contains(locale.languageCode);
  }

  /// Initializes the service by loading persisted locale from shared preferences.
  Future<Locale> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString(_localePrefKey);

      if (savedLocale != null) {
        final locale = Locale(savedLocale);
        if (_isSupported(locale)) {
          state = locale;
          debugPrint('[L10n] Loaded saved locale: $savedLocale');
          return locale;
        }
      }

      state = defaultLocale;
      debugPrint('[L10n] Using default locale: ${defaultLocale.languageCode}');
      return defaultLocale;
    } catch (e) {
      debugPrint('[L10n] Error initializing: $e');
      state = defaultLocale;
      return defaultLocale;
    }
  }

  /// Sets the current app locale and persists it.
  Future<Result<Locale>> setLocale(Locale locale) async {
    if (!_isSupported(locale)) {
      return Result.failure(
        ValidationFailure(
          message: 'Locale ${locale.languageCode} is not supported',
          fieldErrors: {'locale': 'Unsupported locale'},
        ),
      );
    }

    try {
      state = locale;

      // Persist the locale preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localePrefKey, locale.languageCode);

      debugPrint('[L10n] Locale set to: ${locale.languageCode}');
      return Result.success(locale);
    } catch (e) {
      debugPrint('[L10n] Error setting locale: $e');
      return Result.failure(
        ValidationFailure(
          message: 'Failed to save locale preference',
        ),
      );
    }
  }

  /// Sets the locale by language code string.
  Future<Result<Locale>> setLocaleByCode(String languageCode) async {
    return setLocale(Locale(languageCode));
  }

  /// Gets the display name for a locale in the current app language.
  String getDisplayName(Locale locale) {
    return localeDisplayNames[locale.languageCode] ?? locale.languageCode;
  }

  /// Gets the display name for the current locale.
  String getCurrentDisplayName() {
    return getDisplayName(state);
  }

  /// Checks if a locale is in the supported list.
  bool isSupported(Locale locale) {
    return supportedLocales.any((l) => l.languageCode == locale.languageCode);
  }

  bool _isSupported(Locale locale) {
    return isSupported(locale);
  }

  /// Returns a list of supported locales sorted by display name.
  List<Locale> getSupportedLocales() {
    return List.from(supportedLocales);
  }

  /// Clears the persisted locale preference.
  Future<Result<bool>> clearPersistedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localePrefKey);
      state = defaultLocale;
      debugPrint('[L10n] Cleared persisted locale preference');
      return const Result.success(true);
    } catch (e) {
      debugPrint('[L10n] Error clearing locale preference: $e');
      return Result.failure(
        ValidationFailure(
          message: 'Failed to clear locale preference',
        ),
      );
    }
  }

  /// Resolves the best supported locale from a list of preferred locales.
  Locale resolveBestSupportedLocale(List<Locale> preferredLocales) {
    for (final preferred in preferredLocales) {
      if (supportedLocales.any((l) => l.languageCode == preferred.languageCode)) {
        return Locale(preferred.languageCode);
      }
    }
    return defaultLocale;
  }
}

