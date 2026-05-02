import 'package:flutter/widgets.dart';
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
