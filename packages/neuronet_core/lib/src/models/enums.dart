/// Shared enumerations for the NEURONET system.
/// These match the backend API enum values exactly.
library;

/// User roles in the system.
enum UserRole {
  adolescent,
  guardian,
  counselor,
  administrator;

  String toJson() => name;
  static UserRole fromJson(String json) => values.byName(json);
}

/// Account status.
enum AccountStatus {
  active,
  inactive,
  suspended,
  pendingActivation;

  String toJson() => name;
  static AccountStatus fromJson(String json) => values.byName(json);
}

/// Mood types for mood recording.
enum MoodType {
  happy,
  sad,
  anxious,
  calm,
  stressed,
  neutral,
  excited,
  tired,
  angry,
  hopeful;

  String toJson() => name;
  static MoodType fromJson(String json) => values.byName(json);

  /// Emoji representation for UI.
  String get emoji => switch (this) {
        happy => '😊',
        sad => '😢',
        anxious => '😰',
        calm => '😌',
        stressed => '😤',
        neutral => '😐',
        excited => '🤩',
        tired => '😴',
        angry => '😡',
        hopeful => '🌟',
      };

  /// Display label for UI.
  String get label => switch (this) {
        happy => 'Happy',
        sad => 'Sad',
        anxious => 'Anxious',
        calm => 'Calm',
        stressed => 'Stressed',
        neutral => 'Neutral',
        excited => 'Excited',
        tired => 'Tired',
        angry => 'Angry',
        hopeful => 'Hopeful',
      };
}

/// Consent types that guardians can manage.
enum ConsentType {
  journalAnalysis,
  counselorCommunication,
  dataSharing,
  alertNotification,
  channelParticipation;

  String toJson() => name;
  static ConsentType fromJson(String json) => values.byName(json);

  /// Human-readable label for UI.
  String get label => switch (this) {
        journalAnalysis => 'Journal Analysis',
        counselorCommunication => 'Counselor Communication',
        dataSharing => 'Data Sharing',
        alertNotification => 'Alert Notifications',
        channelParticipation => 'Channel Participation',
      };

  /// Description for consent management screen.
  String get description => switch (this) {
        journalAnalysis =>
          'Allow AI to analyze journal entries for emotional trends',
        counselorCommunication =>
          'Allow direct messaging between adolescent and counselor',
        dataSharing =>
          'Share summarized emotional trends with assigned counselor',
        alertNotification =>
          'Send alert notifications when emotional patterns are detected',
        channelParticipation =>
          'Allow participation in counselor-created channels',
      };
}

/// Consent status.
enum ConsentStatus {
  granted,
  revoked,
  expired;

  String toJson() => name;
  static ConsentStatus fromJson(String json) => values.byName(json);
}

/// Who consent is granted to.
enum GrantedToRole {
  guardian,
  counselor,
  both;

  String toJson() => name;
  static GrantedToRole fromJson(String json) => values.byName(json);
}

/// Alert severity levels.
enum AlertSeverity {
  low,
  medium,
  high;

  String toJson() => name;
  static AlertSeverity fromJson(String json) => values.byName(json);
}

/// Alert types.
enum AlertType {
  emotionalPattern,
  moodDrop,
  journalFrequency,
  contentFlag;

  String toJson() => name;
  static AlertType fromJson(String json) => values.byName(json);
}

/// Alert action status.
enum AlertActionStatus {
  pending,
  reviewed,
  inProgress,
  resolved,
  escalated;

  String toJson() => name;
  static AlertActionStatus fromJson(String json) => values.byName(json);
}

/// Chat message types.
enum MessageType {
  aiChat,
  counselorChat,
  guardianChat;

  String toJson() => name;
  static MessageType fromJson(String json) => values.byName(json);
}

/// Channel types.
enum ChannelType {
  educational,
  supportive,
  discussion,
  resourceLibrary;

  String toJson() => name;
  static ChannelType fromJson(String json) => values.byName(json);
}

/// Channel interaction types.
enum InteractionType {
  reaction,
  comment;

  String toJson() => name;
  static InteractionType fromJson(String json) => values.byName(json);
}

/// Guardian relationship type to adolescent.
enum RelationshipType {
  parent,
  legalGuardian,
  other;

  String toJson() => name;
  static RelationshipType fromJson(String json) => values.byName(json);
}
