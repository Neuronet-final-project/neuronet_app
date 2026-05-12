// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'NEURONET';

  @override
  String get login => 'ግባ';

  @override
  String get logout => 'ውጣ';

  @override
  String get home => 'መነሻ';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get profile => 'መገለጫ';

  @override
  String get journal => 'ጆርናል';

  @override
  String get chat => 'ውይይት';

  @override
  String get mood => 'ስሜት';

  @override
  String get alerts => 'ማሳወቂያዎች';

  @override
  String get retry => 'እንደገና ሞክር';

  @override
  String get failedToLoadDashboard => 'ዳሽቦርዱን መጫን አልተቻለም';

  @override
  String get goodMorning => 'እንደምን አደርክ';

  @override
  String get goodAfternoon => 'እንደምን ዋልክ';

  @override
  String get goodEvening => 'እንደምን አመሸህ';

  @override
  String get howAreYouFeeling => 'ምን ይሰማሃል?';

  @override
  String get allMoods => 'ሁሉም ስሜቶች →';

  @override
  String get quickActions => 'ፈጣን እርምጃዎች';

  @override
  String get recentJournals => 'የቅርብ ጊዜ ጆርናሎች';

  @override
  String get viewAll => 'ሁሉንም ተመልከት →';

  @override
  String get personalInsight => 'የግል ግንዛቤ';

  @override
  String get weGotYou => 'ከጎንህ ነን 💙';

  @override
  String get tryThisToday => 'ዛሬ ይህንን ይሞክሩ';

  @override
  String get more => 'ተጨማሪ →';

  @override
  String get recommendedForYou => 'ለእርስዎ የተመከሩ';

  @override
  String get playAndRelax => 'ይጫወቱ እና ይዝናኑ';

  @override
  String get newTag => 'አዲስ';

  @override
  String get myProfile => 'የእኔ መገለጫ';

  @override
  String get accountInformation => 'የመለያ መረጃ';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get emailAddress => 'ኢሜይል አድራሻ';

  @override
  String get accountStatus => 'የመለያ ሁኔታ';

  @override
  String get privacyAndPermissions => 'ግላዊነት እና ፈቃዶች';

  @override
  String get consentStatus => 'የፈቃድ ሁኔታ';

  @override
  String get viewConsentDescription => 'አሳዳጊዎ የፈቀዱትን ይመልከቱ';

  @override
  String get signOut => 'ውጣ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get selectLanguage => 'ቋንቋ ይምረጡ';

  @override
  String get adolescent => 'ታዳጊ';

  @override
  String heyUser(String name) {
    return 'ሰላም $name 👋';
  }

  @override
  String get innerWorldPrompt => 'ዛሬ ውስጣዊ አለምህ እንዴት ነው?';

  @override
  String get writeJournal => 'ጆርናል ጻፍ';

  @override
  String get expressYourself => 'ራስህን ግለጽ 📝';

  @override
  String get aiCompanion => 'የAI ረዳት';

  @override
  String get talkItOut => 'አውራ 🤖';

  @override
  String get checkYourMood => 'ስሜትዎን ያረጋግጡ';

  @override
  String get moodEmojiPrompt => 'ምን ይሰማሃል? 😊';

  @override
  String get learnAndGrow => 'ይማሩ እና ያድጉ';

  @override
  String get exploreResources => 'ግብዓቶችን ያስሱ 📚';

  @override
  String get smallCheckIn => 'ትንሽ ቆይታ ትልቅ ለውጥ ያመጣል።';

  @override
  String get today => 'ዛሬ';

  @override
  String get take30Seconds => '30 ሰከንድ ይውሰዱ።';

  @override
  String get namingFeelings => 'የሚሰማዎቱን ስም መስጠት የግማህ ስራ ነው።\nቀሪውን እኛ እንረዳለን።';

  @override
  String get checkInNow => 'አሁን ይመዝገቡ';

  @override
  String get journals => 'ጆርናሎች';

  @override
  String get moods => 'ስሜቶች';

  @override
  String get forYou => 'ለእርስዎ';

  @override
  String get journalToday => 'ዛሬ';

  @override
  String get journalYesterday => 'ትናንት';

  @override
  String daysAgo(int count) {
    return 'ከ $count ቀናት በፊት';
  }

  @override
  String get journalEntryDefault => 'የጆርናል መዝገብ';

  @override
  String feelingLabel(String mood) {
    return 'ስሜት $mood';
  }

  @override
  String minRead(int count) {
    return '$count ደቂቃ ንባብ';
  }

  @override
  String get readNow => 'አሁን ያንብቡ';

  @override
  String get mindfulnessGames => 'የአስተሳሰብ ጨዋታዎች';

  @override
  String get boostYourMood => 'በአዝናኝ እና በሳይንስ በተደገፅ እንቅስቃሴዎች ስሜትዎን ያሳድጉ።';

  @override
  String get playNow => 'አሁን ይጫወቱ';

  @override
  String get ai => 'AI';

  @override
  String get notificationSettings => 'የማሳወቂያ ቅንብሮች';

  @override
  String get alertNotifications => 'የማሳወቂያ ማሳወቂያዎች';

  @override
  String get counselorMessages => 'የአማካሪ መልእክቶች';

  @override
  String get getNotifiedPatterns => '� pattern የተገኙ ድንጋጠ ማሳዎች ያስተዳድሉ';

  @override
  String get pushNotificationsNewMessages => 'አዳዲሞ መልእክቶች የpush ማሳዎች';

  @override
  String get role => 'ሚና';

  @override
  String get guardian => 'አሳዳጊ';

  @override
  String get areYouSureSignOut => 'እንደምን ወደ መለያ መግባት ነው?';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get translate => 'ተርጉም';

  @override
  String get showOriginal => 'ዋናውን አሳይ';

  @override
  String get translating => 'በመተርጎም ላይ...';

  @override
  String get translationError => 'መተርጎም አልተቻለም';

  @override
  String get failedToLoadJournals => 'ጆርናሎችን መጫን አልተቻለም';

  @override
  String get yourJournalAwaits => 'ጆርናልዎ በጠቀሙ ይጠብቃል';

  @override
  String get captureHowYouFeel => 'እንዴት እንደምን ይሰማሃል ይደርስ።\nዘመን ሲደርስ ይተመልከቱ።';

  @override
  String get secureJournalTag => 'የእርስዎ የተለያዩ ጆርናል';

  @override
  String get refreshingJournal => 'ጆርናል የተለያዩ...';

  @override
  String get stillSyncingEntry => 'መዝገብ የተለያዩ ዘዴ ላይ...';

  @override
  String get thisWeek => 'በዚህ ሳምንት';

  @override
  String memoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ማህደኛዎች',
      one: '1 ማህደኛ',
    );
    return '$_temp0';
  }

  @override
  String get openingYourEntry => 'መዝገብዎን በማዕከል...';

  @override
  String get couldNotOpenShare => 'ማኅበረዚያ አይተለያዩም። ጽሁፍ ወደ ቅዱስ ያካበብ።';

  @override
  String get journalNotFound => 'ጆርናል አልተገኙም';

  @override
  String get journalSubject => 'የጆርናል መዝገብዎ';

  @override
  String get pleaseWriteSomething => 'እባክዎ የተለያዩ ይጻፉ';

  @override
  String get journalSaved => 'ጆርናልዎ ተቆል፧';

  @override
  String get newEntryTag => 'አዲስ መዝገብ';

  @override
  String get safeSpaceNote => 'ይህ የእርስዎ የተለያዩ ቦታ ነው። ዛሬ የሚሰማውን ይጻፉ።';

  @override
  String get journalTitleHint => 'አንድ ርዕስ ይስጡ...';

  @override
  String get journalContentHint => 'እዚህ ልምዶችዎን ጀመሩ...';

  @override
  String get sparkSmile => 'ዛሬ የሚያስተምር ምን ነው?';

  @override
  String get sparkGrateful => 'አንድ ነገር እናምን';

  @override
  String get sparkVictory => 'የኔ ትንሽ ድል';

  @override
  String get sparkChallenge => 'በመንበር እንዴት ተወግየ?';

  @override
  String get discoverHeader => 'ፍተኛ ማዕከል';

  @override
  String get searchMemoriesHint => 'ማህደኛዎችን ፈልግ...';

  @override
  String get filterWhen => 'መሀሪያ';

  @override
  String get filterMood => 'ስሜት';

  @override
  String filterResults(int count) {
    return 'የመረጃ ውጤቶች ($count)';
  }

  @override
  String get stillLooking => 'እሱም ፈልግ...';

  @override
  String get filterAll => 'ሁሉም';

  @override
  String get filterToday => 'ዛሬ';

  @override
  String get filterThisWeek => 'በዚህ ሳምንት';

  @override
  String get filterSpecific => 'የተለየ ቀን';

  @override
  String get copiedToClipboard => 'ወደ ቅዱስ ያካበብ';

  @override
  String get aboutJournalPrivacy => 'የጆርናል ግላዊነት ማንበብ';

  @override
  String get journalPrivacyTitle => 'የጆርናል ግላዊነት';

  @override
  String get journalPrivacyContent =>
      'የጆርናል መዝገቦች ለእርስዎ ይቆያሉ። የመተዳደፊ መረጃ አይታያይቁም።';

  @override
  String get gotIt => 'ገብተው';

  @override
  String get backToJournal => 'ወደ ጆርናል';

  @override
  String get entryRemovedNote => 'ጠፋ ወይም የመረጃ መረጃ ይችላሉ።';

  @override
  String get somethingWentWrong => 'የሚያውቅ ነገር ይችላል';

  @override
  String get tryAgain => 'እንደገና ሞክር';

  @override
  String get moodLabel => 'ስሜት';

  @override
  String get wordsLabel => 'ቃላት';

  @override
  String get readLabel => 'አንብብ';

  @override
  String get tipLongPress => 'ማንበብ: የታያዘውን መዝገብ ይቅዱ ወይም የተመረጠውን መልእክት ይቅዱ።';

  @override
  String get yourPrivateSpace => 'የእርስዎ ተለያዩ ቦታ';

  @override
  String get privateSpaceNote =>
      'ይህ መዝገብ ለእርስዎ ይቆያል። አሳዳጊዎች የጆርናል መልእክት አይነበሩም።';

  @override
  String get copyEntry => 'መዝገብ ኮፐ';

  @override
  String get titleAndFullText => 'ርዕስ እና ሙሉ ጽሁፍ';

  @override
  String get writingSparksTag => 'የመጻፍ ብልጭታዎች';

  @override
  String get howAreYouFeelingNow => 'አሁን እንዴት ነው?';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get syncingTag => 'የተለያዩ';

  @override
  String get shareTooltip => 'አጋፍሪ';

  @override
  String get moreTooltip => 'ተጨማሪ';

  @override
  String get moodHappy => 'ደስታ';

  @override
  String get moodSad => 'አዝዩ';

  @override
  String get moodAnxious => 'አዝዩ';

  @override
  String get moodCalm => 'የተለያዩ';

  @override
  String get moodStressed => 'ደህና';

  @override
  String get moodNeutral => 'የተለያዩ';

  @override
  String get moodExcited => 'አስተዳደፊ';

  @override
  String get moodTired => 'ደህና';

  @override
  String get moodAngry => 'አዝዩ';

  @override
  String get moodHopeful => 'ነገር ይችላል';

  @override
  String get dailyCheckInTag => 'የዛሬ የማሳዎች መዝገብ';

  @override
  String get tapEmojiPrompt => 'የአሁን ስሜትዎን የሚያሳይ emoji ይታመን።';

  @override
  String get intensityLabel => 'የተለያዩ';

  @override
  String get mildLabel => 'ትንሽ';

  @override
  String get strongLabel => 'ጠንካራ';

  @override
  String get moodReasonPrompt => 'እንዴት ነው?';

  @override
  String get moodNoteHint => 'የተለያዩ ማስታဋስ... (በአማራጭ)';

  @override
  String get logMoodButton => 'ስሜት አስቀምጥ';

  @override
  String get moodLoggedSuccess => 'ስሜት ተቆል፧!';

  @override
  String get thanksCheckingIn => 'የመዝገብ ማሳዎ አመሰግናለሁ።\nስሜትዎን መከታተያ ይህን ይጠብቁ።';

  @override
  String get logAnotherMood => 'ምንም ስሜት ይጻፉ';

  @override
  String get pastCheckInsHeader => 'የቀደም የማሳዎች';

  @override
  String get failedToLoadHistory => 'ታሪክ አልተገኘም';

  @override
  String get now => 'አሁን';

  @override
  String get minAbbr => 'ደቂቃ';

  @override
  String get hourAbbr => 'ሰዓት';

  @override
  String get dayAbbr => 'ቀን';

  @override
  String get levelAbbr => 'ደረጃ';

  @override
  String get aiAssistant => 'የAI ረዳት';

  @override
  String get typing => 'እንደምን እየጻፈ...';

  @override
  String get online => 'ጋዜጣ';

  @override
  String get loading => 'በመንበር...';

  @override
  String get offline => 'ከመረጃ ውጣ';

  @override
  String get aiAssistantInfo => 'የAI ረዳት መረጃ';

  @override
  String get safetyFirst => 'የመጀመሪያ ደህና';

  @override
  String get safetyFirstDesc =>
      'ይህ AI ለደህና እና ለማንበብ ነው፣ የሕይወት ምክረ ሐይማኖች ወይም ዕድገት አይደለም።';

  @override
  String get yourData => 'የእርስዎ መረጃ';

  @override
  String get yourDataDesc => 'ውይይቶች የደህና ለማዕከል ይቆያሉ እና የትምህርት መሠረት ይኖሩታል።';

  @override
  String get howToUse => 'እንዴት እንደምን እጠብቁ';

  @override
  String get howToUseDesc => 'ለደህና ለትምህርት ወይም የዛሬ ድምፅ ይህን ይጠብቁ።';

  @override
  String get aboutAiAssistant => 'የAI ረዳት ማንበብ';

  @override
  String get unableConnectAi => 'እስከ AI ረዳት አይተገኙም';

  @override
  String get checkInternetTryAgain => 'የመረጃ መረጃ ይህ እና እንደገና ሞክር።';

  @override
  String get startConversation => 'ውይይት ጀመር';

  @override
  String get aiEmptyPrompt => 'ስለ ደህና ወይም ምንም ይጠብቁ።\nእኔ የሚረዳህ ይችላል።';

  @override
  String get aiThinking => 'AI ረዳት እየጠብቁ...';

  @override
  String get aiSafetyDisclaimer =>
      'AI ረዳት የደህና ለማንበብ ነው እና የሕይወት ምክረ ሐይማኖች አይደለም።';

  @override
  String get aiSenderLabel => 'NEURO ረዳት';

  @override
  String get youSenderLabel => 'አንቺ';

  @override
  String get aiPrompt1 => 'እኛ እንደምን እርስዎ?';

  @override
  String get aiPrompt2 => 'እንዴት ጆርናል ይጻፉ?';

  @override
  String get aiPrompt3 => 'ሄን እንደምን መረጃዬ?';

  @override
  String get aiPrompt4 => 'እንዴት እስከ አማካሪ ይጠብቁ?';

  @override
  String get requestApproval => 'ፍቃድ ይጠይቁ';

  @override
  String get checkingApprovalStatus => 'የፍቃድ ሁኔታ እየተያየው...';

  @override
  String get approvalRequest => 'የፍቃድ ጥያቄ';

  @override
  String get approvalPending => 'ፍቃድ በመጠበቅ ላይ ነው';

  @override
  String approvalPendingMessage(String counselorName) {
    return 'የ$counselorName ፍቃድ ጥያቄዎ በመጠበቅ ላይ ነው።';
  }

  @override
  String get guardianReviewingMessage =>
      'አሳዳጊዎ ጥያቄዎን እየግኙት ነው። እንደነገር እንደመለያየት እናመለከታለን።';

  @override
  String get requestSent => 'ጥያቄ ተልከዋል';

  @override
  String get requestSentSuccess => 'ጥያቄ ተልከዋል!';

  @override
  String get approvalSentMessage => 'የፍቃድ ጥያቄዎ እስረድካ ወደ አሳዳጊዎ ተልከዋል።';

  @override
  String get statusPending => 'ሁኔታ: በመጠበቅ ላይ';

  @override
  String get backToChat => 'ወደ የድረስ ውይይት';

  @override
  String get guardianApprovalRequired => 'አሳዳጊ ፍቃድ ያስፈልጋል';

  @override
  String get guardianApprovalExplanation =>
      'ከነገሥታዊ ጋዴር ጋᇹም የመረዳሪያ ሰው ጋᇹም ይኖሩ ይችላሉ። እንዴት እንደምን እስከ እሱ/ጋ ይወዳሉ?';

  @override
  String get counselorLabel => 'መረዳሪያ ሰው';

  @override
  String get counselorChat => 'የመረዳሪያ ሰው ቻት';

  @override
  String get reasonForRequest => 'ምክንያት ይጠይቁ';

  @override
  String get reasonHint => 'ለማንበብ እንደምን እርስዎ?';

  @override
  String get reasonRequired => 'እባክዎ ምክንያት ይጠይቁ';

  @override
  String get reasonMinLength => 'እባክዎ የበይሐ መረጃ (በቤት አንድ 20 የበይሐ)';

  @override
  String get sendRequest => 'ጥያቄ ልክ';

  @override
  String get unableToGetUserInfo => 'የተጠቃሚ መረጃ ማግኘት አልተቻለም። እንደገና ሞክር።';

  @override
  String get pendingRequestExists => 'አለዎ የአሳዳጊ ፍቃድ ጥያቄ አለዎ።';

  @override
  String get alreadyPending => 'በመጠበቅ ላይ ነው';

  @override
  String get approvalRequestAlreadyPending => 'የፍቃድ ጥያቄ በመጠበቅ ላይ ነው';

  @override
  String get profileNotFound => 'የተጠቃሚ መገለጫ አልተገኘም።';

  @override
  String get adolescentAccount => 'የታዳጊ መለያ';

  @override
  String get errorPrefix => 'ስህተት';

  @override
  String get statusActive => 'ንቁ';

  @override
  String get statusInactive => 'ንቁ ያልሆነ';

  @override
  String get statusSuspended => 'የታገደ';

  @override
  String get statusPendingActivation => 'ማግበር በመጠባበቅ ላይ';

  @override
  String appVersion(String version) {
    return 'ኔየሩኔት በስ$version';
  }

  @override
  String guardianAppVersion(String version) {
    return 'ኔየሩኔት ጋርድያን በስ$version';
  }

  @override
  String get profileNotFoundUser => 'የተጠቃሚ መገለጫ አልተገኘም።';

  @override
  String get accountActivatedLogin => 'መለያ ተካችለህ! እንደገና ግባ።';

  @override
  String get activateAccountTitle => 'መለያ አንቀሳቃሽ';

  @override
  String get setUpSecureAccount => 'ዘመናዊ መለያዎን ዘይምርጥ';

  @override
  String get activationCodeHint =>
      'ከአሳዳጊዎ የተሰጠውን የአንቀሳቃሽ ኮድ ይጠቀሙ አንድ ጉዞ ለመጀመር።';

  @override
  String get registeredEmail => 'ዝᏲተውን ኢሜይል';

  @override
  String get activationCode => 'የአንቀሳቃሽ ኮድ';

  @override
  String get activationCodeExample => 'ምንጭ NEURO-2026';

  @override
  String get newPassword => 'አዲስ ፓስዋርድ';

  @override
  String get confirmPassword => 'ፓስዋርድ አረጋ';

  @override
  String get activateAccountButton => 'መለያ አንቀሳቃር';

  @override
  String get passwordPrivacyInfo => 'ፓስዋርድዎ ጆርናልዎን የሚቆይ እና የሚተላለፍ ነው።';

  @override
  String get pleaseEnterEmail => 'ኢሜይልዎን ይጻፉ';

  @override
  String get pleaseEnterActivationCode => 'የአንቀሳቃሽ ኮድን ይጻፉ';

  @override
  String get pleaseEnterPassword => 'ፓስዋርድ ይጻፉ';

  @override
  String get passwordMinLength => 'ፓስዋርድ በቤት አንድ 6 የበይሐ መረጃ ነው';

  @override
  String get passwordsDoNotMatch => 'ፓስዋርዶች አይደለም';

  @override
  String get discoverPages => 'ገጾችን ፈልግ';

  @override
  String get followedPages => 'የሚወዱ ገጾች';

  @override
  String get pickedForYou => 'ለአንቺ ተመርጧል';

  @override
  String get aiPicks => 'AI ይመርጣል';

  @override
  String get popular => 'አብራሪ';

  @override
  String get analyzeNow => 'አሁን በርዳ';

  @override
  String get insightDetail => 'ግንዛቤ ዝግጅት';

  @override
  String get channelNotFound => 'ጭነት አልተገኘም። እንደገና ሞክር።';

  @override
  String get yourChannels => 'የአንቺ ጭነቶች';

  @override
  String get following => 'እንደ';

  @override
  String get follow => 'እንደ';

  @override
  String get requestApprovalAgain => 'ፍቃድ እንደገና ጠይቁ';

  @override
  String get requestAgain => 'እንደገና ጠይቁ';

  @override
  String get goToYourChannels => 'ጭነቶቺን ይሄዱ';

  @override
  String get loginTagline1 => 'የስሜት ድጋፍ ቦታዎ 💜';

  @override
  String get loginTagline2 => 'በዚህ ውስጥ ብቻዎን አይደሉም 🌿';

  @override
  String get loginTagline3 => 'እዚህ ሁሉም ስሜት ተቀባይነት አለው ✨';

  @override
  String get anErrorOccurred => 'ስህተት ተከስቷል';

  @override
  String get welcomeBack => 'እንኳን ደህና መጡ 👋';

  @override
  String get signInToContinue => 'ለመቀጠል ይግቡ';

  @override
  String get emailHint => 'የኢሜይል አድራሻ';

  @override
  String get passwordHint => 'ፓስዋርድ';

  @override
  String get forgotPassword => 'ፓስዋርድ ረስተዋል?';

  @override
  String get newToNeuroNet => 'ለኔየሩኔት አዲስ ነዎት?';

  @override
  String get activateMyAccount => 'መለያዬን አንቀሳቅስ';

  @override
  String get dataPrivateEncrypted => 'የእርስዎ መረጃ የግል እና የተመሰጠረ ነው';

  @override
  String get onboardingTitle1 => 'የእርስዎ ደህንነቱ የተጠበቀ ቦታ';

  @override
  String get onboardingDesc1 =>
      'ለሃሳቦችዎ እና ስሜቶችዎ የግል ቦታ። የእርስዎ ጆርናሎች ለአሳዳጊዎች ወይም አማካሪዎች አይታዩም።';

  @override
  String get onboardingTitle2 => 'ዝንባሌዎን ይረዱ';

  @override
  String get onboardingDesc2 =>
      'የእኛ AI በጊዜ ሂደት የእርስዎን ስሜታዊ ጉዞ ቅጦች ለማየት ይረዳዎታል፣ ይህም በራስዎ ግንዛቤ እንዲያድጉ ይረዳዎታል።';

  @override
  String get onboardingTitle3 => 'ድጋፍ እንጂ ምርመራ አይደለም';

  @override
  String get onboardingDesc3 =>
      'እኛ እርስዎን ለመርዳት እዚህ ነን። የእኛ AI የመረጃ ረዳት እንጂ ሐኪም ወይም አማካሪ አይደለም።';

  @override
  String get onboardingTitle4 => 'ለመጀመር ዝግጁ ነዎት?';

  @override
  String get onboardingDesc4 =>
      'የግል ስሜታዊ ጉዞዎን ለመጀመር በአሳዳጊዎ የተሰጠውን የማግበሪያ ኮድ ይጠቀሙ።';

  @override
  String get noCommentsYet => 'No comments yet.';

  @override
  String get discover => 'ፈልግ';

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
  String get yesterday => 'ትናንት';

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
  String get loadingConsent => 'Checking permissions...';

  @override
  String get unableToStartChat => 'Unable to start chat.';

  @override
  String get noMessagesYet => 'No messages yet.';

  @override
  String get startConversationWithCounselor =>
      'Start a conversation with your counselor.';

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
  String get noAiPicks => 'No AI picks yet';

  @override
  String get aiPicksDesc =>
      'Check back later for personalized recommendations.';

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
  String get noChannelsYet => 'No channels yet';

  @override
  String get noChannelsToDiscover => 'የሚገኙ ቻናሎች የሉም';

  @override
  String get followFromDiscoverNote => 'ቻናሎችን ለማየት ከ\'ፈልግ\' ገጽ ይከተሉ።';

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
  String get guardianOversightNote => 'Guardian Oversight';

  @override
  String get guardianOversightNoteDesc =>
      'Your guardian can see your mood trends but not your private journals.';

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
  String get you => 'You';

  @override
  String get friend => 'friend';

  @override
  String get refreshingDashboard => 'Refreshing dashboard...';

  @override
  String get skip => 'ዝለል';

  @override
  String get next => 'ቀጣይ';

  @override
  String get getStarted => 'እንጀምር';

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
  String get requestDenied => 'Request Denied';

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
      'ያልተፈቀደ መዳረሻ: ይህ መለያ የታዳጊ መብቶች የሉትም::';

  @override
  String get unauthorizedRoleMismatch => 'ያልተፈቀደ መዳረሻ: የመለያ ሚና አለመዛመድ::';

  @override
  String get invalidEmailError => 'እባክዎ ትክክለኛ የኢሜይል አድራሻ ያስገቡ';

  @override
  String get callError => 'የጥሪ ስህተት';

  @override
  String get dismiss => 'አሰናብት';

  @override
  String get unknownCaller => 'ያልታወቀ ደዋይ';

  @override
  String get calling => 'እየደወለ ነው...';

  @override
  String get endCall => 'ጥሪ አቁም';

  @override
  String get decline => 'አትቀበል';

  @override
  String get accept => 'ተቀበል';

  @override
  String get connected => 'ተገናኝቷል';

  @override
  String get connecting => 'በመገናኘት ላይ...';

  @override
  String get mute => 'ድምፅ አጥፋ';

  @override
  String get unmute => 'ድምፅ አብራ';

  @override
  String get camera => 'ካሜራ';

  @override
  String get camOff => 'ካሜራ አጥፋ';

  @override
  String get flip => 'አዙር';

  @override
  String get speaker => 'ስፒከር';

  @override
  String get insufficientData => 'ለትንተና በቂ መረጃ የለም።';

  @override
  String get micPermissionRequired => 'የድምጽ መልዕክቶችን ለመቅዳት የማይክሮፎን ፈቃድ ያስፈልጋል።';

  @override
  String failedToPickImage(String error) {
    return 'ምስል መምረጥ አልተቻለም: $error';
  }

  @override
  String failedToPickVideo(String error) {
    return 'ቪዲዮ መምረጥ አልተቻለም: $error';
  }

  @override
  String get playVideo => 'ቪዲዮውን አጫውት';

  @override
  String get shareMedia => 'ሚዲያ አጋራ';

  @override
  String get gallery => 'ጋለሪ';

  @override
  String get cameraLabel => 'ካሜራ';

  @override
  String get videoLabel => 'ቪዲዮ';

  @override
  String get preparingMedia => 'ሚዲያ በማዘጋጀት ላይ...';

  @override
  String get tapToDownload => 'ለማውረድ ይንኩ';

  @override
  String get voiceLabel => 'ድምጽ';

  @override
  String get contactLabel => 'እውቂያ';

  @override
  String get emptyMessage => '(ባዶ መልዕክት)';

  @override
  String get attachmentLabel => 'አባሪ';

  @override
  String get mindfulFocusTip => 'ጭንቅላትዎን ሳያንቀሳቅሱ ነጥቡን ይከተሉ።';

  @override
  String get supportGroup => 'የድጋፍ ቡድን';

  @override
  String get educationalLabel => 'ትምህርታዊ';

  @override
  String get supportLabel => 'ድጋፍ';

  @override
  String get discussionLabel => 'ውይይት';

  @override
  String get resourcesLabel => 'ምንጮች';

  @override
  String get activeLabel => 'ንቁ';

  @override
  String get postLabel => 'ፖስት';

  @override
  String get safeSpaceCounselor => 'ለአማካሪ መመሪያ እና ወቅታዊ መረጃዎች ደህንነቱ የተጠበቀ ቦታ።';
}
