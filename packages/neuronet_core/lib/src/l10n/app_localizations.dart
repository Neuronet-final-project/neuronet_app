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
  /// **'Recommended for you:'**
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
  /// **'Today'**
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
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
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
  /// **'{count, plural, =0{No results} =1{1 result} other{{count} results}}'**
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

  /// No description provided for @requestApproval.
  ///
  /// In en, this message translates to:
  /// **'Request Approval'**
  String get requestApproval;

  /// No description provided for @checkingApprovalStatus.
  ///
  /// In en, this message translates to:
  /// **'Checking approval status...'**
  String get checkingApprovalStatus;

  /// No description provided for @approvalRequest.
  ///
  /// In en, this message translates to:
  /// **'Approval Request'**
  String get approvalRequest;

  /// No description provided for @approvalPending.
  ///
  /// In en, this message translates to:
  /// **'Approval Pending'**
  String get approvalPending;

  /// No description provided for @approvalPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your approval request for {counselorName} is already pending.'**
  String approvalPendingMessage(String counselorName);

  /// No description provided for @guardianReviewingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your guardian is reviewing your request. You\'ll be notified once they respond.'**
  String get guardianReviewingMessage;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSent;

  /// No description provided for @requestSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request Sent!'**
  String get requestSentSuccess;

  /// No description provided for @approvalSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Your approval request has been sent to your guardian.'**
  String get approvalSentMessage;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Status: Pending'**
  String get statusPending;

  /// No description provided for @backToChat.
  ///
  /// In en, this message translates to:
  /// **'Back to Chat'**
  String get backToChat;

  /// No description provided for @guardianApprovalRequired.
  ///
  /// In en, this message translates to:
  /// **'Guardian Approval Required'**
  String get guardianApprovalRequired;

  /// No description provided for @guardianApprovalExplanation.
  ///
  /// In en, this message translates to:
  /// **'To communicate with a counselor, you need approval from your guardian. Please explain why you would like to talk to this counselor.'**
  String get guardianApprovalExplanation;

  /// No description provided for @counselorLabel.
  ///
  /// In en, this message translates to:
  /// **'Counselor'**
  String get counselorLabel;

  /// No description provided for @reasonForRequest.
  ///
  /// In en, this message translates to:
  /// **'Reason for Request'**
  String get reasonForRequest;

  /// No description provided for @reasonHint.
  ///
  /// In en, this message translates to:
  /// **'Explain why you would like to talk to this counselor...'**
  String get reasonHint;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for your request'**
  String get reasonRequired;

  /// No description provided for @reasonMinLength.
  ///
  /// In en, this message translates to:
  /// **'Please provide more details (at least 20 characters)'**
  String get reasonMinLength;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @unableToGetUserInfo.
  ///
  /// In en, this message translates to:
  /// **'Unable to get user information. Please try again.'**
  String get unableToGetUserInfo;

  /// No description provided for @pendingRequestExists.
  ///
  /// In en, this message translates to:
  /// **'You already have a pending approval request for this counselor.'**
  String get pendingRequestExists;

  /// No description provided for @alreadyPending.
  ///
  /// In en, this message translates to:
  /// **'already pending'**
  String get alreadyPending;

  /// No description provided for @approvalRequestAlreadyPending.
  ///
  /// In en, this message translates to:
  /// **'Approval request already pending'**
  String get approvalRequestAlreadyPending;

  /// No description provided for @profileNotFound.
  ///
  /// In en, this message translates to:
  /// **'User profile not found.'**
  String get profileNotFound;

  /// No description provided for @adolescentAccount.
  ///
  /// In en, this message translates to:
  /// **'Adolescent Account'**
  String get adolescentAccount;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @statusPendingActivation.
  ///
  /// In en, this message translates to:
  /// **'Pending Activation'**
  String get statusPendingActivation;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'NeuroNet v{version}'**
  String appVersion(String version);

  /// No description provided for @guardianAppVersion.
  ///
  /// In en, this message translates to:
  /// **'NeuroNet Guardian v{version}'**
  String guardianAppVersion(String version);

  /// No description provided for @profileNotFoundUser.
  ///
  /// In en, this message translates to:
  /// **'No user profile found.'**
  String get profileNotFoundUser;

  /// No description provided for @accountActivatedLogin.
  ///
  /// In en, this message translates to:
  /// **'Account activated! Please login.'**
  String get accountActivatedLogin;

  /// No description provided for @activateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate Account'**
  String get activateAccountTitle;

  /// No description provided for @setUpSecureAccount.
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Secure Account'**
  String get setUpSecureAccount;

  /// No description provided for @activationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Use the activation code provided by your guardian to begin your journey.'**
  String get activationCodeHint;

  /// No description provided for @registeredEmail.
  ///
  /// In en, this message translates to:
  /// **'Registered Email'**
  String get registeredEmail;

  /// No description provided for @activationCode.
  ///
  /// In en, this message translates to:
  /// **'Activation Code'**
  String get activationCode;

  /// No description provided for @activationCodeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. NEURO-2026'**
  String get activationCodeExample;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @activateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Activate Account'**
  String get activateAccountButton;

  /// No description provided for @passwordPrivacyInfo.
  ///
  /// In en, this message translates to:
  /// **'Your password ensures your journal remains private and secure.'**
  String get passwordPrivacyInfo;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterActivationCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the activation code'**
  String get pleaseEnterActivationCode;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @discoverPages.
  ///
  /// In en, this message translates to:
  /// **'Discover Pages'**
  String get discoverPages;

  /// No description provided for @followedPages.
  ///
  /// In en, this message translates to:
  /// **'Followed Pages'**
  String get followedPages;

  /// No description provided for @pickedForYou.
  ///
  /// In en, this message translates to:
  /// **'Picked for You'**
  String get pickedForYou;

  /// No description provided for @aiPicks.
  ///
  /// In en, this message translates to:
  /// **'AI Picks'**
  String get aiPicks;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @analyzeNow.
  ///
  /// In en, this message translates to:
  /// **'Analyze Now'**
  String get analyzeNow;

  /// No description provided for @insightDetail.
  ///
  /// In en, this message translates to:
  /// **'Insight Detail'**
  String get insightDetail;

  /// No description provided for @channelNotFound.
  ///
  /// In en, this message translates to:
  /// **'Channel not found. Please try again later.'**
  String get channelNotFound;

  /// No description provided for @yourChannels.
  ///
  /// In en, this message translates to:
  /// **'Your Channels'**
  String get yourChannels;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @requestApprovalAgain.
  ///
  /// In en, this message translates to:
  /// **'Request Approval Again'**
  String get requestApprovalAgain;

  /// No description provided for @requestAgain.
  ///
  /// In en, this message translates to:
  /// **'Request Again'**
  String get requestAgain;

  /// No description provided for @goToYourChannels.
  ///
  /// In en, this message translates to:
  /// **'Go to Your Channels'**
  String get goToYourChannels;

  /// No description provided for @loginTagline1.
  ///
  /// In en, this message translates to:
  /// **'Your Emotional Support Space 💜'**
  String get loginTagline1;

  /// No description provided for @loginTagline2.
  ///
  /// In en, this message translates to:
  /// **'You are not alone in this 🌿'**
  String get loginTagline2;

  /// No description provided for @loginTagline3.
  ///
  /// In en, this message translates to:
  /// **'Every feeling is valid here ✨'**
  String get loginTagline3;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back 👋'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @newToNeuroNet.
  ///
  /// In en, this message translates to:
  /// **'New to NeuroNet?'**
  String get newToNeuroNet;

  /// No description provided for @activateMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Activate My Account'**
  String get activateMyAccount;

  /// No description provided for @dataPrivateEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Your data is private and encrypted'**
  String get dataPrivateEncrypted;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your Safe Space'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'A private place for your thoughts and feelings. Your journals are never seen by guardians or counselors.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Understand Your Trends'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Our AI helps you see patterns in your emotional journey over time, helping you grow with self-awareness.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Support, Not Diagnosis'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to support you. Our AI is an informational assistant, not a doctor or therapist.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Ready to Start?'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In en, this message translates to:
  /// **'Use the activation code provided by your guardian to unlock your personal emotional journey.'**
  String get onboardingDesc4;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet.'**
  String get noCommentsYet;

  /// No description provided for @discover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discover;

  /// No description provided for @myInsights.
  ///
  /// In en, this message translates to:
  /// **'My Insights'**
  String get myInsights;

  /// No description provided for @aiReflectiveQuest.
  ///
  /// In en, this message translates to:
  /// **'AI REFLECTIVE QUEST'**
  String get aiReflectiveQuest;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game Over!'**
  String get gameOver;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'START GAME'**
  String get startGame;

  /// No description provided for @startExercise.
  ///
  /// In en, this message translates to:
  /// **'Start Exercise'**
  String get startExercise;

  /// No description provided for @noInsightsYet.
  ///
  /// In en, this message translates to:
  /// **'No insights yet!'**
  String get noInsightsYet;

  /// No description provided for @keepJournalingDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep journaling and tracking your moods.\nWe\'ll share helpful patterns here.'**
  String get keepJournalingDesc;

  /// No description provided for @insightsHistory.
  ///
  /// In en, this message translates to:
  /// **'Insights History ({count})'**
  String insightsHistory(int count);

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'RECENT'**
  String get recent;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newLabel;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @failedToUploadVoice.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload voice message: {error}'**
  String failedToUploadVoice(String error);

  /// No description provided for @failedToUploadMedia.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload {type}: {error}'**
  String failedToUploadMedia(String type, String error);

  /// No description provided for @voiceCall.
  ///
  /// In en, this message translates to:
  /// **'Voice call'**
  String get voiceCall;

  /// No description provided for @videoCall.
  ///
  /// In en, this message translates to:
  /// **'Video call'**
  String get videoCall;

  /// No description provided for @refreshMessages.
  ///
  /// In en, this message translates to:
  /// **'Refresh messages'**
  String get refreshMessages;

  /// No description provided for @chatEnabledBanner.
  ///
  /// In en, this message translates to:
  /// **'Chat enabled - Your guardian has approved counselor communication'**
  String get chatEnabledBanner;

  /// No description provided for @chatDisabledBanner.
  ///
  /// In en, this message translates to:
  /// **'Chat disabled - Counselor communication consent required'**
  String get chatDisabledBanner;

  /// No description provided for @loadingConsent.
  ///
  /// In en, this message translates to:
  /// **'Checking permissions...'**
  String get loadingConsent;

  /// No description provided for @unableToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Unable to start chat.'**
  String get unableToStartChat;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessagesYet;

  /// No description provided for @startConversationWithCounselor.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your counselor.'**
  String get startConversationWithCounselor;

  /// No description provided for @counselorPrompt1.
  ///
  /// In en, this message translates to:
  /// **'I\'d like to talk about something'**
  String get counselorPrompt1;

  /// No description provided for @counselorPrompt2.
  ///
  /// In en, this message translates to:
  /// **'Can you help me with some concerns?'**
  String get counselorPrompt2;

  /// No description provided for @counselorPrompt3.
  ///
  /// In en, this message translates to:
  /// **'I need some guidance'**
  String get counselorPrompt3;

  /// No description provided for @deepBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Deep Breathing'**
  String get deepBreathingTitle;

  /// No description provided for @deepBreathingDesc.
  ///
  /// In en, this message translates to:
  /// **'A simple 4-4-4 rhythm to calm your mind and regulate your system.'**
  String get deepBreathingDesc;

  /// No description provided for @mindfulFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Mindful Focus'**
  String get mindfulFocusTitle;

  /// No description provided for @mindfulFocusDesc.
  ///
  /// In en, this message translates to:
  /// **'Train your attention by following the rhythmic movement of light.'**
  String get mindfulFocusDesc;

  /// No description provided for @moodMatcherTitle.
  ///
  /// In en, this message translates to:
  /// **'Mood Matcher'**
  String get moodMatcherTitle;

  /// No description provided for @moodMatcherDesc.
  ///
  /// In en, this message translates to:
  /// **'A fun pattern-matching game to sharpen your focus.'**
  String get moodMatcherDesc;

  /// No description provided for @aiQuestTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Reflective Quest'**
  String get aiQuestTitle;

  /// No description provided for @aiQuestDesc.
  ///
  /// In en, this message translates to:
  /// **'Embark on a personal journey of self-discovery powered by AI.'**
  String get aiQuestDesc;

  /// No description provided for @minCount.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String minCount(int count);

  /// No description provided for @learnersNook.
  ///
  /// In en, this message translates to:
  /// **'Learner\'s Nook'**
  String get learnersNook;

  /// No description provided for @browseTopics.
  ///
  /// In en, this message translates to:
  /// **'Browse Topics'**
  String get browseTopics;

  /// No description provided for @myFeed.
  ///
  /// In en, this message translates to:
  /// **'My Feed'**
  String get myFeed;

  /// No description provided for @unfollowedCategory.
  ///
  /// In en, this message translates to:
  /// **'Unfollowed {category}'**
  String unfollowedCategory(String category);

  /// No description provided for @followingCategory.
  ///
  /// In en, this message translates to:
  /// **'Following {category}'**
  String followingCategory(String category);

  /// No description provided for @noTopicsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No topics available'**
  String get noTopicsAvailable;

  /// No description provided for @checkBackSoonTopics.
  ///
  /// In en, this message translates to:
  /// **'Check back soon for new topics!'**
  String get checkBackSoonTopics;

  /// No description provided for @feedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your feed is empty'**
  String get feedEmpty;

  /// No description provided for @followTopicsToSeeArticles.
  ///
  /// In en, this message translates to:
  /// **'Follow some topics to see articles here!'**
  String get followTopicsToSeeArticles;

  /// No description provided for @articlesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} articles'**
  String articlesCount(int count);

  /// No description provided for @followersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} followers'**
  String followersCount(int count);

  /// No description provided for @readMoreAbout.
  ///
  /// In en, this message translates to:
  /// **'Read more about {title}'**
  String readMoreAbout(String title);

  /// No description provided for @searchPagesHint.
  ///
  /// In en, this message translates to:
  /// **'Search pages...'**
  String get searchPagesHint;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noPagesFound.
  ///
  /// In en, this message translates to:
  /// **'No pages found'**
  String get noPagesFound;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @noPagesInCategory.
  ///
  /// In en, this message translates to:
  /// **'No pages available in this category'**
  String get noPagesInCategory;

  /// No description provided for @followerCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 follower} other{{count} followers}}'**
  String followerCountLabel(int count);

  /// No description provided for @moodCategory.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodCategory;

  /// No description provided for @sleepCategory.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepCategory;

  /// No description provided for @stressCategory.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stressCategory;

  /// No description provided for @relationshipsCategory.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get relationshipsCategory;

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @counselorDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Counselor'**
  String get counselorDefaultName;

  /// No description provided for @counselorCredentialsDefault.
  ///
  /// In en, this message translates to:
  /// **'Licensed Clinical Psychologist'**
  String get counselorCredentialsDefault;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @partOfTopic.
  ///
  /// In en, this message translates to:
  /// **'Part of {category} topic'**
  String partOfTopic(String category);

  /// No description provided for @iveReadThis.
  ///
  /// In en, this message translates to:
  /// **'I\'ve read this!'**
  String get iveReadThis;

  /// No description provided for @noFollowedPages.
  ///
  /// In en, this message translates to:
  /// **'No followed pages yet'**
  String get noFollowedPages;

  /// No description provided for @startFollowingToSee.
  ///
  /// In en, this message translates to:
  /// **'Start following pages to see them here. Discover new content to follow!'**
  String get startFollowingToSee;

  /// No description provided for @couldNotLoadFollowedPages.
  ///
  /// In en, this message translates to:
  /// **'Could not load followed pages.'**
  String get couldNotLoadFollowedPages;

  /// No description provided for @couldNotLoadPageDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not load page details'**
  String get couldNotLoadPageDetails;

  /// No description provided for @byAuthor.
  ///
  /// In en, this message translates to:
  /// **'By {author}'**
  String byAuthor(String author);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String weeksAgo(int count);

  /// No description provided for @monthsAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String monthsAgo(int count);

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete! Check for new recommendations.'**
  String get analysisComplete;

  /// No description provided for @noNewRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No new recommendations at this time.'**
  String get noNewRecommendations;

  /// No description provided for @analyzingJourney.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your journey...'**
  String get analyzingJourney;

  /// No description provided for @noAiPicks.
  ///
  /// In en, this message translates to:
  /// **'No AI picks yet'**
  String get noAiPicks;

  /// No description provided for @aiPicksDesc.
  ///
  /// In en, this message translates to:
  /// **'Check back later for personalized recommendations.'**
  String get aiPicksDesc;

  /// No description provided for @couldNotLoadAiRecs.
  ///
  /// In en, this message translates to:
  /// **'Could not load AI recommendations.'**
  String get couldNotLoadAiRecs;

  /// No description provided for @noPicksYet.
  ///
  /// In en, this message translates to:
  /// **'No picks yet!'**
  String get noPicksYet;

  /// No description provided for @picksDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep journaling and exploring! Your personalized picks will appear here as we learn more about your journey.'**
  String get picksDesc;

  /// No description provided for @couldNotLoadPicks.
  ///
  /// In en, this message translates to:
  /// **'Could not load your picks.'**
  String get couldNotLoadPicks;

  /// No description provided for @aiPickLabel.
  ///
  /// In en, this message translates to:
  /// **'AI PICK'**
  String get aiPickLabel;

  /// No description provided for @smartPickLabel.
  ///
  /// In en, this message translates to:
  /// **'SMART PICK'**
  String get smartPickLabel;

  /// No description provided for @relatedArticle.
  ///
  /// In en, this message translates to:
  /// **'Related Article:'**
  String get relatedArticle;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorLabel(String message);

  /// No description provided for @channels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get channels;

  /// No description provided for @hideComments.
  ///
  /// In en, this message translates to:
  /// **'Hide comments'**
  String get hideComments;

  /// No description provided for @viewComments.
  ///
  /// In en, this message translates to:
  /// **'View comments'**
  String get viewComments;

  /// No description provided for @addCommentHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addCommentHint;

  /// No description provided for @refreshPostsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh posts'**
  String get refreshPostsTooltip;

  /// No description provided for @followingTooltip.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingTooltip;

  /// No description provided for @followTooltip.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followTooltip;

  /// No description provided for @reactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reaction} other{{count} reactions}}'**
  String reactionsCount(int count);

  /// No description provided for @privacyHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Hub'**
  String get privacyHubTitle;

  /// No description provided for @coreTransparency.
  ///
  /// In en, this message translates to:
  /// **'Core Transparency'**
  String get coreTransparency;

  /// No description provided for @sharingVisibility.
  ///
  /// In en, this message translates to:
  /// **'Sharing & Visibility'**
  String get sharingVisibility;

  /// No description provided for @personalGrowthData.
  ///
  /// In en, this message translates to:
  /// **'Personal Growth Data'**
  String get personalGrowthData;

  /// No description provided for @counselorAccess.
  ///
  /// In en, this message translates to:
  /// **'Counselor Access'**
  String get counselorAccess;

  /// No description provided for @oversightTitle.
  ///
  /// In en, this message translates to:
  /// **'Guardian Oversight'**
  String get oversightTitle;

  /// No description provided for @oversightDescription.
  ///
  /// In en, this message translates to:
  /// **'Your guardian can see your mood trends but not your private journals.'**
  String get oversightDescription;

  /// No description provided for @dataPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Privacy'**
  String get dataPrivacyTitle;

  /// No description provided for @dataPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personal data is encrypted and stored securely.'**
  String get dataPrivacyDescription;

  /// No description provided for @aiAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysisTitle;

  /// No description provided for @aiAnalysisDescription.
  ///
  /// In en, this message translates to:
  /// **'AI analyzes your patterns to provide helpful insights.'**
  String get aiAnalysisDescription;

  /// No description provided for @activitySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Sharing'**
  String get activitySharingTitle;

  /// No description provided for @activitySharingDescription.
  ///
  /// In en, this message translates to:
  /// **'You can choose which activities to share with others.'**
  String get activitySharingDescription;

  /// No description provided for @totalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @followingLabel.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingLabel;

  /// No description provided for @inThisTabLabel.
  ///
  /// In en, this message translates to:
  /// **'In this tab'**
  String get inThisTabLabel;

  /// No description provided for @noChannelsYet.
  ///
  /// In en, this message translates to:
  /// **'No channels yet'**
  String get noChannelsYet;

  /// No description provided for @noChannelsToDiscover.
  ///
  /// In en, this message translates to:
  /// **'No channels to discover'**
  String get noChannelsToDiscover;

  /// No description provided for @followFromDiscoverNote.
  ///
  /// In en, this message translates to:
  /// **'Follow channels from the Discover tab to see them here.'**
  String get followFromDiscoverNote;

  /// No description provided for @checkBackLaterForChannels.
  ///
  /// In en, this message translates to:
  /// **'Check back later for new channels!'**
  String get checkBackLaterForChannels;

  /// No description provided for @browseAllChannels.
  ///
  /// In en, this message translates to:
  /// **'Browse All Channels'**
  String get browseAllChannels;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet.'**
  String get noPostsYet;

  /// No description provided for @counselorUpdatesNote.
  ///
  /// In en, this message translates to:
  /// **'Counselors will post updates here.'**
  String get counselorUpdatesNote;

  /// No description provided for @commentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 comment} other{{count} comments}}'**
  String commentsCount(num count);

  /// No description provided for @interactionControls.
  ///
  /// In en, this message translates to:
  /// **'Interaction Controls'**
  String get interactionControls;

  /// No description provided for @generalParticipation.
  ///
  /// In en, this message translates to:
  /// **'General Participation'**
  String get generalParticipation;

  /// No description provided for @generalParticipationDesc.
  ///
  /// In en, this message translates to:
  /// **'This allows Neuronet AI to analyze your journal entries for emotional patterns. If disabled, entries are stored but not analyzed.'**
  String get generalParticipationDesc;

  /// No description provided for @aiInsightsSummaries.
  ///
  /// In en, this message translates to:
  /// **'AI Insights & Summaries'**
  String get aiInsightsSummaries;

  /// No description provided for @aiInsightsSummariesDesc.
  ///
  /// In en, this message translates to:
  /// **'Your guardian and counselor can view summaries of your emotional trends.'**
  String get aiInsightsSummariesDesc;

  /// No description provided for @safetyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Safety Alerts'**
  String get safetyAlerts;

  /// No description provided for @safetyAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time notifications sent to your guardian when high-risk patterns are identified.'**
  String get safetyAlertsDesc;

  /// No description provided for @counselorConnection.
  ///
  /// In en, this message translates to:
  /// **'Counselor Connection'**
  String get counselorConnection;

  /// No description provided for @counselorConnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Allows your school counselor to view your profile and participate in your growth journey.'**
  String get counselorConnectionDesc;

  /// No description provided for @directMessaging.
  ///
  /// In en, this message translates to:
  /// **'Direct Messaging'**
  String get directMessaging;

  /// No description provided for @directMessagingDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable secure messaging between you, your guardian, and your counselor.'**
  String get directMessagingDesc;

  /// No description provided for @couldNotLoadPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Could not load privacy settings.'**
  String get couldNotLoadPrivacy;

  /// No description provided for @participationPausedNote.
  ///
  /// In en, this message translates to:
  /// **'Paused: General Participation is off'**
  String get participationPausedNote;

  /// No description provided for @guardianOversightNote.
  ///
  /// In en, this message translates to:
  /// **'Guardian Oversight'**
  String get guardianOversightNote;

  /// No description provided for @guardianOversightNoteDesc.
  ///
  /// In en, this message translates to:
  /// **'Your guardian can see your mood trends but not your private journals.'**
  String get guardianOversightNoteDesc;

  /// No description provided for @understandingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Understanding Your Privacy'**
  String get understandingPrivacy;

  /// No description provided for @privacyEducation1.
  ///
  /// In en, this message translates to:
  /// **'Your guardian manages these settings to ensure you have the right support.'**
  String get privacyEducation1;

  /// No description provided for @privacyEducation2.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about these settings, we encourage you to discuss them with your guardian.'**
  String get privacyEducation2;

  /// No description provided for @privacyEducation3.
  ///
  /// In en, this message translates to:
  /// **'Neuronet uses AI only for emotional insight, never for clinical diagnosis.'**
  String get privacyEducation3;

  /// No description provided for @yourPrivacyMatters.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Matters'**
  String get yourPrivacyMatters;

  /// No description provided for @transparencyNote.
  ///
  /// In en, this message translates to:
  /// **'We value transparency. Below are the oversight settings currently active for your account.'**
  String get transparencyNote;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @revoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get revoked;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @composeEntry.
  ///
  /// In en, this message translates to:
  /// **'Compose Entry'**
  String get composeEntry;

  /// No description provided for @intensityLevel.
  ///
  /// In en, this message translates to:
  /// **'Intensity: {level}'**
  String intensityLevel(int level);

  /// No description provided for @couldNotLoadAlerts.
  ///
  /// In en, this message translates to:
  /// **'Could not load alerts.'**
  String get couldNotLoadAlerts;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @friend.
  ///
  /// In en, this message translates to:
  /// **'friend'**
  String get friend;

  /// No description provided for @refreshingDashboard.
  ///
  /// In en, this message translates to:
  /// **'Refreshing dashboard...'**
  String get refreshingDashboard;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;
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
