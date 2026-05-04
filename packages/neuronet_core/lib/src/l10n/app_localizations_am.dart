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
  String get writingSparksTag => 'WRITING SPARKS';

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
}
