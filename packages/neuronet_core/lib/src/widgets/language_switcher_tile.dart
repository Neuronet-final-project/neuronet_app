import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../l10n/l10n_extensions.dart';

/// A tile that displays the current language and allows switching it.
class LanguageSwitcherTile extends ConsumerWidget {
  const LanguageSwitcherTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(l10nProvider);
    final l10nNotifier = ref.read(l10nProvider.notifier);
    final l10n = context.localizations;

    return ListTile(
      leading: const Icon(Icons.language_rounded),
      title: Text(l10n.language),
      subtitle: Text(l10nNotifier.getDisplayName(currentLocale)),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => _showLanguagePicker(context, ref),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final l10nNotifier = ref.read(l10nProvider.notifier);
    final l10n = context.localizations;
    final supportedLocales = l10nNotifier.getSupportedLocales();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.6,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    l10n.selectLanguage,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: supportedLocales.length,
                      itemBuilder: (context, index) {
                        final locale = supportedLocales[index];
                        final isSelected = ref.watch(l10nProvider).languageCode == locale.languageCode;
                        return ListTile(
                          title: Text(l10nNotifier.getDisplayName(locale)),
                          trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Colors.green) : null,
                          onTap: () {
                            ref.read(l10nProvider.notifier).setLocale(locale);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
