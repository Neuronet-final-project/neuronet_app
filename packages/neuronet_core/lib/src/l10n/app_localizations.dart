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
  /// **'EMOTION'**
  String get filterMood;

  /// No description provided for @filterEmotion.
  ///
  /// In en, this message translates to:
  /// **'EMOTION'**
  String get filterEmotion;

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

  /// No description provided for @counselorChat.
  ///
  /// In en, this message translates to:
  /// **'Counselor Chat'**
  String get counselorChat;

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

  /// No description provided for @activateAccount.
  ///
  /// In en, this message translates to:
  /// **'Activate Account'**
  String get activateAccount;

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

  /// No description provided for @guardianOnboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Empower Growth'**
  String get guardianOnboardingTitle1;

  /// No description provided for @guardianOnboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Help your child grow with confidence. NeuroNet provides a safe balance between support and independence.'**
  String get guardianOnboardingDesc1;

  /// No description provided for @guardianOnboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Consent-Driven Oversight'**
  String get guardianOnboardingTitle2;

  /// No description provided for @guardianOnboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'You decide what information is shared with counselors. Your oversight is always based on the consents you manage.'**
  String get guardianOnboardingDesc2;

  /// No description provided for @guardianOnboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Stay Informed, Respect Privacy'**
  String get guardianOnboardingTitle3;

  /// No description provided for @guardianOnboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Receive AI-generated summaries and alerts about emotional trends, without ever exposing your child\'s private journal text.'**
  String get guardianOnboardingDesc3;

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
  /// **'Loading consent status...'**
  String get loadingConsent;

  /// No description provided for @unableToStartChat.
  ///
  /// In en, this message translates to:
  /// **'Unable to Start Counselor Chat'**
  String get unableToStartChat;

  /// No description provided for @noMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No Messages Yet'**
  String get noMessagesYet;

  /// No description provided for @startConversationWithCounselor.
  ///
  /// In en, this message translates to:
  /// **'Send a message to start a conversation\nwith your counselor.'**
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
  /// **'No AI picks yet!'**
  String get noAiPicks;

  /// No description provided for @aiPicksDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep journaling and exploring! Our AI will analyze your journey and suggest personalized content.'**
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

  /// No description provided for @boxBreathingTitle.
  ///
  /// In en, this message translates to:
  /// **'Box Breathing'**
  String get boxBreathingTitle;

  /// No description provided for @boxBreathingDesc.
  ///
  /// In en, this message translates to:
  /// **'Calm your mind & find your focus.'**
  String get boxBreathingDesc;

  /// No description provided for @phasePrepare.
  ///
  /// In en, this message translates to:
  /// **'Prepare'**
  String get phasePrepare;

  /// No description provided for @phaseInhale.
  ///
  /// In en, this message translates to:
  /// **'Inhale'**
  String get phaseInhale;

  /// No description provided for @phaseHold.
  ///
  /// In en, this message translates to:
  /// **'Hold'**
  String get phaseHold;

  /// No description provided for @phaseExhale.
  ///
  /// In en, this message translates to:
  /// **'Exhale'**
  String get phaseExhale;

  /// No description provided for @phaseReady.
  ///
  /// In en, this message translates to:
  /// **'Ready?'**
  String get phaseReady;

  /// No description provided for @focusOnBreath.
  ///
  /// In en, this message translates to:
  /// **'Focus on your breath...'**
  String get focusOnBreath;

  /// No description provided for @tapOrbToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap the orb to start your quest'**
  String get tapOrbToStart;

  /// No description provided for @reflectedOnThis.
  ///
  /// In en, this message translates to:
  /// **'I\'ve reflected on this'**
  String get reflectedOnThis;

  /// No description provided for @quest1.
  ///
  /// In en, this message translates to:
  /// **'If your current mood was a weather pattern, what would it look like right now?'**
  String get quest1;

  /// No description provided for @quest2.
  ///
  /// In en, this message translates to:
  /// **'Identify one thing you can control in your life today, and one thing you can let go.'**
  String get quest2;

  /// No description provided for @quest3.
  ///
  /// In en, this message translates to:
  /// **'Imagine a future version of yourself who is completely at peace. What\'s the one piece of advice they\'d give you?'**
  String get quest3;

  /// No description provided for @quest4.
  ///
  /// In en, this message translates to:
  /// **'What\'s a small act of kindness you\'ve witnessed or done recently that stayed with you?'**
  String get quest4;

  /// No description provided for @yourMoodMatchScore.
  ///
  /// In en, this message translates to:
  /// **'Your Mood Match score: {score}'**
  String yourMoodMatchScore(int score);

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @moodMatcherInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap the mood icon that matches the target as fast as you can!'**
  String get moodMatcherInstructions;

  /// No description provided for @findThisMood.
  ///
  /// In en, this message translates to:
  /// **'FIND THIS MOOD:'**
  String get findThisMood;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreLabel(int score);

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String timeLabel(int time);

  /// No description provided for @pageFollowed.
  ///
  /// In en, this message translates to:
  /// **'Page followed!'**
  String get pageFollowed;

  /// No description provided for @pageUnfollowed.
  ///
  /// In en, this message translates to:
  /// **'Page unfollowed'**
  String get pageUnfollowed;

  /// No description provided for @failedToUnfollowPage.
  ///
  /// In en, this message translates to:
  /// **'Failed to unfollow page'**
  String get failedToUnfollowPage;

  /// No description provided for @failedToFollowPage.
  ///
  /// In en, this message translates to:
  /// **'Failed to follow page'**
  String get failedToFollowPage;

  /// No description provided for @unfollowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollowTooltip;

  /// No description provided for @approvalRequired.
  ///
  /// In en, this message translates to:
  /// **'Approval Required'**
  String get approvalRequired;

  /// No description provided for @needGuardianApprovalDesc.
  ///
  /// In en, this message translates to:
  /// **'You need guardian approval to communicate with this counselor. Request approval to start chatting.'**
  String get needGuardianApprovalDesc;

  /// No description provided for @alertTriggeredRequest.
  ///
  /// In en, this message translates to:
  /// **'Alert-triggered request'**
  String get alertTriggeredRequest;

  /// No description provided for @aiAlertDetails.
  ///
  /// In en, this message translates to:
  /// **'AI Alert Details'**
  String get aiAlertDetails;

  /// No description provided for @riskLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level: '**
  String get riskLevelLabel;

  /// No description provided for @riskScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Risk Score: {score}%'**
  String riskScoreLabel(double score);

  /// No description provided for @approvedByGuardian.
  ///
  /// In en, this message translates to:
  /// **'Approved by guardian'**
  String get approvedByGuardian;

  /// No description provided for @approvalRevoked.
  ///
  /// In en, this message translates to:
  /// **'Approval Revoked'**
  String get approvalRevoked;

  /// No description provided for @guardianRevokedApprovalDesc.
  ///
  /// In en, this message translates to:
  /// **'Your guardian has revoked approval for this counselor. You can request approval again to continue chatting.'**
  String get guardianRevokedApprovalDesc;

  /// No description provided for @guardianDeniedRequestDesc.
  ///
  /// In en, this message translates to:
  /// **'Your guardian has denied this request. You can submit a new request with more details.'**
  String get guardianDeniedRequestDesc;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get checking;

  /// No description provided for @failedToLoadAlertDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alert details'**
  String get failedToLoadAlertDetails;

  /// No description provided for @patternNoticedOn.
  ///
  /// In en, this message translates to:
  /// **'Pattern noticed on {date}'**
  String patternNoticedOn(String date);

  /// No description provided for @whatWeNoticed.
  ///
  /// In en, this message translates to:
  /// **'What we noticed'**
  String get whatWeNoticed;

  /// No description provided for @feelingsPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Feelings we picked up on'**
  String get feelingsPickedUp;

  /// No description provided for @groupsHelp.
  ///
  /// In en, this message translates to:
  /// **'Groups that might help'**
  String get groupsHelp;

  /// No description provided for @channelRecSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Highly recommended for you based on recent journals.'**
  String get channelRecSubtitle;

  /// No description provided for @leftGroup.
  ///
  /// In en, this message translates to:
  /// **'Left group'**
  String get leftGroup;

  /// No description provided for @joinedGroup.
  ///
  /// In en, this message translates to:
  /// **'Joined {name}!'**
  String joinedGroup(String name);

  /// No description provided for @joined.
  ///
  /// In en, this message translates to:
  /// **'JOINED'**
  String get joined;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'JOIN'**
  String get join;

  /// No description provided for @thinkingAboutThis.
  ///
  /// In en, this message translates to:
  /// **'Thinking about this?'**
  String get thinkingAboutThis;

  /// No description provided for @keepJournaling.
  ///
  /// In en, this message translates to:
  /// **'Keep Journaling'**
  String get keepJournaling;

  /// No description provided for @journalingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing your thoughts helps us find more patterns.'**
  String get journalingSubtitle;

  /// No description provided for @chatWithCounselor.
  ///
  /// In en, this message translates to:
  /// **'Chat with Counselor'**
  String get chatWithCounselor;

  /// No description provided for @chatWithCounselorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'It\'s always good to reach out if you feel like it.'**
  String get chatWithCounselorSubtitle;

  /// No description provided for @alertDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'These insights are patterns we noticed based on your activity. They aren\'t a diagnosis or medical advice. We\'re just here to help you understand your emotional journey.'**
  String get alertDisclaimer;

  /// No description provided for @moodPattern.
  ///
  /// In en, this message translates to:
  /// **'Mood Pattern'**
  String get moodPattern;

  /// No description provided for @energyShift.
  ///
  /// In en, this message translates to:
  /// **'Energy Shift'**
  String get energyShift;

  /// No description provided for @activityUpdate.
  ///
  /// In en, this message translates to:
  /// **'Activity Update'**
  String get activityUpdate;

  /// No description provided for @mindfulnessPrompt.
  ///
  /// In en, this message translates to:
  /// **'Mindfulness Prompt'**
  String get mindfulnessPrompt;

  /// No description provided for @chatInsight.
  ///
  /// In en, this message translates to:
  /// **'Chat Insight'**
  String get chatInsight;

  /// No description provided for @notice.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get notice;

  /// No description provided for @emotionSadness.
  ///
  /// In en, this message translates to:
  /// **'😔 Feeling down'**
  String get emotionSadness;

  /// No description provided for @emotionLoneliness.
  ///
  /// In en, this message translates to:
  /// **'🫂 Feeling alone'**
  String get emotionLoneliness;

  /// No description provided for @emotionHopelessness.
  ///
  /// In en, this message translates to:
  /// **'💭 Tough thoughts'**
  String get emotionHopelessness;

  /// No description provided for @emotionFear.
  ///
  /// In en, this message translates to:
  /// **'😨 Feeling scared'**
  String get emotionFear;

  /// No description provided for @emotionAnger.
  ///
  /// In en, this message translates to:
  /// **'😤 Feeling frustrated'**
  String get emotionAnger;

  /// No description provided for @emotionNervousness.
  ///
  /// In en, this message translates to:
  /// **'😰 Feeling nervous'**
  String get emotionNervousness;

  /// No description provided for @emotionAnxiety.
  ///
  /// In en, this message translates to:
  /// **'🌊 Waves of worry'**
  String get emotionAnxiety;

  /// No description provided for @emotionDisappointment.
  ///
  /// In en, this message translates to:
  /// **'😞 Disappointed'**
  String get emotionDisappointment;

  /// No description provided for @emotionGrief.
  ///
  /// In en, this message translates to:
  /// **'💔 Heavy heart'**
  String get emotionGrief;

  /// No description provided for @emotionAnnoyance.
  ///
  /// In en, this message translates to:
  /// **'😒 Annoyed'**
  String get emotionAnnoyance;

  /// No description provided for @emotionConfusion.
  ///
  /// In en, this message translates to:
  /// **'🤔 Confused'**
  String get emotionConfusion;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @followChannelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Follow channel'**
  String get followChannelTooltip;

  /// No description provided for @channelLabel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channelLabel;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userLabel;

  /// No description provided for @unauthorizedAdolescentAccess.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access: This account does not have Adolescent privileges.'**
  String get unauthorizedAdolescentAccess;

  /// No description provided for @unauthorizedRoleMismatch.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized access: Account role mismatch.'**
  String get unauthorizedRoleMismatch;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get invalidEmailError;

  /// No description provided for @callError.
  ///
  /// In en, this message translates to:
  /// **'Call Error'**
  String get callError;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @unknownCaller.
  ///
  /// In en, this message translates to:
  /// **'Unknown Caller'**
  String get unknownCaller;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling...'**
  String get calling;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get endCall;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// No description provided for @mute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// No description provided for @unmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @camOff.
  ///
  /// In en, this message translates to:
  /// **'Cam Off'**
  String get camOff;

  /// No description provided for @flip.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get flip;

  /// No description provided for @speaker.
  ///
  /// In en, this message translates to:
  /// **'Speaker'**
  String get speaker;

  /// No description provided for @insufficientData.
  ///
  /// In en, this message translates to:
  /// **'Insufficient data for analysis.'**
  String get insufficientData;

  /// No description provided for @micPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record voice messages.'**
  String get micPermissionRequired;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(String error);

  /// No description provided for @failedToPickVideo.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick video: {error}'**
  String failedToPickVideo(String error);

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play Video'**
  String get playVideo;

  /// No description provided for @shareMedia.
  ///
  /// In en, this message translates to:
  /// **'Share Media'**
  String get shareMedia;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @cameraLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraLabel;

  /// No description provided for @videoLabel.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoLabel;

  /// No description provided for @preparingMedia.
  ///
  /// In en, this message translates to:
  /// **'Preparing media...'**
  String get preparingMedia;

  /// No description provided for @tapToDownload.
  ///
  /// In en, this message translates to:
  /// **'Tap to download'**
  String get tapToDownload;

  /// No description provided for @voiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceLabel;

  /// No description provided for @contactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @emptyMessage.
  ///
  /// In en, this message translates to:
  /// **'(empty message)'**
  String get emptyMessage;

  /// No description provided for @attachmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachmentLabel;

  /// No description provided for @mindfulFocusTip.
  ///
  /// In en, this message translates to:
  /// **'Keep your head still and follow the dot.'**
  String get mindfulFocusTip;

  /// No description provided for @supportGroup.
  ///
  /// In en, this message translates to:
  /// **'Support Group'**
  String get supportGroup;

  /// No description provided for @educationalLabel.
  ///
  /// In en, this message translates to:
  /// **'Educational'**
  String get educationalLabel;

  /// No description provided for @supportLabel.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportLabel;

  /// No description provided for @discussionLabel.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussionLabel;

  /// No description provided for @resourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get resourcesLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @postLabel.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postLabel;

  /// No description provided for @safeSpaceCounselor.
  ///
  /// In en, this message translates to:
  /// **'Safe space for counselor guidance and updates.'**
  String get safeSpaceCounselor;

  /// No description provided for @guardianOverview.
  ///
  /// In en, this message translates to:
  /// **'Guardian Overview'**
  String get guardianOverview;

  /// No description provided for @linkedAdolescents.
  ///
  /// In en, this message translates to:
  /// **'Linked Adolescents'**
  String get linkedAdolescents;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level: {risk}'**
  String riskLevel(String risk);

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get lowRisk;

  /// No description provided for @mediumRisk.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get mediumRisk;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get highRisk;

  /// No description provided for @viewAlerts.
  ///
  /// In en, this message translates to:
  /// **'View Alerts'**
  String get viewAlerts;

  /// No description provided for @viewAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check active alerts for your adolescents'**
  String get viewAlertsSubtitle;

  /// No description provided for @addAdolescent.
  ///
  /// In en, this message translates to:
  /// **'Add Adolescent'**
  String get addAdolescent;

  /// No description provided for @addAdolescentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Link a new account to your command center'**
  String get addAdolescentSubtitle;

  /// No description provided for @pendingActivations.
  ///
  /// In en, this message translates to:
  /// **'Pending Activations'**
  String get pendingActivations;

  /// No description provided for @noAdolescentsAwaitingActivation.
  ///
  /// In en, this message translates to:
  /// **'No adolescents awaiting activation'**
  String get noAdolescentsAwaitingActivation;

  /// No description provided for @adolescentsAwaitingActivation.
  ///
  /// In en, this message translates to:
  /// **'{count} adolescent(s) awaiting activation'**
  String adolescentsAwaitingActivation(int count);

  /// No description provided for @counselorApprovals.
  ///
  /// In en, this message translates to:
  /// **'Counselor Approvals'**
  String get counselorApprovals;

  /// No description provided for @counselorApprovalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage counselor communication requests'**
  String get counselorApprovalsSubtitle;

  /// No description provided for @noDashboardData.
  ///
  /// In en, this message translates to:
  /// **'No dashboard data available.'**
  String get noDashboardData;

  /// No description provided for @dataUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Data Unavailable'**
  String get dataUnavailable;

  /// No description provided for @guardianDataUnavailableDesc.
  ///
  /// In en, this message translates to:
  /// **'Guardian activity data is temporarily unavailable. Quick Actions are active.'**
  String get guardianDataUnavailableDesc;

  /// No description provided for @adolescentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Adolescents'**
  String get adolescentsLabel;

  /// No description provided for @totalJournalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Journals'**
  String get totalJournalsLabel;

  /// No description provided for @emotionalTrends.
  ///
  /// In en, this message translates to:
  /// **'Emotional Trends'**
  String get emotionalTrends;

  /// No description provided for @noTrendDataYet.
  ///
  /// In en, this message translates to:
  /// **'No Trend Data Yet'**
  String get noTrendDataYet;

  /// No description provided for @noTrendDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Trend visualization will appear once mood entries are recorded by linked adolescents.'**
  String get noTrendDataDesc;

  /// No description provided for @sevenDays.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get sevenDays;

  /// No description provided for @fourteenDays.
  ///
  /// In en, this message translates to:
  /// **'14d'**
  String get fourteenDays;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30d'**
  String get thirtyDays;

  /// No description provided for @aggregatedInsights.
  ///
  /// In en, this message translates to:
  /// **'Aggregated Insights'**
  String get aggregatedInsights;

  /// No description provided for @averageMoodSentiment.
  ///
  /// In en, this message translates to:
  /// **'Average Mood Sentiment'**
  String get averageMoodSentiment;

  /// No description provided for @allAdolescentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Across all linked adolescents (last {period})'**
  String allAdolescentsSubtitle(String period);

  /// No description provided for @alertsSummary.
  ///
  /// In en, this message translates to:
  /// **'Alerts Summary'**
  String get alertsSummary;

  /// No description provided for @totalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String totalCount(int count);

  /// No description provided for @alertsSeverityBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Low: {low}, Medium: {med}, High: {high}'**
  String alertsSeverityBreakdown(int low, int med, int high);

  /// No description provided for @activityStats.
  ///
  /// In en, this message translates to:
  /// **'Activity Stats'**
  String get activityStats;

  /// No description provided for @journalMoodStats.
  ///
  /// In en, this message translates to:
  /// **'{journalCount} journals, {moodCount} mood entries'**
  String journalMoodStats(int journalCount, int moodCount);

  /// No description provided for @adolescentsLinked.
  ///
  /// In en, this message translates to:
  /// **'{count} adolescent(s) linked'**
  String adolescentsLinked(int count);

  /// No description provided for @adolescentProfiles.
  ///
  /// In en, this message translates to:
  /// **'Adolescent Profiles'**
  String get adolescentProfiles;

  /// No description provided for @failedToLoadAdolescents.
  ///
  /// In en, this message translates to:
  /// **'Failed to load adolescents'**
  String get failedToLoadAdolescents;

  /// No description provided for @registerAdolescentGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Register an adolescent to get started.'**
  String get registerAdolescentGetStarted;

  /// No description provided for @interventionHub.
  ///
  /// In en, this message translates to:
  /// **'Intervention Hub'**
  String get interventionHub;

  /// No description provided for @registrationDetails.
  ///
  /// In en, this message translates to:
  /// **'Registration Details'**
  String get registrationDetails;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @linkedSince.
  ///
  /// In en, this message translates to:
  /// **'Linked Since'**
  String get linkedSince;

  /// No description provided for @activePermissions.
  ///
  /// In en, this message translates to:
  /// **'Active Permissions'**
  String get activePermissions;

  /// No description provided for @noConsentsFound.
  ///
  /// In en, this message translates to:
  /// **'No Consents Found'**
  String get noConsentsFound;

  /// No description provided for @noConsentsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'No consents record found for this account.'**
  String get noConsentsFoundDesc;

  /// No description provided for @manageAllConsents.
  ///
  /// In en, this message translates to:
  /// **'Manage All Consents'**
  String get manageAllConsents;

  /// No description provided for @unlinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Unlink This Account'**
  String get unlinkAccount;

  /// No description provided for @personalAccountTag.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL ACCOUNT'**
  String get personalAccountTag;

  /// No description provided for @aiGuide.
  ///
  /// In en, this message translates to:
  /// **'AI Guide'**
  String get aiGuide;

  /// No description provided for @viewTips.
  ///
  /// In en, this message translates to:
  /// **'View tips'**
  String get viewTips;

  /// No description provided for @followsLabel.
  ///
  /// In en, this message translates to:
  /// **'Follows'**
  String get followsLabel;

  /// No description provided for @educationalPagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Educational pages'**
  String get educationalPagesSubtitle;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get activeStatus;

  /// No description provided for @disabledStatus.
  ///
  /// In en, this message translates to:
  /// **'DISABLED'**
  String get disabledStatus;

  /// No description provided for @guardianPortal.
  ///
  /// In en, this message translates to:
  /// **'Guardian Portal 👋'**
  String get guardianPortal;

  /// No description provided for @secureAccessOversight.
  ///
  /// In en, this message translates to:
  /// **'Secure access for oversight'**
  String get secureAccessOversight;

  /// No description provided for @newGuardianPrompt.
  ///
  /// In en, this message translates to:
  /// **'New Guardian?'**
  String get newGuardianPrompt;

  /// No description provided for @noAdolescentsLinked.
  ///
  /// In en, this message translates to:
  /// **'No Adolescents Linked'**
  String get noAdolescentsLinked;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @alertsHistory.
  ///
  /// In en, this message translates to:
  /// **'Alerts History'**
  String get alertsHistory;

  /// No description provided for @filterBySeverity.
  ///
  /// In en, this message translates to:
  /// **'Filter by Severity'**
  String get filterBySeverity;

  /// No description provided for @noAlertsFound.
  ///
  /// In en, this message translates to:
  /// **'No Alerts Found'**
  String get noAlertsFound;

  /// No description provided for @noAlertsYet.
  ///
  /// In en, this message translates to:
  /// **'No alerts yet'**
  String get noAlertsYet;

  /// No description provided for @noAlertsYetDesc.
  ///
  /// In en, this message translates to:
  /// **'We will notify you if any concerning patterns appear.'**
  String get noAlertsYetDesc;

  /// No description provided for @noAlertsFoundDescFiltered.
  ///
  /// In en, this message translates to:
  /// **'No alerts match the \"{severity}\" severity filter.'**
  String noAlertsFoundDescFiltered(String severity);

  /// No description provided for @clearFilter.
  ///
  /// In en, this message translates to:
  /// **'Clear Filter'**
  String get clearFilter;

  /// No description provided for @securityAlerts.
  ///
  /// In en, this message translates to:
  /// **'Security Alerts'**
  String get securityAlerts;

  /// No description provided for @adolescentProfile.
  ///
  /// In en, this message translates to:
  /// **'Adolescent Profile'**
  String get adolescentProfile;

  /// No description provided for @registerNewAdolescent.
  ///
  /// In en, this message translates to:
  /// **'Register New Adolescent'**
  String get registerNewAdolescent;

  /// No description provided for @approvalRequests.
  ///
  /// In en, this message translates to:
  /// **'Approval Requests'**
  String get approvalRequests;

  /// No description provided for @noApprovalRequests.
  ///
  /// In en, this message translates to:
  /// **'No Approval Requests'**
  String get noApprovalRequests;

  /// No description provided for @noApprovalRequestsDesc.
  ///
  /// In en, this message translates to:
  /// **'Approval requests from your adolescents will appear here'**
  String get noApprovalRequestsDesc;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @noPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No Pending Requests'**
  String get noPendingRequests;

  /// No description provided for @noPendingRequestsDesc.
  ///
  /// In en, this message translates to:
  /// **'All approval requests have been reviewed'**
  String get noPendingRequestsDesc;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No History'**
  String get noHistory;

  /// No description provided for @noHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Reviewed approval requests will appear here'**
  String get noHistoryDesc;

  /// No description provided for @revokeApproval.
  ///
  /// In en, this message translates to:
  /// **'Revoke Approval'**
  String get revokeApproval;

  /// No description provided for @revoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get revoke;

  /// No description provided for @approvalRevokedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Approval revoked successfully'**
  String get approvalRevokedSuccess;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @secureAccessWithCode.
  ///
  /// In en, this message translates to:
  /// **'Secure your access with your code'**
  String get secureAccessWithCode;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account Email'**
  String get accountEmail;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @empowerParentingJourney.
  ///
  /// In en, this message translates to:
  /// **'Empower your parenting journey'**
  String get empowerParentingJourney;

  /// No description provided for @alreadyGuardian.
  ///
  /// In en, this message translates to:
  /// **'Already a Guardian?'**
  String get alreadyGuardian;

  /// No description provided for @dataAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataAndPrivacy;

  /// No description provided for @manageDataProcessed.
  ///
  /// In en, this message translates to:
  /// **'Manage how data is processed'**
  String get manageDataProcessed;

  /// No description provided for @safetyMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Safety Monitoring'**
  String get safetyMonitoring;

  /// No description provided for @proactiveAlertsSupport.
  ///
  /// In en, this message translates to:
  /// **'Proactive alerts and support'**
  String get proactiveAlertsSupport;

  /// No description provided for @noLinkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'No Linked Accounts'**
  String get noLinkedAccounts;

  /// No description provided for @consentManagementAwaitsLink.
  ///
  /// In en, this message translates to:
  /// **'Consent management will appear once an adolescent account is linked.'**
  String get consentManagementAwaitsLink;

  /// No description provided for @pickedForUser.
  ///
  /// In en, this message translates to:
  /// **'Picked for {name}'**
  String pickedForUser(String name);

  /// No description provided for @empowerGrowth.
  ///
  /// In en, this message translates to:
  /// **'Empower Growth'**
  String get empowerGrowth;

  /// No description provided for @consentDrivenOversight.
  ///
  /// In en, this message translates to:
  /// **'Consent-Driven Oversight'**
  String get consentDrivenOversight;

  /// No description provided for @stayInformedRespectPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Stay Informed, Respect Privacy'**
  String get stayInformedRespectPrivacy;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// No description provided for @adolescentFullName.
  ///
  /// In en, this message translates to:
  /// **'Adolescent\'s Full Name'**
  String get adolescentFullName;

  /// No description provided for @supportEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Support Email (Required)'**
  String get supportEmailRequired;

  /// No description provided for @returnToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Return to Dashboard'**
  String get returnToDashboard;

  /// No description provided for @activationCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Activation code copied'**
  String get activationCodeCopied;

  /// No description provided for @alertResolvedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Alert resolved successfully'**
  String get alertResolvedSuccess;

  /// No description provided for @failedToResolveAlert.
  ///
  /// In en, this message translates to:
  /// **'Failed to resolve alert: {error}'**
  String failedToResolveAlert(String error);

  /// No description provided for @markAsResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark as Resolved'**
  String get markAsResolved;

  /// No description provided for @errorLoadingAlerts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load alerts.'**
  String get errorLoadingAlerts;

  /// No description provided for @alertNotFound.
  ///
  /// In en, this message translates to:
  /// **'Alert Not Found'**
  String get alertNotFound;

  /// No description provided for @alertNotFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'This alert may have been resolved or deleted.'**
  String get alertNotFoundDesc;

  /// No description provided for @addedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String addedDateLabel(String date);

  /// No description provided for @waitingForConnection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Connection'**
  String get waitingForConnection;

  /// No description provided for @waitingForConnectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Ensure your adolescent enters the activation code on their device to establish the encrypted emotional health monitoring link.'**
  String get waitingForConnectionDesc;

  /// No description provided for @viewActivationInfo.
  ///
  /// In en, this message translates to:
  /// **'View Activation Info'**
  String get viewActivationInfo;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @alertAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Alert Analysis'**
  String get alertAnalysis;

  /// No description provided for @aiInsight.
  ///
  /// In en, this message translates to:
  /// **'AI Insight'**
  String get aiInsight;

  /// No description provided for @detectedEmotions.
  ///
  /// In en, this message translates to:
  /// **'Detected Emotions'**
  String get detectedEmotions;

  /// No description provided for @triggerDetails.
  ///
  /// In en, this message translates to:
  /// **'Trigger Details'**
  String get triggerDetails;

  /// No description provided for @resolutionNotes.
  ///
  /// In en, this message translates to:
  /// **'Resolution Notes'**
  String get resolutionNotes;

  /// No description provided for @resolutionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any notes about how this alert was addressed...'**
  String get resolutionNotesHint;

  /// No description provided for @generalBehavioralCheck.
  ///
  /// In en, this message translates to:
  /// **'General Behavioral Check'**
  String get generalBehavioralCheck;

  /// No description provided for @emotionalContext.
  ///
  /// In en, this message translates to:
  /// **'Emotional Context'**
  String get emotionalContext;

  /// No description provided for @triggerPattern.
  ///
  /// In en, this message translates to:
  /// **'Trigger Pattern'**
  String get triggerPattern;

  /// No description provided for @resolutionGuardrail.
  ///
  /// In en, this message translates to:
  /// **'Resolution & Guardrail'**
  String get resolutionGuardrail;

  /// No description provided for @enterObservations.
  ///
  /// In en, this message translates to:
  /// **'Enter observations or actions taken...'**
  String get enterObservations;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @failedToLoadApprovals.
  ///
  /// In en, this message translates to:
  /// **'Failed to load approval requests'**
  String get failedToLoadApprovals;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved'**
  String get requestApproved;

  /// No description provided for @requestDenied.
  ///
  /// In en, this message translates to:
  /// **'Request denied'**
  String get requestDenied;

  /// No description provided for @revokeApprovalDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke this approval? The adolescent will no longer be able to communicate with this counselor, but can request approval again.'**
  String get revokeApprovalDesc;

  /// No description provided for @wantsToCommunicate.
  ///
  /// In en, this message translates to:
  /// **'wants to communicate with counselor'**
  String get wantsToCommunicate;

  /// No description provided for @reasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reasonLabel;

  /// No description provided for @requestedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Requested {date}'**
  String requestedDateLabel(String date);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String hoursAgo(int count);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String minutesAgo(int count);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @activationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account activated! Please login.'**
  String get activationSuccess;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalidEmail;

  /// No description provided for @enterActivationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter activation code'**
  String get enterActivationCode;

  /// No description provided for @min6Characters.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get min6Characters;

  /// No description provided for @signUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please login.'**
  String get signUpSuccess;

  /// No description provided for @errorDuringSignUp.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during signup'**
  String get errorDuringSignUp;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @signUpNow.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Now'**
  String get signUpNow;

  /// No description provided for @guardianEmail.
  ///
  /// In en, this message translates to:
  /// **'Guardian Email'**
  String get guardianEmail;

  /// No description provided for @createPassword.
  ///
  /// In en, this message translates to:
  /// **'Create Password'**
  String get createPassword;

  /// No description provided for @privacyOversight.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Oversight'**
  String get privacyOversight;

  /// No description provided for @refreshSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh settings'**
  String get refreshSettingsTooltip;

  /// No description provided for @failedToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings'**
  String get failedToLoadSettings;

  /// No description provided for @securityHub.
  ///
  /// In en, this message translates to:
  /// **'Security Hub'**
  String get securityHub;

  /// No description provided for @consentHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Configure how Neuronet supports your adolescent. Balance their journey toward independence with the oversight needed for a safe environment.'**
  String get consentHeroDesc;

  /// No description provided for @consentRevokedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Consent revoked successfully'**
  String get consentRevokedSuccess;

  /// No description provided for @failedToRevokeConsent.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke consent: {error}'**
  String failedToRevokeConsent(String error);

  /// No description provided for @consentGrantedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Consent granted successfully'**
  String get consentGrantedSuccess;

  /// No description provided for @failedToGrantConsent.
  ///
  /// In en, this message translates to:
  /// **'Failed to grant consent: {error}'**
  String failedToGrantConsent(String error);

  /// No description provided for @settingsForAdolescent.
  ///
  /// In en, this message translates to:
  /// **'Settings for {email}'**
  String settingsForAdolescent(String email);

  /// No description provided for @chattingAboutAdolescent.
  ///
  /// In en, this message translates to:
  /// **'Chatting about {name}'**
  String chattingAboutAdolescent(String name);

  /// No description provided for @noCounselorLinked.
  ///
  /// In en, this message translates to:
  /// **'No Counselor Linked'**
  String get noCounselorLinked;

  /// No description provided for @noCounselorLinkedDesc.
  ///
  /// In en, this message translates to:
  /// **'A counselor hasn\'t been assigned or linked to {name}\'s account yet.'**
  String noCounselorLinkedDesc(String name);

  /// No description provided for @notLinkedToCounselor.
  ///
  /// In en, this message translates to:
  /// **'{name} is not currently linked to a counselor.'**
  String notLinkedToCounselor(String name);

  /// No description provided for @counselorAssistanceAwaits.
  ///
  /// In en, this message translates to:
  /// **'Communication and collaboration will appear here once a connection is established.'**
  String get counselorAssistanceAwaits;

  /// No description provided for @startCollaboration.
  ///
  /// In en, this message translates to:
  /// **'Start Collaboration'**
  String get startCollaboration;

  /// No description provided for @regardingAdolescent.
  ///
  /// In en, this message translates to:
  /// **'Regarding: {name}'**
  String regardingAdolescent(String name);

  /// No description provided for @chatEnabledConsent.
  ///
  /// In en, this message translates to:
  /// **'Chat enabled - Adolescent consent on file'**
  String get chatEnabledConsent;

  /// No description provided for @chatDisabledConsent.
  ///
  /// In en, this message translates to:
  /// **'Chat disabled - Adolescent consent required'**
  String get chatDisabledConsent;

  /// No description provided for @noCounselorAssigned.
  ///
  /// In en, this message translates to:
  /// **'No Counselor Assigned'**
  String get noCounselorAssigned;

  /// No description provided for @noCounselorAssignedDesc.
  ///
  /// In en, this message translates to:
  /// **'An assigned counselor is required to start a conversation. Please wait for the school administration to assign a professional to {name}.'**
  String noCounselorAssignedDesc(String name);

  /// No description provided for @startConversationWithCounselorSimple.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with the counselor'**
  String get startConversationWithCounselorSimple;

  /// No description provided for @noFollowsFound.
  ///
  /// In en, this message translates to:
  /// **'No followed pages found'**
  String get noFollowsFound;

  /// No description provided for @noFollowsFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'{name} hasn\'t followed any educational pages yet.'**
  String noFollowsFoundDesc(String name);

  /// No description provided for @noPicksYetDesc.
  ///
  /// In en, this message translates to:
  /// **'Personalized recommendations will appear here as {name} continues journaling and exploring.'**
  String noPicksYetDesc(String name);

  /// No description provided for @couldNotLoadRecs.
  ///
  /// In en, this message translates to:
  /// **'Could not load recommendations.'**
  String get couldNotLoadRecs;

  /// No description provided for @followedDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Followed {date}'**
  String followedDateLabel(String date);

  /// No description provided for @recently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get recently;

  /// No description provided for @viewsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 view} other{{count} views}}'**
  String viewsCountLabel(int count);

  /// No description provided for @deleteMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessageTitle;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this message? This action cannot be undone.'**
  String get deleteMessageConfirm;

  /// No description provided for @deleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteLabel;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;
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
