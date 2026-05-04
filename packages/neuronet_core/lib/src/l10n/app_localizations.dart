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

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @showOriginal.
  ///
  /// In en, this message translates to:
  /// **'Show Original'**
  String get showOriginal;

  /// No description provided for @translating.
  ///
  /// In en, this message translates to:
  /// **'Translating...'**
  String get translating;

  /// No description provided for @translationError.
  ///
  /// In en, this message translates to:
  /// **'Failed to translate'**
  String get translationError;

  /// No description provided for @failedToLoadJournals.
  ///
  /// In en, this message translates to:
  /// **'Error loading journals'**
  String get failedToLoadJournals;

  /// No description provided for @yourJournalAwaits.
  ///
  /// In en, this message translates to:
  /// **'Your journal awaits'**
  String get yourJournalAwaits;

  /// No description provided for @captureHowYouFeel.
  ///
  /// In en, this message translates to:
  /// **'Capture how you feel in a private space.\nTap compose when you are ready.'**
  String get captureHowYouFeel;

  /// No description provided for @secureJournalTag.
  ///
  /// In en, this message translates to:
  /// **'YOUR SECURE JOURNAL'**
  String get secureJournalTag;

  /// No description provided for @refreshingJournal.
  ///
  /// In en, this message translates to:
  /// **'Refreshing journal...'**
  String get refreshingJournal;

  /// No description provided for @stillSyncingEntry.
  ///
  /// In en, this message translates to:
  /// **'Still syncing this entry to the server...'**
  String get stillSyncingEntry;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get thisWeek;

  /// No description provided for @memoriesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 MEMORY} other{{count} MEMORIES}}'**
  String memoriesCount(int count);

  /// No description provided for @openingYourEntry.
  ///
  /// In en, this message translates to:
  /// **'Opening your entry...'**
  String get openingYourEntry;

  /// No description provided for @couldNotOpenShare.
  ///
  /// In en, this message translates to:
  /// **'Could not open share. Text copied to clipboard instead.'**
  String get couldNotOpenShare;

  /// No description provided for @journalNotFound.
  ///
  /// In en, this message translates to:
  /// **'Journal not found'**
  String get journalNotFound;

  /// No description provided for @journalSubject.
  ///
  /// In en, this message translates to:
  /// **'My journal entry'**
  String get journalSubject;

  /// No description provided for @pleaseWriteSomething.
  ///
  /// In en, this message translates to:
  /// **'Please write something first'**
  String get pleaseWriteSomething;

  /// No description provided for @journalSaved.
  ///
  /// In en, this message translates to:
  /// **'Your journal was saved.'**
  String get journalSaved;

  /// No description provided for @newEntryTag.
  ///
  /// In en, this message translates to:
  /// **'NEW ENTRY'**
  String get newEntryTag;

  /// No description provided for @safeSpaceNote.
  ///
  /// In en, this message translates to:
  /// **'This is your safe space. Write what you feel today.'**
  String get safeSpaceNote;

  /// No description provided for @journalTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Give it a title...'**
  String get journalTitleHint;

  /// No description provided for @journalContentHint.
  ///
  /// In en, this message translates to:
  /// **'Start writing your thoughts here...'**
  String get journalContentHint;

  /// No description provided for @sparkSmile.
  ///
  /// In en, this message translates to:
  /// **'What made me smile today?'**
  String get sparkSmile;

  /// No description provided for @sparkGrateful.
  ///
  /// In en, this message translates to:
  /// **'One thing I\'m grateful for'**
  String get sparkGrateful;

  /// No description provided for @sparkVictory.
  ///
  /// In en, this message translates to:
  /// **'A small victory I had'**
  String get sparkVictory;

  /// No description provided for @sparkChallenge.
  ///
  /// In en, this message translates to:
  /// **'How I handled a challenge'**
  String get sparkChallenge;

  /// No description provided for @discoverHeader.
  ///
  /// In en, this message translates to:
  /// **'DISCOVER'**
  String get discoverHeader;

  /// No description provided for @searchMemoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Search memories...'**
  String get searchMemoriesHint;

  /// No description provided for @filterWhen.
  ///
  /// In en, this message translates to:
  /// **'WHEN'**
  String get filterWhen;

  /// No description provided for @filterMood.
  ///
  /// In en, this message translates to:
  /// **'MOOD'**
  String get filterMood;

  /// No description provided for @filterResults.
  ///
  /// In en, this message translates to:
  /// **'RESULTS ({count})'**
  String filterResults(int count);

  /// No description provided for @stillLooking.
  ///
  /// In en, this message translates to:
  /// **'Still looking...'**
  String get stillLooking;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get filterToday;

  /// No description provided for @filterThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get filterThisWeek;

  /// No description provided for @filterSpecific.
  ///
  /// In en, this message translates to:
  /// **'Specific Date'**
  String get filterSpecific;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @aboutJournalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'About journal privacy'**
  String get aboutJournalPrivacy;

  /// No description provided for @journalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal privacy'**
  String get journalPrivacyTitle;

  /// No description provided for @journalPrivacyContent.
  ///
  /// In en, this message translates to:
  /// **'Your journal entries are stored securely for your account. The app is designed so your raw journal text is not shown to guardians or counselors. If you ever use optional features that analyze mood in aggregate, those are described in your consent settings.'**
  String get journalPrivacyContent;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @backToJournal.
  ///
  /// In en, this message translates to:
  /// **'Back to journal'**
  String get backToJournal;

  /// No description provided for @entryRemovedNote.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed or this link is outdated.'**
  String get entryRemovedNote;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @moodLabel.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodLabel;

  /// No description provided for @wordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get wordsLabel;

  /// No description provided for @readLabel.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readLabel;

  /// No description provided for @tipLongPress.
  ///
  /// In en, this message translates to:
  /// **'Tip: long-press your entry below to select text or copy a favorite line.'**
  String get tipLongPress;

  /// No description provided for @yourPrivateSpace.
  ///
  /// In en, this message translates to:
  /// **'Your private space'**
  String get yourPrivateSpace;

  /// No description provided for @privateSpaceNote.
  ///
  /// In en, this message translates to:
  /// **'This entry stays on your account for you. Guardians and counselors do not read your journal text.'**
  String get privateSpaceNote;

  /// No description provided for @copyEntry.
  ///
  /// In en, this message translates to:
  /// **'Copy entry'**
  String get copyEntry;

  /// No description provided for @titleAndFullText.
  ///
  /// In en, this message translates to:
  /// **'Title and full text'**
  String get titleAndFullText;

  /// No description provided for @writingSparksTag.
  ///
  /// In en, this message translates to:
  /// **'WRITING SPARKS'**
  String get writingSparksTag;

  /// No description provided for @howAreYouFeelingNow.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling right now?'**
  String get howAreYouFeelingNow;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @syncingTag.
  ///
  /// In en, this message translates to:
  /// **'SYNCING'**
  String get syncingTag;

  /// No description provided for @shareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTooltip;

  /// No description provided for @moreTooltip.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTooltip;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodCalm.
  ///
  /// In en, this message translates to:
  /// **'Calm'**
  String get moodCalm;

  /// No description provided for @moodStressed.
  ///
  /// In en, this message translates to:
  /// **'Stressed'**
  String get moodStressed;

  /// No description provided for @moodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get moodNeutral;

  /// No description provided for @moodExcited.
  ///
  /// In en, this message translates to:
  /// **'Excited'**
  String get moodExcited;

  /// No description provided for @moodTired.
  ///
  /// In en, this message translates to:
  /// **'Tired'**
  String get moodTired;

  /// No description provided for @moodAngry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get moodAngry;

  /// No description provided for @moodHopeful.
  ///
  /// In en, this message translates to:
  /// **'Hopeful'**
  String get moodHopeful;

  /// No description provided for @dailyCheckInTag.
  ///
  /// In en, this message translates to:
  /// **'YOUR DAILY CHECK-IN'**
  String get dailyCheckInTag;

  /// No description provided for @tapEmojiPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the emoji that best captures your current mood.'**
  String get tapEmojiPrompt;

  /// No description provided for @intensityLabel.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensityLabel;

  /// No description provided for @mildLabel.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get mildLabel;

  /// No description provided for @strongLabel.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get strongLabel;

  /// No description provided for @moodReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'What\'s making you feel this way?'**
  String get moodReasonPrompt;

  /// No description provided for @moodNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a quick note... (Optional)'**
  String get moodNoteHint;

  /// No description provided for @logMoodButton.
  ///
  /// In en, this message translates to:
  /// **'Log This Mood'**
  String get logMoodButton;

  /// No description provided for @moodLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Mood Logged!'**
  String get moodLoggedSuccess;

  /// No description provided for @thanksCheckingIn.
  ///
  /// In en, this message translates to:
  /// **'Thanks for checking in.\nTracking how you feel helps you understand yourself better.'**
  String get thanksCheckingIn;

  /// No description provided for @logAnotherMood.
  ///
  /// In en, this message translates to:
  /// **'Log another mood'**
  String get logAnotherMood;

  /// No description provided for @pastCheckInsHeader.
  ///
  /// In en, this message translates to:
  /// **'Past Check-ins'**
  String get pastCheckInsHeader;

  /// No description provided for @failedToLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load history'**
  String get failedToLoadHistory;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @minAbbr.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minAbbr;

  /// No description provided for @hourAbbr.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hourAbbr;

  /// No description provided for @dayAbbr.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get dayAbbr;

  /// No description provided for @levelAbbr.
  ///
  /// In en, this message translates to:
  /// **'Lvl'**
  String get levelAbbr;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @typing.
  ///
  /// In en, this message translates to:
  /// **'Typing...'**
  String get typing;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @aiAssistantInfo.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant Information'**
  String get aiAssistantInfo;

  /// No description provided for @safetyFirst.
  ///
  /// In en, this message translates to:
  /// **'Safety First'**
  String get safetyFirst;

  /// No description provided for @safetyFirstDesc.
  ///
  /// In en, this message translates to:
  /// **'This AI is for support and reflection, not for medical diagnosis or crisis intervention.'**
  String get safetyFirstDesc;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your Data'**
  String get yourData;

  /// No description provided for @yourDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Conversations are analyzed to provide support and may be reviewed by your school counselor.'**
  String get yourDataDesc;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to Use'**
  String get howToUse;

  /// No description provided for @howToUseDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask about stress management, study tips, or just chat about your day.'**
  String get howToUseDesc;

  /// No description provided for @aboutAiAssistant.
  ///
  /// In en, this message translates to:
  /// **'About AI Assistant'**
  String get aboutAiAssistant;

  /// No description provided for @unableConnectAi.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to AI Assistant'**
  String get unableConnectAi;

  /// No description provided for @checkInternetTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get checkInternetTryAgain;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a Conversation'**
  String get startConversation;

  /// No description provided for @aiEmptyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about your well-being.\nI\'m here to help you reflect.'**
  String get aiEmptyPrompt;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant is thinking...'**
  String get aiThinking;

  /// No description provided for @aiSafetyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant can support your reflection but is not a medical professional. For urgent help, please contact your counselor.'**
  String get aiSafetyDisclaimer;

  /// No description provided for @aiSenderLabel.
  ///
  /// In en, this message translates to:
  /// **'NEURO Assistant'**
  String get aiSenderLabel;

  /// No description provided for @youSenderLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youSenderLabel;

  /// No description provided for @aiPrompt1.
  ///
  /// In en, this message translates to:
  /// **'What can you help me with?'**
  String get aiPrompt1;

  /// No description provided for @aiPrompt2.
  ///
  /// In en, this message translates to:
  /// **'How do I add a journal entry?'**
  String get aiPrompt2;

  /// No description provided for @aiPrompt3.
  ///
  /// In en, this message translates to:
  /// **'Who can see my data?'**
  String get aiPrompt3;

  /// No description provided for @aiPrompt4.
  ///
  /// In en, this message translates to:
  /// **'How do I contact my counselor?'**
  String get aiPrompt4;
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
