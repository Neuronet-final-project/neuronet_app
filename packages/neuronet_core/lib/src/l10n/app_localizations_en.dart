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
  String get forgotPassword => 'Forgot password?';

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
  String get unknownDate => 'Unknown date';

  @override
  String get accountIsActive => 'This account is active.';

  @override
  String get activationCodeSharedInfo =>
      'Activation code was shared during registration. Ensure the adolescent enters it on their device.';

  @override
  String get accountIsInactiveInfo =>
      'This account is inactive. Profile editing is disabled.';

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
  String get recommendedForYou => 'Recommended for you:';

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
  String get today => 'Today';

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
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
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
  String get filterMood => 'EMOTION';

  @override
  String get filterEmotion => 'EMOTION';

  @override
  String filterResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
      zero: 'No results',
    );
    return '$_temp0';
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

  @override
  String get requestApproval => 'Request Approval';

  @override
  String get checkingApprovalStatus => 'Checking approval status...';

  @override
  String get approvalRequest => 'Approval Request';

  @override
  String get approvalPending => 'Approval Pending';

  @override
  String approvalPendingMessage(String counselorName) {
    return 'Your approval request for $counselorName is already pending.';
  }

  @override
  String get guardianReviewingMessage =>
      'Your guardian is reviewing your request. You\'ll be notified once they respond.';

  @override
  String get requestSent => 'Request Sent';

  @override
  String get requestSentSuccess => 'Request Sent!';

  @override
  String get approvalSentMessage =>
      'Your approval request has been sent to your guardian.';

  @override
  String get statusPending => 'Status: Pending';

  @override
  String get backToChat => 'Back to Chat';

  @override
  String get guardianApprovalRequired => 'Guardian Approval Required';

  @override
  String get guardianApprovalExplanation =>
      'To communicate with a counselor, you need approval from your guardian. Please explain why you would like to talk to this counselor.';

  @override
  String get counselorLabel => 'Counselor';

  @override
  String get counselorChat => 'Counselor Chat';

  @override
  String get reasonForRequest => 'Reason for Request';

  @override
  String get reasonHint =>
      'Explain why you would like to talk to this counselor...';

  @override
  String get reasonRequired => 'Please provide a reason for your request';

  @override
  String get reasonMinLength =>
      'Please provide more details (at least 20 characters)';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get unableToGetUserInfo =>
      'Unable to get user information. Please try again.';

  @override
  String get pendingRequestExists =>
      'You already have a pending approval request for this counselor.';

  @override
  String get alreadyPending => 'already pending';

  @override
  String get approvalRequestAlreadyPending =>
      'Approval request already pending';

  @override
  String get profileNotFound => 'User profile not found.';

  @override
  String get adolescentAccount => 'Adolescent Account';

  @override
  String get errorPrefix => 'Error';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get statusPendingActivation => 'Pending Activation';

  @override
  String appVersion(String version) {
    return 'NeuroNet v$version';
  }

  @override
  String guardianAppVersion(String version) {
    return 'NeuroNet Guardian v$version';
  }

  @override
  String get profileNotFoundUser => 'No user profile found.';

  @override
  String get accountActivatedLogin => 'Account activated! Please login.';

  @override
  String get activateAccount => 'Activate Account';

  @override
  String get activateAccountTitle => 'Activate Account';

  @override
  String get setUpSecureAccount => 'Set Up Your Secure Account';

  @override
  String get activationCodeHint =>
      'Use the activation code provided by your guardian to begin your journey.';

  @override
  String get registeredEmail => 'Registered Email';

  @override
  String get activationCode => 'Activation Code';

  @override
  String get activationCodeExample => 'e.g. NEURO-2026';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get activateAccountButton => 'Activate Account';

  @override
  String get passwordPrivacyInfo =>
      'Your password ensures your journal remains private and secure.';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterActivationCode => 'Please enter the activation code';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get discoverPages => 'Discover Pages';

  @override
  String get followedPages => 'Followed Pages';

  @override
  String get pickedForYou => 'Picked for You';

  @override
  String get aiPicks => 'AI Picks';

  @override
  String get popular => 'Popular';

  @override
  String get analyzeNow => 'Analyze Now';

  @override
  String get insightDetail => 'Insight Detail';

  @override
  String get channelNotFound => 'Channel not found. Please try again later.';

  @override
  String get yourChannels => 'Your Channels';

  @override
  String get following => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get requestApprovalAgain => 'Request Approval Again';

  @override
  String get requestAgain => 'Request Again';

  @override
  String get goToYourChannels => 'Go to Your Channels';

  @override
  String get loginTagline1 => 'Your Emotional Support Space 💜';

  @override
  String get loginTagline2 => 'You are not alone in this 🌿';

  @override
  String get loginTagline3 => 'Every feeling is valid here ✨';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get welcomeBack => 'Welcome back 👋';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get emailHint => 'Email address';

  @override
  String get passwordHint => 'Password';

  @override
  String get newToNeuroNet => 'New to NeuroNet?';

  @override
  String get activateMyAccount => 'Activate My Account';

  @override
  String get dataPrivateEncrypted => 'Your data is private and encrypted';

  @override
  String get onboardingTitle1 => 'Your Safe Space';

  @override
  String get onboardingDesc1 =>
      'A private place for your thoughts and feelings. Your journals are never seen by guardians or counselors.';

  @override
  String get onboardingTitle2 => 'Understand Your Trends';

  @override
  String get onboardingDesc2 =>
      'Our AI helps you see patterns in your emotional journey over time, helping you grow with self-awareness.';

  @override
  String get onboardingTitle3 => 'Support, Not Diagnosis';

  @override
  String get onboardingDesc3 =>
      'We\'re here to support you. Our AI is an informational assistant, not a doctor or therapist.';

  @override
  String get onboardingTitle4 => 'Ready to Start?';

  @override
  String get onboardingDesc4 =>
      'Use the activation code provided by your guardian to unlock your personal emotional journey.';

  @override
  String get guardianOnboardingTitle1 => 'Track Progress';

  @override
  String get guardianOnboardingDesc1 =>
      'Monitor your child\'s emotional growth and developmental milestones in real-time.';

  @override
  String get guardianOnboardingTitle2 => 'Secure Oversight';

  @override
  String get guardianOnboardingDesc2 =>
      'Your data is protected with state-of-the-art encryption and HIPAA compliance.';

  @override
  String get guardianOnboardingTitle3 => 'Instant Alerts';

  @override
  String get guardianOnboardingDesc3 =>
      'Receive immediate notifications for critical emotional shifts and safety concerns.';

  @override
  String get noCommentsYet => 'No comments yet.';

  @override
  String get discover => 'Discover';

  @override
  String get myInsights => 'My Insights';

  @override
  String get aiReflectiveQuest => 'AI REFLECTIVE QUEST';

  @override
  String get gameOver => 'Game Over!';

  @override
  String get playAgain => 'Play Again';

  @override
  String get close => 'Close';

  @override
  String get startGame => 'START GAME';

  @override
  String get startExercise => 'Start Exercise';

  @override
  String get noInsightsYet => 'No insights yet!';

  @override
  String get keepJournalingDesc =>
      'Keep journaling and tracking your moods.\nWe\'ll share helpful patterns here.';

  @override
  String insightsHistory(int count) {
    return 'Insights History ($count)';
  }

  @override
  String get recent => 'RECENT';

  @override
  String get newLabel => 'NEW';

  @override
  String get viewDetails => 'View Details';

  @override
  String get yesterday => 'Yesterday';

  @override
  String failedToUploadVoice(String error) {
    return 'Failed to upload voice message: $error';
  }

  @override
  String failedToUploadMedia(String type, String error) {
    return 'Failed to upload $type: $error';
  }

  @override
  String get voiceCall => 'Voice call';

  @override
  String get videoCall => 'Video call';

  @override
  String get refreshMessages => 'Refresh messages';

  @override
  String get chatEnabledBanner =>
      'Chat enabled - Your guardian has approved counselor communication';

  @override
  String get chatDisabledBanner =>
      'Chat disabled - Counselor communication consent required';

  @override
  String get loadingConsent => 'Loading consent status...';

  @override
  String get unableToStartChat => 'Unable to Start Counselor Chat';

  @override
  String get noMessagesYet => 'No Messages Yet';

  @override
  String get startConversationWithCounselor =>
      'Send a message to start a conversation\nwith your counselor.';

  @override
  String get counselorPrompt1 => 'I\'d like to talk about something';

  @override
  String get counselorPrompt2 => 'Can you help me with some concerns?';

  @override
  String get counselorPrompt3 => 'I need some guidance';

  @override
  String get deepBreathingTitle => 'Deep Breathing';

  @override
  String get deepBreathingDesc =>
      'A simple 4-4-4 rhythm to calm your mind and regulate your system.';

  @override
  String get mindfulFocusTitle => 'Mindful Focus';

  @override
  String get mindfulFocusDesc =>
      'Train your attention by following the rhythmic movement of light.';

  @override
  String get moodMatcherTitle => 'Mood Matcher';

  @override
  String get moodMatcherDesc =>
      'A fun pattern-matching game to sharpen your focus.';

  @override
  String get aiQuestTitle => 'AI Reflective Quest';

  @override
  String get aiQuestDesc =>
      'Embark on a personal journey of self-discovery powered by AI.';

  @override
  String minCount(int count) {
    return '$count min';
  }

  @override
  String get learnersNook => 'Learner\'s Nook';

  @override
  String get browseTopics => 'Browse Topics';

  @override
  String get myFeed => 'My Feed';

  @override
  String unfollowedCategory(String category) {
    return 'Unfollowed $category';
  }

  @override
  String followingCategory(String category) {
    return 'Following $category';
  }

  @override
  String get noTopicsAvailable => 'No topics available';

  @override
  String get checkBackSoonTopics => 'Check back soon for new topics!';

  @override
  String get feedEmpty => 'Your feed is empty';

  @override
  String get followTopicsToSeeArticles =>
      'Follow some topics to see articles here!';

  @override
  String articlesCount(int count) {
    return '$count articles';
  }

  @override
  String followersCount(int count) {
    return '$count followers';
  }

  @override
  String readMoreAbout(String title) {
    return 'Read more about $title';
  }

  @override
  String get searchPagesHint => 'Search pages...';

  @override
  String get all => 'All';

  @override
  String get noPagesFound => 'No pages found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get noPagesInCategory => 'No pages available in this category';

  @override
  String followerCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count followers',
      one: '1 follower',
    );
    return '$_temp0';
  }

  @override
  String get moodCategory => 'Mood';

  @override
  String get sleepCategory => 'Sleep';

  @override
  String get stressCategory => 'Stress';

  @override
  String get relationshipsCategory => 'Relationships';

  @override
  String get beginner => 'Beginner';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get counselorDefaultName => 'Counselor';

  @override
  String get counselorCredentialsDefault => 'Licensed Clinical Psychologist';

  @override
  String get tagsLabel => 'Tags';

  @override
  String partOfTopic(String category) {
    return 'Part of $category topic';
  }

  @override
  String get iveReadThis => 'I\'ve read this!';

  @override
  String get noFollowedPages => 'No followed pages yet';

  @override
  String get startFollowingToSee =>
      'Start following pages to see them here. Discover new content to follow!';

  @override
  String get couldNotLoadFollowedPages => 'Could not load followed pages.';

  @override
  String get couldNotLoadPageDetails => 'Could not load page details';

  @override
  String byAuthor(String author) {
    return 'By $author';
  }

  @override
  String weeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String monthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String get analysisComplete =>
      'Analysis complete! Check for new recommendations.';

  @override
  String get noNewRecommendations => 'No new recommendations at this time.';

  @override
  String get analyzingJourney => 'Analyzing your journey...';

  @override
  String get noAiPicks => 'No AI picks yet!';

  @override
  String get aiPicksDesc =>
      'Keep journaling and exploring! Our AI will analyze your journey and suggest personalized content.';

  @override
  String get couldNotLoadAiRecs => 'Could not load AI recommendations.';

  @override
  String get noPicksYet => 'No picks yet!';

  @override
  String get picksDesc =>
      'Keep journaling and exploring! Your personalized picks will appear here as we learn more about your journey.';

  @override
  String get couldNotLoadPicks => 'Could not load your picks.';

  @override
  String get aiPickLabel => 'AI PICK';

  @override
  String get smartPickLabel => 'SMART PICK';

  @override
  String get relatedArticle => 'Related Article:';

  @override
  String errorLabel(String message) {
    return 'Error: $message';
  }

  @override
  String get channels => 'Channels';

  @override
  String get hideComments => 'Hide comments';

  @override
  String get viewComments => 'View comments';

  @override
  String get addCommentHint => 'Add a comment...';

  @override
  String get refreshPostsTooltip => 'Refresh posts';

  @override
  String get followingTooltip => 'Following';

  @override
  String get followTooltip => 'Follow';

  @override
  String reactionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reactions',
      one: '1 reaction',
    );
    return '$_temp0';
  }

  @override
  String get privacyHubTitle => 'Privacy Hub';

  @override
  String get coreTransparency => 'Core Transparency';

  @override
  String get sharingVisibility => 'Sharing & Visibility';

  @override
  String get personalGrowthData => 'Personal Growth Data';

  @override
  String get counselorAccess => 'Counselor Access';

  @override
  String get oversightTitle => 'Guardian Oversight';

  @override
  String get oversightDescription =>
      'Your guardian can see your mood trends but not your private journals.';

  @override
  String get dataPrivacyTitle => 'Data Privacy';

  @override
  String get dataPrivacyDescription =>
      'Your personal data is encrypted and stored securely.';

  @override
  String get aiAnalysisTitle => 'AI Analysis';

  @override
  String get aiAnalysisDescription =>
      'AI analyzes your patterns to provide helpful insights.';

  @override
  String get activitySharingTitle => 'Activity Sharing';

  @override
  String get activitySharingDescription =>
      'You can choose which activities to share with others.';

  @override
  String get totalLabel => 'Total';

  @override
  String get followingLabel => 'Following';

  @override
  String get inThisTabLabel => 'In this tab';

  @override
  String get emotionalInsights => 'Emotional Insights';

  @override
  String get moodDistribution => 'Mood Distribution';

  @override
  String get allTime => 'All time';

  @override
  String get thisMonth => 'This Month';

  @override
  String get todaysInsights => 'Today\'s Insights';

  @override
  String get weeklyInsights => 'Weekly Insights';

  @override
  String get monthlyInsights => 'Monthly Insights';

  @override
  String get analysisPending => 'Analysis pending...';

  @override
  String get nameCannotContainNumbers => 'Full name cannot contain numbers';

  @override
  String get noChannelsYet => 'No channels yet';

  @override
  String get noChannelsToDiscover => 'No channels to discover';

  @override
  String get followFromDiscoverNote =>
      'Follow channels from the Discover tab to see them here.';

  @override
  String get checkBackLaterForChannels => 'Check back later for new channels!';

  @override
  String get browseAllChannels => 'Browse All Channels';

  @override
  String get noPostsYet => 'No posts yet.';

  @override
  String get counselorUpdatesNote => 'Counselors will post updates here.';

  @override
  String commentsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get interactionControls => 'Interaction Controls';

  @override
  String get generalParticipation => 'General Participation';

  @override
  String get generalParticipationDesc =>
      'This allows Neuronet AI to analyze your journal entries for emotional patterns. If disabled, entries are stored but not analyzed.';

  @override
  String get aiInsightsSummaries => 'AI Insights & Summaries';

  @override
  String get aiInsightsSummariesDesc =>
      'Your guardian and counselor can view summaries of your emotional trends.';

  @override
  String get safetyAlerts => 'Safety Alerts';

  @override
  String get safetyAlertsDesc =>
      'Real-time notifications sent to your guardian when high-risk patterns are identified.';

  @override
  String get counselorConnection => 'Counselor Connection';

  @override
  String get counselorConnectionDesc =>
      'Allows your school counselor to view your profile and participate in your growth journey.';

  @override
  String get directMessaging => 'Direct Messaging';

  @override
  String get directMessagingDesc =>
      'Enable secure messaging between you, your guardian, and your counselor.';

  @override
  String get couldNotLoadPrivacy => 'Could not load privacy settings.';

  @override
  String get participationPausedNote => 'Paused: General Participation is off';

  @override
  String get understandingPrivacy => 'Understanding Your Privacy';

  @override
  String get privacyEducation1 =>
      'Your guardian manages these settings to ensure you have the right support.';

  @override
  String get privacyEducation2 =>
      'If you have questions about these settings, we encourage you to discuss them with your guardian.';

  @override
  String get privacyEducation3 =>
      'Neuronet uses AI only for emotional insight, never for clinical diagnosis.';

  @override
  String get yourPrivacyMatters => 'Your Privacy Matters';

  @override
  String get transparencyNote =>
      'We value transparency. Below are the oversight settings currently active for your account.';

  @override
  String get granted => 'Granted';

  @override
  String get revoked => 'Revoked';

  @override
  String get paused => 'Paused';

  @override
  String get composeEntry => 'Compose Entry';

  @override
  String intensityLevel(int level) {
    return 'Intensity: $level';
  }

  @override
  String get couldNotLoadAlerts => 'Could not load alerts.';

  @override
  String get refreshingDashboard => 'Refreshing dashboard...';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get boxBreathingTitle => 'Box Breathing';

  @override
  String get boxBreathingDesc => 'Calm your mind & find your focus.';

  @override
  String get phasePrepare => 'Prepare';

  @override
  String get phaseInhale => 'Inhale';

  @override
  String get phaseHold => 'Hold';

  @override
  String get phaseExhale => 'Exhale';

  @override
  String get phaseReady => 'Ready?';

  @override
  String get focusOnBreath => 'Focus on your breath...';

  @override
  String get tapOrbToStart => 'Tap the orb to start your quest';

  @override
  String get reflectedOnThis => 'I\'ve reflected on this';

  @override
  String get quest1 =>
      'If your current mood was a weather pattern, what would it look like right now?';

  @override
  String get quest2 =>
      'Identify one thing you can control in your life today, and one thing you can let go.';

  @override
  String get quest3 =>
      'Imagine a future version of yourself who is completely at peace. What\'s the one piece of advice they\'d give you?';

  @override
  String get quest4 =>
      'What\'s a small act of kindness you\'ve witnessed or done recently that stayed with you?';

  @override
  String yourMoodMatchScore(int score) {
    return 'Your Mood Match score: $score';
  }

  @override
  String get howToPlay => 'How to Play';

  @override
  String get moodMatcherInstructions =>
      'Tap the mood icon that matches the target as fast as you can!';

  @override
  String get findThisMood => 'FIND THIS MOOD:';

  @override
  String scoreLabel(int score) {
    return 'Score: $score';
  }

  @override
  String timeLabel(int time) {
    return 'Time: $time';
  }

  @override
  String get pageFollowed => 'Page followed!';

  @override
  String get pageUnfollowed => 'Page unfollowed';

  @override
  String get failedToUnfollowPage => 'Failed to unfollow page';

  @override
  String get failedToFollowPage => 'Failed to follow page';

  @override
  String get unfollowTooltip => 'Unfollow';

  @override
  String get approvalRequired => 'Approval Required';

  @override
  String get needGuardianApprovalDesc =>
      'You need guardian approval to communicate with this counselor. Request approval to start chatting.';

  @override
  String get alertTriggeredRequest => 'Alert-triggered request';

  @override
  String get aiAlertDetails => 'AI Alert Details';

  @override
  String get riskLevelLabel => 'Risk Level: ';

  @override
  String riskScoreLabel(double score) {
    return 'Risk Score: $score%';
  }

  @override
  String get approvedByGuardian => 'Approved by guardian';

  @override
  String get approvalRevoked => 'Approval Revoked';

  @override
  String get guardianRevokedApprovalDesc =>
      'Your guardian has revoked approval for this counselor. You can request approval again to continue chatting.';

  @override
  String get guardianDeniedRequestDesc =>
      'Your guardian has denied this request. You can submit a new request with more details.';

  @override
  String get checking => 'Checking...';

  @override
  String get failedToLoadAlertDetails => 'Failed to load alert details';

  @override
  String patternNoticedOn(String date) {
    return 'Pattern noticed on $date';
  }

  @override
  String get whatWeNoticed => 'What we noticed';

  @override
  String get feelingsPickedUp => 'Feelings we picked up on';

  @override
  String get groupsHelp => 'Groups that might help';

  @override
  String get channelRecSubtitle =>
      'Highly recommended for you based on recent journals.';

  @override
  String get leftGroup => 'Left group';

  @override
  String joinedGroup(String name) {
    return 'Joined $name!';
  }

  @override
  String get joined => 'JOINED';

  @override
  String get join => 'JOIN';

  @override
  String get thinkingAboutThis => 'Thinking about this?';

  @override
  String get keepJournaling => 'Keep Journaling';

  @override
  String get journalingSubtitle =>
      'Sharing your thoughts helps us find more patterns.';

  @override
  String get chatWithCounselor => 'Chat with Counselor';

  @override
  String get chatWithCounselorSubtitle =>
      'It\'s always good to reach out if you feel like it.';

  @override
  String get alertDisclaimer =>
      'These insights are patterns we noticed based on your activity. They aren\'t a diagnosis or medical advice. We\'re just here to help you understand your emotional journey.';

  @override
  String get moodPattern => 'Mood Pattern';

  @override
  String get energyShift => 'Energy Shift';

  @override
  String get activityUpdate => 'Activity Update';

  @override
  String get mindfulnessPrompt => 'Mindfulness Prompt';

  @override
  String get chatInsight => 'Chat Insight';

  @override
  String get notice => 'Notice';

  @override
  String get emotionSadness => '😔 Feeling down';

  @override
  String get emotionLoneliness => '🫂 Feeling alone';

  @override
  String get emotionHopelessness => '💭 Tough thoughts';

  @override
  String get emotionFear => '😨 Feeling scared';

  @override
  String get emotionAnger => '😤 Feeling frustrated';

  @override
  String get emotionNervousness => '😰 Feeling nervous';

  @override
  String get emotionAnxiety => '🌊 Waves of worry';

  @override
  String get emotionDisappointment => '😞 Disappointed';

  @override
  String get emotionGrief => '💔 Heavy heart';

  @override
  String get emotionAnnoyance => '😒 Annoyed';

  @override
  String get emotionConfusion => '🤔 Confused';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get followChannelTooltip => 'Follow channel';

  @override
  String get channelLabel => 'Channel';

  @override
  String get userLabel => 'User';

  @override
  String get unauthorizedAdolescentAccess =>
      'Unauthorized access: This account does not have Adolescent privileges.';

  @override
  String get unauthorizedRoleMismatch =>
      'Unauthorized access: Account role mismatch.';

  @override
  String get invalidEmailError => 'Please enter a valid email address.';

  @override
  String get callError => 'Call Error';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get unknownCaller => 'Unknown Caller';

  @override
  String get calling => 'Calling...';

  @override
  String get endCall => 'End Call';

  @override
  String get accept => 'Accept';

  @override
  String get connected => 'Connected';

  @override
  String get connecting => 'Connecting';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get camera => 'Camera';

  @override
  String get camOff => 'Cam Off';

  @override
  String get flip => 'Flip';

  @override
  String get speaker => 'Speaker';

  @override
  String get insufficientData => 'Insufficient data for analysis.';

  @override
  String get micPermissionRequired =>
      'Microphone permission is required to record voice messages.';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String failedToPickVideo(String error) {
    return 'Failed to pick video: $error';
  }

  @override
  String get playVideo => 'Play Video';

  @override
  String get shareMedia => 'Share Media';

  @override
  String get gallery => 'Gallery';

  @override
  String get cameraLabel => 'Camera';

  @override
  String get videoLabel => 'Video';

  @override
  String get preparingMedia => 'Preparing media...';

  @override
  String get tapToDownload => 'Tap to download';

  @override
  String get voiceLabel => 'Voice';

  @override
  String get contactLabel => 'Contact';

  @override
  String get emptyMessage => '(empty message)';

  @override
  String get attachmentLabel => 'Attachment';

  @override
  String get mindfulFocusTip => 'Keep your head still and follow the dot.';

  @override
  String get supportGroup => 'Support Group';

  @override
  String get educationalLabel => 'Educational';

  @override
  String get supportLabel => 'Support';

  @override
  String get discussionLabel => 'Discussion';

  @override
  String get resourcesLabel => 'Resources';

  @override
  String get activeLabel => 'Active';

  @override
  String get postLabel => 'Post';

  @override
  String get safeSpaceCounselor =>
      'Safe space for counselor guidance and updates.';

  @override
  String get guardianOverview => 'Guardian Overview';

  @override
  String get linkedAdolescents => 'Linked Adolescents';

  @override
  String riskLevel(String risk) {
    return 'Risk Level: $risk';
  }

  @override
  String get lowRisk => 'LOW';

  @override
  String get mediumRisk => 'MEDIUM';

  @override
  String get highRisk => 'HIGH';

  @override
  String severityRisk(String risk) {
    return '$risk RISK';
  }

  @override
  String get viewAlerts => 'View Alerts';

  @override
  String get viewAlertsSubtitle => 'Check active alerts for your adolescents';

  @override
  String get addAdolescent => 'Add Adolescent';

  @override
  String get addAdolescentSubtitle =>
      'Link a new account to your command center';

  @override
  String get pendingActivations => 'Pending Activations';

  @override
  String get noAdolescentsAwaitingActivation =>
      'No adolescents awaiting activation';

  @override
  String adolescentsAwaitingActivation(int count) {
    return '$count adolescent(s) awaiting activation';
  }

  @override
  String get counselorApprovals => 'Counselor Approvals';

  @override
  String get counselorApprovalsSubtitle =>
      'Manage counselor communication requests';

  @override
  String get noDashboardData => 'No dashboard data available.';

  @override
  String get dataUnavailable => 'Data Unavailable';

  @override
  String get guardianDataUnavailableDesc =>
      'Guardian activity data is temporarily unavailable. Quick Actions are active.';

  @override
  String get adolescentsLabel => 'Adolescents';

  @override
  String get totalJournalsLabel => 'Total Journals';

  @override
  String get emotionalTrends => 'Emotional Trends';

  @override
  String get noTrendDataYet => 'No Trend Data Yet';

  @override
  String get noTrendDataDesc =>
      'Trend visualization will appear once mood entries are recorded by linked adolescents.';

  @override
  String get sevenDays => '7d';

  @override
  String get fourteenDays => '14d';

  @override
  String get thirtyDays => '30d';

  @override
  String get aggregatedInsights => 'Aggregated Insights';

  @override
  String get averageMoodSentiment => 'Average Mood Sentiment';

  @override
  String allAdolescentsSubtitle(String period) {
    return 'Across all linked adolescents (last $period)';
  }

  @override
  String get alertsSummary => 'Alerts Summary';

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String alertsSeverityBreakdown(int low, int med, int high) {
    return 'Low: $low, Medium: $med, High: $high';
  }

  @override
  String get activityStats => 'Activity Stats';

  @override
  String journalMoodStats(int journalCount, int moodCount) {
    return '$journalCount journals, $moodCount mood entries';
  }

  @override
  String adolescentsLinked(int count) {
    return '$count adolescent(s) linked';
  }

  @override
  String get adolescentProfiles => 'Adolescent Profiles';

  @override
  String get failedToLoadAdolescents => 'Failed to load adolescents';

  @override
  String get registerAdolescentGetStarted =>
      'Register an adolescent to get started.';

  @override
  String get interventionHub => 'Intervention Hub';

  @override
  String get registrationDetails => 'Registration Details';

  @override
  String get relationship => 'Relationship';

  @override
  String get linkedSince => 'Linked Since';

  @override
  String get activePermissions => 'Active Permissions';

  @override
  String get noConsentsFound => 'No Consents Found';

  @override
  String get noConsentsFoundDesc =>
      'No consents record found for this account.';

  @override
  String get manageAllConsents => 'Manage All Consents';

  @override
  String get unlinkAccount => 'Unlink This Account';

  @override
  String get personalAccountTag => 'PERSONAL ACCOUNT';

  @override
  String get aiGuide => 'AI Guide';

  @override
  String get viewTips => 'View tips';

  @override
  String get followsLabel => 'Follows';

  @override
  String get educationalPagesSubtitle => 'Educational pages';

  @override
  String get activeStatus => 'ACTIVE';

  @override
  String get disabledStatus => 'DISABLED';

  @override
  String get guardianPortal => 'Guardian Portal 👋';

  @override
  String get secureAccessOversight => 'Secure access for oversight';

  @override
  String get newGuardianPrompt => 'New Guardian?';

  @override
  String get noAdolescentsLinked => 'No Adolescents Linked';

  @override
  String get sendMessage => 'Send message';

  @override
  String get alertsHistory => 'Alerts History';

  @override
  String get filterBySeverity => 'Filter by Severity';

  @override
  String get noAlertsFound => 'No Alerts Found';

  @override
  String get noAlertsYet => 'No alerts yet';

  @override
  String get noAlertsYetDesc =>
      'We will notify you if any concerning patterns appear.';

  @override
  String noAlertsFoundDescFiltered(String severity) {
    return 'No alerts match the \"$severity\" severity filter.';
  }

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get securityAlerts => 'Security Alerts';

  @override
  String get adolescentProfile => 'Adolescent Profile';

  @override
  String get registerNewAdolescent => 'Register New Adolescent';

  @override
  String get approvalRequests => 'Approval Requests';

  @override
  String get noApprovalRequests => 'No Approval Requests';

  @override
  String get noApprovalRequestsDesc =>
      'Approval requests from your adolescents will appear here';

  @override
  String get pending => 'Pending';

  @override
  String get noPendingRequests => 'No Pending Requests';

  @override
  String get noPendingRequestsDesc =>
      'All approval requests have been reviewed';

  @override
  String get noHistory => 'No History';

  @override
  String get noHistoryDesc => 'Reviewed approval requests will appear here';

  @override
  String get revokeApproval => 'Revoke Approval';

  @override
  String get revoke => 'Revoke';

  @override
  String get approvalRevokedSuccess => 'Approval revoked successfully';

  @override
  String get deny => 'Deny';

  @override
  String get approve => 'Approve';

  @override
  String get secureAccessWithCode => 'Secure your access with your code';

  @override
  String get accountEmail => 'Account Email';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get createAccount => 'Create account';

  @override
  String get empowerParentingJourney => 'Empower your parenting journey';

  @override
  String get alreadyGuardian => 'Already a Guardian?';

  @override
  String get dataAndPrivacy => 'Data & Privacy';

  @override
  String get manageDataProcessed => 'Manage how data is processed';

  @override
  String get safetyMonitoring => 'Safety Monitoring';

  @override
  String get proactiveAlertsSupport => 'Proactive alerts and support';

  @override
  String get noLinkedAccounts => 'No Linked Accounts';

  @override
  String get consentManagementAwaitsLink =>
      'Consent management will appear once an adolescent account is linked.';

  @override
  String pickedForUser(String name) {
    return 'Picked for $name';
  }

  @override
  String get empowerGrowth => 'Empower Growth';

  @override
  String get consentDrivenOversight => 'Consent-Driven Oversight';

  @override
  String get stayInformedRespectPrivacy => 'Stay Informed, Respect Privacy';

  @override
  String get updateProfile => 'Update Profile';

  @override
  String get completeRegistration => 'Complete Registration';

  @override
  String get adolescentFullName => 'Adolescent\'s Full Name';

  @override
  String get supportEmailRequired => 'Support Email (Required)';

  @override
  String get returnToDashboard => 'Return to Dashboard';

  @override
  String get activationCodeCopied => 'Activation code copied';

  @override
  String get alertResolvedSuccess => 'Alert resolved successfully';

  @override
  String failedToResolveAlert(String error) {
    return 'Failed to resolve alert: $error';
  }

  @override
  String get markAsResolved => 'Mark as Resolved';

  @override
  String get errorLoadingAlerts => 'Failed to load alerts.';

  @override
  String get alertNotFound => 'Alert Not Found';

  @override
  String get alertNotFoundDesc =>
      'This alert may have been resolved or deleted.';

  @override
  String addedDateLabel(String date) {
    return 'Added $date';
  }

  @override
  String get waitingForConnection => 'Waiting for Connection';

  @override
  String get waitingForConnectionDesc =>
      'Ensure your adolescent enters the activation code on their device to establish the encrypted emotional health monitoring link.';

  @override
  String get viewActivationInfo => 'View Activation Info';

  @override
  String get accountDetails => 'Account Details';

  @override
  String get alertAnalysis => 'Alert Analysis';

  @override
  String get aiInsight => 'AI Insight';

  @override
  String get detectedEmotions => 'Detected Emotions';

  @override
  String get triggerDetails => 'Trigger Details';

  @override
  String get resolutionNotes => 'Resolution Notes';

  @override
  String get resolutionNotesHint =>
      'Add any notes about how this alert was addressed...';

  @override
  String get generalBehavioralCheck => 'General Behavioral Check';

  @override
  String get emotionalContext => 'Emotional Context';

  @override
  String get triggerPattern => 'Trigger Pattern';

  @override
  String get resolutionGuardrail => 'Resolution & Guardrail';

  @override
  String get enterObservations => 'Enter observations or actions taken...';

  @override
  String get history => 'History';

  @override
  String get failedToLoadApprovals => 'Failed to load approval requests';

  @override
  String get requestApproved => 'Request approved';

  @override
  String get requestDenied => 'Request denied';

  @override
  String get revokeApprovalDesc =>
      'Are you sure you want to revoke this approval? The adolescent will no longer be able to communicate with this counselor, but can request approval again.';

  @override
  String get wantsToCommunicate => 'wants to communicate with counselor';

  @override
  String get reasonLabel => 'Reason';

  @override
  String requestedDateLabel(String date) {
    return 'Requested $date';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get activationSuccess => 'Account activated! Please login.';

  @override
  String get invalidEmail => 'Invalid email';

  @override
  String get enterActivationCode => 'Enter activation code';

  @override
  String get min6Characters => 'Min 6 characters';

  @override
  String get signUpSuccess => 'Registration successful! Please login.';

  @override
  String get errorDuringSignUp => 'An error occurred during signup';

  @override
  String get enterFullName => 'Enter your full name';

  @override
  String get signUpNow => 'Sign Up Now';

  @override
  String get guardianEmail => 'Guardian Email';

  @override
  String get createPassword => 'Create Password';

  @override
  String get privacyOversight => 'Privacy & Oversight';

  @override
  String get refreshSettingsTooltip => 'Refresh settings';

  @override
  String get failedToLoadSettings => 'Failed to load settings';

  @override
  String get securityHub => 'Security Hub';

  @override
  String get consentHeroDesc =>
      'Configure how Neuronet supports your adolescent. Balance their journey toward independence with the oversight needed for a safe environment.';

  @override
  String get consentRevokedSuccess => 'Consent revoked successfully';

  @override
  String failedToRevokeConsent(String error) {
    return 'Failed to revoke consent: $error';
  }

  @override
  String get consentGrantedSuccess => 'Consent granted successfully';

  @override
  String failedToGrantConsent(String error) {
    return 'Failed to grant consent: $error';
  }

  @override
  String settingsForAdolescent(String email) {
    return 'Settings for $email';
  }

  @override
  String get consentParticipationLabel => 'General Participation & AI Analysis';

  @override
  String get consentParticipationDesc =>
      'Enable AI-driven emotional analysis and trend detection for all journals.';

  @override
  String get consentShareAiSummariesLabel => 'AI Summaries & Risk Levels';

  @override
  String get consentShareAiSummariesDesc =>
      'Allow viewing of AI-generated emotional summaries and designated risk levels.';

  @override
  String get consentShareAlertsLabel => 'Security Alerts & Notifications';

  @override
  String get consentShareAlertsDesc =>
      'Receive immediate notifications when critical emotional patterns or risks are detected.';

  @override
  String get consentCounselorChatLabel => 'Counselor Private Messaging';

  @override
  String get consentCounselorChatDesc =>
      'Authorize private one-on-one communication with assigned counselors.';

  @override
  String chattingAboutAdolescent(String name) {
    return 'Chatting about $name';
  }

  @override
  String get noCounselorLinked => 'No Counselor Linked';

  @override
  String noCounselorLinkedDesc(String name) {
    return 'A counselor hasn\'t been assigned or linked to $name\'s account yet.';
  }

  @override
  String notLinkedToCounselor(String name) {
    return '$name is not currently linked to a counselor.';
  }

  @override
  String get counselorAssistanceAwaits =>
      'Communication and collaboration will appear here once a connection is established.';

  @override
  String get startCollaboration => 'Start Collaboration';

  @override
  String regardingAdolescent(String name) {
    return 'Regarding: $name';
  }

  @override
  String get chatEnabledConsent => 'Chat enabled - Adolescent consent on file';

  @override
  String get chatDisabledConsent =>
      'Chat disabled - Adolescent consent required';

  @override
  String get noCounselorAssigned => 'No Counselor Assigned';

  @override
  String noCounselorAssignedDesc(String name) {
    return 'An assigned counselor is required to start a conversation. Please wait for the school administration to assign a professional to $name.';
  }

  @override
  String get startConversationWithCounselorSimple =>
      'Start a conversation with the counselor';

  @override
  String get noFollowsFound => 'No followed pages found';

  @override
  String noFollowsFoundDesc(String name) {
    return '$name hasn\'t followed any educational pages yet.';
  }

  @override
  String noPicksYetDesc(String name) {
    return 'Personalized recommendations will appear here as $name continues journaling and exploring.';
  }

  @override
  String get couldNotLoadRecs => 'Could not load recommendations.';

  @override
  String followedDateLabel(String date) {
    return 'Followed $date';
  }

  @override
  String get recently => 'Recently';

  @override
  String viewsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count views',
      one: '1 view',
    );
    return '$_temp0';
  }

  @override
  String get deleteMessageTitle => 'Delete Message';

  @override
  String get deleteMessageConfirm =>
      'Are you sure you want to delete this message? This action cannot be undone.';

  @override
  String get deleteLabel => 'Delete';

  @override
  String get cancelLabel => 'Cancel';

  @override
  String get you => 'You';

  @override
  String get decline => 'Decline';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get enrollAdolescent => 'Enroll Adolescent';

  @override
  String get newEnrollment => 'New Enrollment';

  @override
  String get newEnrollmentDesc =>
      'Connect your child to the Neuronet platform to begin monitoring their emotional health and guiding their developmental journey.';

  @override
  String get enrollmentSuccess => 'Enrollment Successful!';

  @override
  String get enrollmentSuccessDesc =>
      'Registration complete. Please share this activation code with your adolescent. They will need it to link their device to your account.';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get finish => 'Finish';

  @override
  String get saveUpper => 'SAVE';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordDesc => 'Leave blank to keep current password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get registrationComplete => 'Registration Complete';

  @override
  String get loginSecurely => 'Login Securely';

  @override
  String dashboardDataFailedToLoad(String error) {
    return 'Dashboard data failed to load: $error';
  }

  @override
  String get emailAddressNonEditable => 'Email Address (Non-editable)';

  @override
  String get security => 'Security';

  @override
  String get passwordProtectionAdvice =>
      'Use a strong password to protect your account and the sensitive emotional health data you monitor.';

  @override
  String get initialCapabilities => 'Initial Capabilities';

  @override
  String get initialCapabilitiesDesc =>
      'Select the features you want to enable initially. You can adjust these granularly after enrollment.';

  @override
  String get enrollmentComplete => 'Enrollment Complete!';

  @override
  String get enrollmentCompleteDesc =>
      'Your adolescent has been successfully registered. Share this activation code with them to link their device.';

  @override
  String get activationCodeUpper => 'ACTIVATION CODE';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get selectDate => 'Select Date';

  @override
  String get relationshipToAdolescent => 'Relationship to Adolescent';

  @override
  String get pleaseFillRequiredFields => 'Please fill in all required fields';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address';

  @override
  String failedToRegisterAdolescent(Object error) {
    return 'Failed to register adolescent: $error';
  }

  @override
  String get loginTaglineEmpathy => 'Oversight with Empathy ❤️';

  @override
  String get loginTaglineSupport => 'Secure Support for your Teens 🛡️';

  @override
  String get loginTaglinePeace => 'Peace of mind, anytime ✨';

  @override
  String get atLeast6Characters => 'At least 6 characters';

  @override
  String get activateCode => 'Activate Code';

  @override
  String get guardianDataEncrypted =>
      'Guardian Data is Encrypted & HIPAA Compliant';

  @override
  String get failedToLoadAlerts => 'Failed to load alerts. Please try again.';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get unauthorizedGuardianAccess =>
      'Unauthorized access: This account does not have Guardian privileges.';

  @override
  String get parent => 'Parent';

  @override
  String get legalGuardian => 'Legal Guardian';

  @override
  String get other => 'Other';

  @override
  String get notAvailable => 'N/A';
}
