import 'package:flutter/widgets.dart';
import '../models/enums.dart';
import 'app_localizations.dart';

/// Extensions on [AppLocalizations] for convenient access to localized strings.
///
/// Example:
/// ```dart
/// context.localizations.someKey
/// ```
extension L10nExtensions on BuildContext {
  /// Shortcut to access [AppLocalizations] of this [BuildContext].
  AppLocalizations get localizations => AppLocalizations.of(this)!;
}

/// Extension to provide localized labels for [MoodType].
extension MoodTypeL10n on MoodType {
  /// Returns the localized label for this mood.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        MoodType.happy => l10n.moodHappy,
        MoodType.sad => l10n.moodSad,
        MoodType.anxious => l10n.moodAnxious,
        MoodType.calm => l10n.moodCalm,
        MoodType.stressed => l10n.moodStressed,
        MoodType.neutral => l10n.moodNeutral,
        MoodType.excited => l10n.moodExcited,
        MoodType.tired => l10n.moodTired,
        MoodType.angry => l10n.moodAngry,
        MoodType.hopeful => l10n.moodHopeful,
      };
}
