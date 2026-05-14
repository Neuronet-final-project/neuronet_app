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

/// Extension to provide localized labels for [AccountStatus].
extension AccountStatusL10n on AccountStatus {
  /// Returns the localized label for this account status.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        AccountStatus.active => l10n.statusActive,
        AccountStatus.inactive => l10n.statusInactive,
        AccountStatus.suspended => l10n.statusSuspended,
        AccountStatus.pendingActivation => l10n.statusPendingActivation,
      };
}

/// Extension to provide localized labels for [ConsentType].
extension ConsentTypeL10n on ConsentType {
  /// Returns the localized label for this consent type.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ConsentType.shareAiSummaries => l10n.aiInsightsSummaries,
        ConsentType.shareAlerts => l10n.safetyAlerts,
        ConsentType.participation => l10n.generalParticipation,
        ConsentType.counselorChat => l10n.directMessaging,
      };

  /// Returns the localized description for this consent type.
  String localizedDescription(AppLocalizations l10n) => switch (this) {
        ConsentType.shareAiSummaries => l10n.aiInsightsSummariesDesc,
        ConsentType.shareAlerts => l10n.safetyAlertsDesc,
        ConsentType.participation => l10n.generalParticipationDesc,
        ConsentType.counselorChat => l10n.directMessagingDesc,
      };
}

/// Extension to provide localized labels for [RelationshipType].
extension RelationshipTypeL10n on RelationshipType {
  /// Returns the localized label for this relationship type.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        RelationshipType.parent => l10n.parent,
        RelationshipType.legalGuardian => l10n.legalGuardian,
        RelationshipType.other => l10n.other,
      };
}
