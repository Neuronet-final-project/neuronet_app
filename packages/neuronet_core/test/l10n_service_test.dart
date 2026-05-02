import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('L10n', () {
    test('initializes with default locale when no saved preference', () async {
      final locale = await container.read(l10nProvider.notifier).initialize();
      expect(locale.languageCode, 'en');
      expect(container.read(l10nProvider).languageCode, 'en');
    });

    test('initializes with saved locale preference', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'es'});
      final locale = await container.read(l10nProvider.notifier).initialize();
      expect(locale.languageCode, 'es');
      expect(container.read(l10nProvider).languageCode, 'es');
    });

    test('initialize uses default locale for unsupported saved locale', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'xx'});
      final locale = await container.read(l10nProvider.notifier).initialize();
      expect(locale.languageCode, 'en');
      expect(container.read(l10nProvider).languageCode, 'en');
    });

    test('setLocale succeeds for supported locale', () async {
      await container.read(l10nProvider.notifier).initialize();
      final result = await container.read(l10nProvider.notifier).setLocale(const Locale('fr'));
      expect(result.isSuccess, true);
      expect(result.value.languageCode, 'fr');
      expect(container.read(l10nProvider).languageCode, 'fr');
    });

    test('setLocale fails for unsupported locale', () async {
      await container.read(l10nProvider.notifier).initialize();
      final result = await container.read(l10nProvider.notifier).setLocale(const Locale('xx'));
      expect(result.isFailure, true);
      expect(result.failure, isA<ValidationFailure>());
      // Locale should not change
      expect(container.read(l10nProvider).languageCode, 'en');
    });

    test('setLocaleByCode succeeds for supported locale', () async {
      await container.read(l10nProvider.notifier).initialize();
      final result = await container.read(l10nProvider.notifier).setLocaleByCode('de');
      expect(result.isSuccess, true);
      expect(result.value.languageCode, 'de');
      expect(container.read(l10nProvider).languageCode, 'de');
    });

    test('getDisplayName returns correct display names', () {
      final notifier = container.read(l10nProvider.notifier);
      expect(notifier.getDisplayName(const Locale('en')), 'English');
      expect(notifier.getDisplayName(const Locale('es')), 'Español');
      expect(notifier.getDisplayName(const Locale('fr')), 'Français');
      expect(notifier.getDisplayName(const Locale('de')), 'Deutsch');
      expect(notifier.getDisplayName(const Locale('ar')), 'العربية');
      expect(notifier.getDisplayName(const Locale('ur')), 'اردو');
    });

    test('isRtl returns true for RTL locales', () async {
      await container.read(l10nProvider.notifier).setLocaleByCode('ar');
      expect(container.read(l10nProvider.notifier).isRtl, true);
      await container.read(l10nProvider.notifier).setLocaleByCode('ur');
      expect(container.read(l10nProvider.notifier).isRtl, true);
    });

    test('clearPersistedLocale resets to default locale', () async {
      await container.read(l10nProvider.notifier).setLocaleByCode('fr');
      expect(container.read(l10nProvider).languageCode, 'fr');
      
      final result = await container.read(l10nProvider.notifier).clearPersistedLocale();
      expect(result.isSuccess, true);
      expect(container.read(l10nProvider).languageCode, 'en');
    });
  });
}
