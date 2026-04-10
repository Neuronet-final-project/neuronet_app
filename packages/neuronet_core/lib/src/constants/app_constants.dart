/// Shared application constants used across both adolescent and guardian apps.
class AppConstants {
  AppConstants._();

  /// Current app version. Updated via CI/CD or manually before releases.
  static const String appVersion = '1.0.0';

  /// Default display name when user profile has no name.
  static const String anonymousUserName = 'Member';

  /// Fallback user ID used when auth profile is unavailable.
  static const String fallbackUserId = 'fallback';

  /// Sender ID for AI assistant messages.
  static const String aiAssistantId = 'ai-assistant';

  /// Role string for guardian users (used in chat message construction).
  static const String guardianRole = 'guardian';

  /// Role string for adolescent users.
  static const String adolescentRole = 'adolescent';
}
