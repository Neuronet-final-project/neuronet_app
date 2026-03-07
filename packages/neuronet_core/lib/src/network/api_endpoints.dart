/// API endpoint constants for the NEURONET backend.
class ApiEndpoints {
  const ApiEndpoints._();

  static const String baseUrl = 'https://api.neuronet.com';

  // Auth
  static const String login = '/api/v1/auth/login';
  static const String activate = '/api/v1/auth/activate';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';

  // Profile
  static const String profile = '/api/v1/users/me';

  // Journals
  static const String journals = '/api/v1/journals';
  static String journalById(String id) => '/api/v1/journals/$id';

  // Moods
  static const String moods = '/api/v1/moods';

  // AI Chat
  static const String aiChat = '/api/v1/chat/ai';

  // Dashboard
  static const String dashboardTrends = '/api/v1/dashboard/trends';

  // Consent
  static const String consents = '/api/v1/consents';
  static String consentById(String id) => '/api/v1/consent/$id';

  // Adolescent Registration (Guardian)
  static const String registerAdolescent =
      '/api/v1/guardians/register-adolescent';

  // Alerts
  static const String alerts = '/api/v1/alerts';

  // Chat (Counselor/Guardian)
  static const String chatRequest = '/api/v1/chat/request';
  static const String chatMessages = '/api/v1/chat/messages';

  // Channels
  static const String channels = '/api/v1/channels';
  static String channelJoin(String id) => '/api/v1/channels/$id/join';
  static String channelInteract(String channelId, String postId) =>
      '/api/v1/channels/$channelId/posts/$postId/interact';

  // Guardian specific
  static const String followedPages = '/api/v1/guardians/followed-pages';
}
