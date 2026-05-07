import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../theme/app_theme.dart';

/// A dropdown button that allows users to select their preferred language.
class LanguagePickerDropdown extends ConsumerWidget {
  final Color? textColor;
  final Color? iconColor;
  final Color? dropdownColor;
  final Color? itemTextColor;

  const LanguagePickerDropdown({
    super.key,
    this.textColor,
    this.iconColor,
    this.dropdownColor,
    this.itemTextColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(l10nProvider);
    final l10nNotifier = ref.read(l10nProvider.notifier);
    final supportedLocales = l10nNotifier.getSupportedLocales();

    return DropdownButtonHideUnderline(
      child: DropdownButton<Locale>(
        value: currentLocale,
        dropdownColor: dropdownColor ?? NeuroColors.surface,
        icon: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Icon(
            Icons.translate_rounded,
            color: iconColor ?? NeuroColors.onSurfaceVariant,
            size: 18,
          ),
        ),
        elevation: 16,
        borderRadius: BorderRadius.circular(16),
        alignment: AlignmentDirectional.centerEnd,
        isDense: true,
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            ref.read(l10nProvider.notifier).setLocale(newLocale);
          }
        },
        items: supportedLocales.map((Locale locale) {
          final isSelected = locale.languageCode == currentLocale.languageCode;
          return DropdownMenuItem<Locale>(
            value: locale,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                l10nNotifier.getDisplayName(locale),
                style: TextStyle(
                  color: isSelected
                      ? (textColor ?? NeuroColors.adolescentPrimary)
                      : (itemTextColor ?? NeuroColors.onSurface),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
