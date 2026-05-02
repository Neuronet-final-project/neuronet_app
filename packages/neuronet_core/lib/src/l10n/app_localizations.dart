import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_om.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('es'),
    Locale('om'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'NEURONET'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @journal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journal;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @failedToLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get failedToLoadDashboard;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @allMoods.
  ///
  /// In en, this message translates to:
  /// **'All moods →'**
  String get allMoods;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentJournals.
  ///
  /// In en, this message translates to:
  /// **'Recent Journals'**
  String get recentJournals;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all →'**
  String get viewAll;

  /// No description provided for @personalInsight.
  ///
  /// In en, this message translates to:
  /// **'Personal Insight'**
  String get personalInsight;

  /// No description provided for @weGotYou.
  ///
  /// In en, this message translates to:
  /// **'We\'ve got you 💙'**
  String get weGotYou;

  /// No description provided for @tryThisToday.
  ///
  /// In en, this message translates to:
  /// **'Try This Today'**
  String get tryThisToday;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More →'**
  String get more;

  /// No description provided for @recommendedForYou.
  ///
  /// In en, this message translates to:
  /// **'Recommended for You'**
  String get recommendedForYou;

  /// No description provided for @playAndRelax.
  ///
  /// In en, this message translates to:
  /// **'Play & Relax'**
  String get playAndRelax;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newTag;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @privacyAndPermissions.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Permissions'**
  String get privacyAndPermissions;

  /// No description provided for @consentStatus.
  ///
  /// In en, this message translates to:
  /// **'Consent Status'**
  String get consentStatus;

  /// No description provided for @viewConsentDescription.
  ///
  /// In en, this message translates to:
  /// **'View what your guardian has approved'**
  String get viewConsentDescription;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @adolescent.
  ///
  /// In en, this message translates to:
  /// **'ADOLESCENT'**
  String get adolescent;

  /// No description provided for @heyUser.
  ///
  /// In en, this message translates to:
  /// **'Hey {name} 👋'**
  String heyUser(String name);

  /// No description provided for @innerWorldPrompt.
  ///
  /// In en, this message translates to:
  /// **'How\'s your inner world today?'**
  String get innerWorldPrompt;

  /// No description provided for @writeJournal.
  ///
  /// In en, this message translates to:
  /// **'Write Journal'**
  String get writeJournal;

  /// No description provided for @expressYourself.
  ///
  /// In en, this message translates to:
  /// **'Express yourself 📝'**
  String get expressYourself;

  /// No description provided for @aiCompanion.
  ///
  /// In en, this message translates to:
  /// **'AI Companion'**
  String get aiCompanion;

  /// No description provided for @talkItOut.
  ///
  /// In en, this message translates to:
  /// **'Talk it out 🤖'**
  String get talkItOut;

  /// No description provided for @checkYourMood.
  ///
  /// In en, this message translates to:
  /// **'Check Your Mood'**
  String get checkYourMood;

  /// No description provided for @moodEmojiPrompt.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling? 😊'**
  String get moodEmojiPrompt;

  /// No description provided for @learnAndGrow.
  ///
  /// In en, this message translates to:
  /// **'Learn & Grow'**
  String get learnAndGrow;

  /// No description provided for @exploreResources.
  ///
  /// In en, this message translates to:
  /// **'Explore resources 📚'**
  String get exploreResources;

  /// No description provided for @smallCheckIn.
  ///
  /// In en, this message translates to:
  /// **'A small check-in goes a long way.'**
  String get smallCheckIn;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get today;

  /// No description provided for @take30Seconds.
  ///
  /// In en, this message translates to:
  /// **'Take 30 seconds.'**
  String get take30Seconds;

  /// No description provided for @namingFeelings.
  ///
  /// In en, this message translates to:
  /// **'Naming what you feel is half the work.\nWe\'ll help with the rest.'**
  String get namingFeelings;

  /// No description provided for @checkInNow.
  ///
  /// In en, this message translates to:
  /// **'Check in now'**
  String get checkInNow;

  /// No description provided for @journals.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get journals;

  /// No description provided for @moods.
  ///
  /// In en, this message translates to:
  /// **'Moods'**
  String get moods;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get forYou;

  /// No description provided for @journalToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get journalToday;

  /// No description provided for @journalYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get journalYesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @journalEntryDefault.
  ///
  /// In en, this message translates to:
  /// **'Journal Entry'**
  String get journalEntryDefault;

  /// No description provided for @feelingLabel.
  ///
  /// In en, this message translates to:
  /// **'Feeling {mood}'**
  String feelingLabel(String mood);

  /// No description provided for @minRead.
  ///
  /// In en, this message translates to:
  /// **'{count} min read'**
  String minRead(int count);

  /// No description provided for @readNow.
  ///
  /// In en, this message translates to:
  /// **'Read now'**
  String get readNow;

  /// No description provided for @mindfulnessGames.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness Games'**
  String get mindfulnessGames;

  /// No description provided for @boostYourMood.
  ///
  /// In en, this message translates to:
  /// **'Boost your mood with fun, science-backed activities.'**
  String get boostYourMood;

  /// No description provided for @playNow.
  ///
  /// In en, this message translates to:
  /// **'Play Now'**
  String get playNow;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @alertNotifications.
  ///
  /// In en, this message translates to:
  /// **'Alert Notifications'**
  String get alertNotifications;

  /// No description provided for @counselorMessages.
  ///
  /// In en, this message translates to:
  /// **'Counselor Messages'**
  String get counselorMessages;

  /// No description provided for @getNotifiedPatterns.
  ///
  /// In en, this message translates to:
  /// **'Get notified when patterns are detected'**
  String get getNotifiedPatterns;

  /// No description provided for @pushNotificationsNewMessages.
  ///
  /// In en, this message translates to:
  /// **'Push notifications for new messages'**
  String get pushNotificationsNewMessages;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @guardian.
  ///
  /// In en, this message translates to:
  /// **'Guardian'**
  String get guardian;

  /// No description provided for @areYouSureSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureSignOut;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en', 'es', 'om'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'om':
      return AppLocalizationsOm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
