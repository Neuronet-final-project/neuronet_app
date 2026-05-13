/// API endpoint constants for the NEURONET backend.
class ApiEndpoints {
  const ApiEndpoints._();

  static String _baseUrl = 'https://final-year-project-backend-production-da67.up.railway.app';

  /// Current base URL. Set via [init] at startup.
  static String get baseUrl => _baseUrl;

  /// Call once at startup after loading environment config.
  static void init({required String baseUrl}) {
    _baseUrl = baseUrl;
  }

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String activateAccount = '/auth/activate-account';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/me'; // PUT method
  static const String createAdolescent = '/auth/guardian/create-adolescent';
  static const String pendingAdolescents = '/auth/guardian/pending-adolescents';
  static const String deviceToken = '/auth/device-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';

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
  static String alertSummary(String id) => '/alerts/adolescent/$id/summary';
  static String resolveAlert(String id) => '/alerts/resolve/$id';
  static String markViewed(String id) => '/alerts/mark-viewed/single/$id';
  static String markAlertsViewed(String adolescentId) => '/alerts/mark-viewed/$adolescentId';

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
  static String sendConversationMessage(String id) => '/messaging/conversations/$id/messages'; // POST
  static String markConversationAsRead(String id) => '/messaging/conversations/$id/mark-read'; // POST
  static String conversationUnreadCount(String id) => '/messaging/conversations/$id/unread-count';
  static const String totalUnreadCount = '/messaging/unread-count/total';
  static const String uploadMedia = '/messaging/upload';

  // Voice/Video Calls
  static const String initiateCall = '/messaging/calls/initiate';
  static const String incomingCalls = '/messaging/calls/incoming';
  static String callDetails(String callId) => '/messaging/calls/$callId';
  static String callSignal(String callId) => '/messaging/calls/$callId/signal';
  static String callAnswer(String callId) => '/messaging/calls/$callId/answer';
  static String callEnd(String callId) => '/messaging/calls/$callId/end';
  static String callActive(String callId) => '/messaging/calls/$callId/active';

  // AI Analysis
  static const String analyzeText = '/ai/analyze-text';
  static String evaluateRisk(String adolescentId) => '/ai/evaluate-risk/$adolescentId';

  // Channels
  static const String myChannels = '/channels/me';
  static const String channels = '/channels';
  static String channelSubscribe(String id) => '/channels/$id/subscribe';
  // Channel Posts & Interactions
  static String channelPosts(String id) => '/channels/$id/posts';
  static String channelPost(String channelId, String postId) => '/channels/$channelId/posts/$postId';
  static String channelInteractions(String channelId, String postId) => '/channels/$channelId/posts/$postId/interactions';
  static String channelInteract(String channelId, String postId) => '/channels/$channelId/posts/$postId/interact';
  static String channelModerate(String channelId, String postId, String interactionId) =>
      '/channels/$channelId/posts/$postId/interactions/$interactionId/moderate';


  // Educational Pages
  static const String educationalPages = '/educational-pages';
  static const String discoverEducationalPagesNew = '/educational-pages/discover';
  static String educationalPageBySlug(String slug) => '/educational-pages/$slug';
  static String educationalRecommendations(String id) => '/educational/recommendations/adolescent/$id';
  static String guardianEducationalRecommendations(String id) => '/educational/recommendations/guardian/$id';

  // Educational Page Following (FR-14 & FR-15)
  static String followEducationalPage(String slug) => '/educational-follows/follow/$slug';
  static String unfollowEducationalPage(String slug) => '/educational-follows/unfollow/$slug';
  static const String myFollowedPages = '/educational-follows/my-followed-pages';
  static const String guardianFollowView = '/educational-follows/guardian-view';
  static const String discoverEducationalPages = '/educational-follows/discover';
  static String pageFollowCount(String slug) => '/educational-follows/page/$slug/follow-count';
  static String isPageFollowed(String slug) => '/educational-follows/page/$slug/is-followed';

  // Category Following
  static String followCategory(String category) => '/category-follows/follow/$category';
  static String unfollowCategory(String category) => '/category-follows/unfollow/$category';
  static const String myFollowedCategories = '/category-follows/my-followed-categories';
  static const String myFeed = '/category-follows/my-feed';
  static String isCategoryFollowed(String category) => '/category-follows/is-followed/$category';
  static const String availableCategories = '/category-follows/available-categories';

  // AI Recommendations (FR-31)
  static const String analyzeAndRecommend = '/ai-recommendations/analyze-and-recommend';
  static const String myAIRecommendations = '/ai-recommendations/my-recommendations';
  static String markRecommendationViewed(String id) => '/ai-recommendations/mark-viewed/$id';

  // Guardian Approvals (FR-34)
  static const String requestCommunicationApproval = '/guardian-approvals/request-communication';
  static String respondToApproval(String id) => '/guardian-approvals/respond/$id';
  static String revokeApproval(String id) => '/guardian-approvals/revoke/$id';
  static const String pendingApprovals = '/guardian-approvals/pending';
  static const String approvalHistory = '/guardian-approvals/history';
  static String checkApprovalStatus(String adolescentId, String counselorEmail) => 
      '/guardian-approvals/check-approval/$adolescentId/$counselorEmail';

  // Guardian overview
  static const String guardianAdolescents = '/guardians/me/adolescents';

  // Counselor Assignments
  static String adolescentCounselors(String adolescentId) => '/counselor-assignments/adolescent/$adolescentId/counselors';

  // Translation
  static const String translate = '/api/translation/translate';
}
