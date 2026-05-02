import 'package:flutter/widgets.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'l10n_provider.g.dart';

@riverpod
Locale currentLocale(Ref ref) {
  return ref.watch(l10nProvider);
}

@riverpod
List<Locale> supportedLocales(Ref ref) {
  return L10n.supportedLocales;
}

@riverpod
String currentLocaleDisplayName(Ref ref) {
  final locale = ref.watch(l10nProvider);
  return L10n.localeDisplayNames[locale.languageCode] ?? locale.languageCode;
}

@riverpod
bool isRtl(Ref ref) {
  return ref.watch(l10nProvider.notifier).isRtl;
}

@riverpod
String localeLanguageCode(Ref ref) {
  return ref.watch(l10nProvider).languageCode;
}

@riverpod
bool isLocaleSupported(Ref ref, Locale locale) {
  return ref.read(l10nProvider.notifier).isSupported(locale);
}