import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../theme/app_theme.dart';

/// A dropdown button that allows users to select their preferred language.
class LanguagePickerDropdown extends ConsumerWidget {
  final Color? textColor;
  final Color? iconColor;

  const LanguagePickerDropdown({
    super.key,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(l10nProvider);
    final l10nNotifier = ref.read(l10nProvider.notifier);
    final supportedLocales = l10nNotifier.getSupportedLocales();

    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: currentLocale,
        icon: Icon(Icons.language_rounded, color: iconColor ?? NeuroColors.onSurfaceVariant, size: 20),
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            ref.read(l10nProvider.notifier).setLocale(newLocale);
          }
        },
        items: supportedLocales.map((Locale locale) {
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Text(
              l10nNotifier.getDisplayName(locale),
              style: TextStyle(
                color: textColor ?? NeuroColors.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
