/// NEURONET Localization — AppLocalizations, delegates, and extensions.
library;

export 'src/l10n/app_localizations.dart';
export 'src/l10n/l10n_extensions.dart';
export 'src/l10n/fallback_l10n.dart';

import 'package:flutter/widgets.dart';
import 'src/l10n/app_localizations.dart';
import 'src/l10n/fallback_l10n.dart';

/// Combined localization delegates for NEURONET apps, including fallbacks for unsupported locales.
List<LocalizationsDelegate<dynamic>> get neuroLocalizationsDelegates => [
      ...AppLocalizations.localizationsDelegates,
      const FallbackMaterialLocalizationsDelegate(),
      const FallbackCupertinoLocalizationsDelegate(),
    ];

