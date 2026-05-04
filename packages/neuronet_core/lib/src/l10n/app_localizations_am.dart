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
  String get namingFeelings => 'የሚሰማዎትን ስም መስጠት የግማሽ ስራ ነው።\nቀሪውን እኛ እንረዳለን።';

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
  String get boostYourMood => 'በአዝናኝ እና በሳይንስ በተደገፉ እንቅስቃሴዎች ስሜትዎን ያሳድጉ።';

  @override
  String get playNow => 'አሁን ይጫወቱ';

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
  String get translate => 'ተርጉም';

  @override
  String get showOriginal => 'ዋናውን አሳይ';

  @override
  String get translating => 'በመተርጎም ላይ...';

  @override
  String get translationError => 'መተርጎም አልተቻለም';
}
