/// API endpoint constants for the NEURONET backend.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://final-year-project-backend-production-da67.up.railway.app';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String activateAccount = '/auth/activate-account';
  static const String me = '/auth/me';
  static const String createAdolescent = '/auth/guardian/create-adolescent';
  static const String pendingAdolescents = '/auth/guardian/pending-adolescents';

  // Dashboard
  static const String guardianDashboard = '/dashboard/guardian';
  static const String adolescentDashboard = '/dashboard/adolescent/me';

  // Journals
  static const String journals = '/journals/';
  static String journalsByAdolescent(String id) => '/journals/adolescent/$id';
  static String journalById(String id) => '/journals/$id';

  // Moods
  static const String moods = '/moods/';
  static const String myMoods = '/moods/me';

  // Alerts
  static const String guardianAlerts = '/alerts/guardian/me';
  static const String counselorAlerts = '/alerts/counselor/me';
  static String alertsByAdolescent(String id) => '/alerts/adolescent/$id';
  static String resolveAlert(String id) => '/alerts/resolve/$id';
  static String markViewed(String id) => '/alerts/mark-viewed/$id';

  // Consents
  static String consentByEmail(String email) => '/consents/$email';
  static const String myConsent = '/consents/me';

  // AI Chat
  static const String aiChatSessions = '/ai-chat/sessions';
  static const String myAiSessions = '/ai-chat/sessions/me';
  static String aiChatMessages(String id) => '/ai-chat/sessions/$id/messages';

  // Messaging
  static const String conversations = '/messaging/conversations';
  static String conversationMessages(String id) => '/messaging/conversations/$id/messages';

  // Channels
  static const String myChannels = '/channels/me';
  static String channelSubscribe(String id) => '/channels/$id/subscribe';

  // Educational Pages
  static const String educationalPages = '/educational-pages/';
  static String educationalPageBySlug(String slug) => '/educational-pages/$slug';
  static String educationalRecommendations(String id) => '/educational/recommendations/adolescent/$id';

  // Guardian overview
  static const String guardianAdolescents = '/guardians/me/adolescents';
}
