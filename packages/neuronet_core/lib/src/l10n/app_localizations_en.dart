// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NEURONET';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get journal => 'Journal';

  @override
  String get chat => 'Chat';

  @override
  String get mood => 'Mood';

  @override
  String get alerts => 'Alerts';

  @override
  String get retry => 'Retry';

  @override
  String get failedToLoadDashboard => 'Failed to load dashboard';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get howAreYouFeeling => 'How are you feeling?';

  @override
  String get allMoods => 'All moods →';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentJournals => 'Recent Journals';

  @override
  String get viewAll => 'View all →';

  @override
  String get personalInsight => 'Personal Insight';

  @override
  String get weGotYou => 'We\'ve got you 💙';

  @override
  String get tryThisToday => 'Try This Today';

  @override
  String get more => 'More →';

  @override
  String get recommendedForYou => 'Recommended for You';

  @override
  String get playAndRelax => 'Play & Relax';

  @override
  String get newTag => 'NEW';

  @override
  String get myProfile => 'My Profile';

  @override
  String get accountInformation => 'Account Information';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get accountStatus => 'Account Status';

  @override
  String get privacyAndPermissions => 'Privacy & Permissions';

  @override
  String get consentStatus => 'Consent Status';

  @override
  String get viewConsentDescription => 'View what your guardian has approved';

  @override
  String get signOut => 'Sign Out';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get adolescent => 'ADOLESCENT';

  @override
  String heyUser(String name) {
    return 'Hey $name 👋';
  }

  @override
  String get innerWorldPrompt => 'How\'s your inner world today?';

  @override
  String get writeJournal => 'Write Journal';

  @override
  String get expressYourself => 'Express yourself 📝';

  @override
  String get aiCompanion => 'AI Companion';

  @override
  String get talkItOut => 'Talk it out 🤖';

  @override
  String get checkYourMood => 'Check Your Mood';

  @override
  String get moodEmojiPrompt => 'How are you feeling? 😊';

  @override
  String get learnAndGrow => 'Learn & Grow';

  @override
  String get exploreResources => 'Explore resources 📚';

  @override
  String get smallCheckIn => 'A small check-in goes a long way.';

  @override
  String get today => 'TODAY';

  @override
  String get take30Seconds => 'Take 30 seconds.';

  @override
  String get namingFeelings =>
      'Naming what you feel is half the work.\nWe\'ll help with the rest.';

  @override
  String get checkInNow => 'Check in now';

  @override
  String get journals => 'Journals';

  @override
  String get moods => 'Moods';

  @override
  String get forYou => 'For You';

  @override
  String get journalToday => 'Today';

  @override
  String get journalYesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get journalEntryDefault => 'Journal Entry';

  @override
  String feelingLabel(String mood) {
    return 'Feeling $mood';
  }

  @override
  String minRead(int count) {
    return '$count min read';
  }

  @override
  String get readNow => 'Read now';

  @override
  String get mindfulnessGames => 'Mindfulness Games';

  @override
  String get boostYourMood =>
      'Boost your mood with fun, science-backed activities.';

  @override
  String get playNow => 'Play Now';

  @override
  String get ai => 'AI';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get alertNotifications => 'Alert Notifications';

  @override
  String get counselorMessages => 'Counselor Messages';

  @override
  String get getNotifiedPatterns => 'Get notified when patterns are detected';

  @override
  String get pushNotificationsNewMessages =>
      'Push notifications for new messages';

  @override
  String get role => 'Role';

  @override
  String get guardian => 'Guardian';

  @override
  String get areYouSureSignOut => 'Are you sure you want to sign out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get translate => 'Translate';

  @override
  String get showOriginal => 'Show Original';

  @override
  String get translating => 'Translating...';

  @override
  String get translationError => 'Failed to translate';

  @override
  String get failedToLoadJournals => 'Error loading journals';

  @override
  String get yourJournalAwaits => 'Your journal awaits';

  @override
  String get captureHowYouFeel =>
      'Capture how you feel in a private space.\nTap compose when you are ready.';

  @override
  String get secureJournalTag => 'YOUR SECURE JOURNAL';

  @override
  String get refreshingJournal => 'Refreshing journal...';

  @override
  String get stillSyncingEntry => 'Still syncing this entry to the server...';

  @override
  String get thisWeek => 'THIS WEEK';

  @override
  String memoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count MEMORIES',
      one: '1 MEMORY',
    );
    return '$_temp0';
  }

  @override
  String get openingYourEntry => 'Opening your entry...';

  @override
  String get couldNotOpenShare =>
      'Could not open share. Text copied to clipboard instead.';

  @override
  String get journalNotFound => 'Journal not found';

  @override
  String get journalSubject => 'My journal entry';

  @override
  String get pleaseWriteSomething => 'Please write something first';

  @override
  String get journalSaved => 'Your journal was saved.';

  @override
  String get newEntryTag => 'NEW ENTRY';

  @override
  String get safeSpaceNote =>
      'This is your safe space. Write what you feel today.';

  @override
  String get journalTitleHint => 'Give it a title...';

  @override
  String get journalContentHint => 'Start writing your thoughts here...';

  @override
  String get sparkSmile => 'What made me smile today?';

  @override
  String get sparkGrateful => 'One thing I\'m grateful for';

  @override
  String get sparkVictory => 'A small victory I had';

  @override
  String get sparkChallenge => 'How I handled a challenge';

  @override
  String get discoverHeader => 'DISCOVER';

  @override
  String get searchMemoriesHint => 'Search memories...';

  @override
  String get filterWhen => 'WHEN';

  @override
  String get filterMood => 'MOOD';

  @override
  String filterResults(int count) {
    return 'RESULTS ($count)';
  }

  @override
  String get stillLooking => 'Still looking...';

  @override
  String get filterAll => 'All';

  @override
  String get filterToday => 'Today';

  @override
  String get filterThisWeek => 'This Week';

  @override
  String get filterSpecific => 'Specific Date';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get aboutJournalPrivacy => 'About journal privacy';

  @override
  String get journalPrivacyTitle => 'Journal privacy';

  @override
  String get journalPrivacyContent =>
      'Your journal entries are stored securely for your account. The app is designed so your raw journal text is not shown to guardians or counselors. If you ever use optional features that analyze mood in aggregate, those are described in your consent settings.';

  @override
  String get gotIt => 'Got it';

  @override
  String get backToJournal => 'Back to journal';

  @override
  String get entryRemovedNote =>
      'It may have been removed or this link is outdated.';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get tryAgain => 'Try again';

  @override
  String get moodLabel => 'Mood';

  @override
  String get wordsLabel => 'Words';

  @override
  String get readLabel => 'Read';

  @override
  String get tipLongPress =>
      'Tip: long-press your entry below to select text or copy a favorite line.';

  @override
  String get yourPrivateSpace => 'Your private space';

  @override
  String get privateSpaceNote =>
      'This entry stays on your account for you. Guardians and counselors do not read your journal text.';

  @override
  String get copyEntry => 'Copy entry';

  @override
  String get titleAndFullText => 'Title and full text';

  @override
  String get writingSparksTag => 'WRITING SPARKS';

  @override
  String get howAreYouFeelingNow => 'How are you feeling right now?';

  @override
  String get save => 'Save';

  @override
  String get syncingTag => 'SYNCING';

  @override
  String get shareTooltip => 'Share';

  @override
  String get moreTooltip => 'More';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodCalm => 'Calm';

  @override
  String get moodStressed => 'Stressed';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodExcited => 'Excited';

  @override
  String get moodTired => 'Tired';

  @override
  String get moodAngry => 'Angry';

  @override
  String get moodHopeful => 'Hopeful';

  @override
  String get dailyCheckInTag => 'YOUR DAILY CHECK-IN';

  @override
  String get tapEmojiPrompt =>
      'Tap the emoji that best captures your current mood.';

  @override
  String get intensityLabel => 'Intensity';

  @override
  String get mildLabel => 'Mild';

  @override
  String get strongLabel => 'Strong';

  @override
  String get moodReasonPrompt => 'What\'s making you feel this way?';

  @override
  String get moodNoteHint => 'Add a quick note... (Optional)';

  @override
  String get logMoodButton => 'Log This Mood';

  @override
  String get moodLoggedSuccess => 'Mood Logged!';

  @override
  String get thanksCheckingIn =>
      'Thanks for checking in.\nTracking how you feel helps you understand yourself better.';

  @override
  String get logAnotherMood => 'Log another mood';

  @override
  String get pastCheckInsHeader => 'Past Check-ins';

  @override
  String get failedToLoadHistory => 'Could not load history';

  @override
  String get now => 'Now';

  @override
  String get minAbbr => 'm';

  @override
  String get hourAbbr => 'h';

  @override
  String get dayAbbr => 'd';

  @override
  String get levelAbbr => 'Lvl';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get typing => 'Typing...';

  @override
  String get online => 'Online';

  @override
  String get loading => 'Loading...';

  @override
  String get offline => 'Offline';

  @override
  String get aiAssistantInfo => 'AI Assistant Information';

  @override
  String get safetyFirst => 'Safety First';

  @override
  String get safetyFirstDesc =>
      'This AI is for support and reflection, not for medical diagnosis or crisis intervention.';

  @override
  String get yourData => 'Your Data';

  @override
  String get yourDataDesc =>
      'Conversations are analyzed to provide support and may be reviewed by your school counselor.';

  @override
  String get howToUse => 'How to Use';

  @override
  String get howToUseDesc =>
      'Ask about stress management, study tips, or just chat about your day.';

  @override
  String get aboutAiAssistant => 'About AI Assistant';

  @override
  String get unableConnectAi => 'Unable to connect to AI Assistant';

  @override
  String get checkInternetTryAgain =>
      'Check your internet connection and try again.';

  @override
  String get startConversation => 'Start a Conversation';

  @override
  String get aiEmptyPrompt =>
      'Ask me anything about your well-being.\nI\'m here to help you reflect.';

  @override
  String get aiThinking => 'AI Assistant is thinking...';

  @override
  String get aiSafetyDisclaimer =>
      'AI Assistant can support your reflection but is not a medical professional. For urgent help, please contact your counselor.';

  @override
  String get aiSenderLabel => 'NEURO Assistant';

  @override
  String get youSenderLabel => 'You';

  @override
  String get aiPrompt1 => 'What can you help me with?';

  @override
  String get aiPrompt2 => 'How do I add a journal entry?';

  @override
  String get aiPrompt3 => 'Who can see my data?';

  @override
  String get aiPrompt4 => 'How do I contact my counselor?';
}
