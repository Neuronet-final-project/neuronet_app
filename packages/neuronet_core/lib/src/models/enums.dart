/// Shared enumerations for the NEURONET system.
/// These match the backend API enum values exactly.
library;

import 'package:json_annotation/json_annotation.dart';

/// User roles in the system.
enum UserRole {
  adolescent,
  guardian,
  counselor,
  administrator;

  String toJson() => name;
  static UserRole fromJson(String json) {
    try {
      return values.byName(json.toLowerCase());
    } catch (_) {
      return UserRole.adolescent;
    }
  }
}

/// Account status.
enum AccountStatus {
  active,
  inactive,
  suspended,
  pendingActivation;

  String toJson() => name;
  static AccountStatus fromJson(String json) => values.byName(json.toLowerCase());
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
  static MoodType fromJson(String json) {
    try {
      return values.byName(json.toLowerCase());
    } catch (_) {
      return MoodType.neutral;
    }
  }

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
  shareAiSummaries,
  shareAlerts,
  participation,
  counselorChat;

  String toJson() => name;
  static ConsentType fromJson(String json) => values.byName(json.toLowerCase());

  /// Human-readable label for UI.
        shareAiSummaries => 'AI Summaries & Risk Levels',
        shareAlerts => 'Security Alerts & Notifications',
        participation => 'General Participation & AI Analysis',
        counselorChat => 'Counselor Private Messaging',
      };

  /// Description for consent management screen.
  String get description => switch (this) {
        shareAiSummaries =>
          'Allow viewing of AI-generated emotional summaries and designated risk levels.',
        shareAlerts =>
          'Receive immediate notifications when critical emotional patterns or risks are detected.',
        participation =>
          'Enable AI-driven emotional analysis and trend detection for all journals.',
        counselorChat =>
          'Authorize private one-on-one communication with assigned counselors.',
      };
}

/// Consent status.
enum ConsentStatus {
  granted,
  revoked,
  expired;

  String toJson() => name;
  static ConsentStatus fromJson(String json) => values.byName(json.toLowerCase());
}

/// Who consent is granted to.
enum GrantedToRole {
  guardian,
  counselor,
  both;

  String toJson() => name;
  static GrantedToRole fromJson(String json) => values.byName(json.toLowerCase());
}

/// Alert severity levels.
enum AlertSeverity {
  low,
  medium,
  high;

  String toJson() => name;
  static AlertSeverity fromJson(String json) {
    try {
      return values.byName(json.toLowerCase());
    } catch (_) {
      return AlertSeverity.low;
    }
  }
}

/// Alert types.
enum AlertType {
  @JsonValue('emotionalPattern')
  emotionalPattern,
  @JsonValue('moodDrop')
  moodDrop,
  @JsonValue('journalFrequency')
  journalFrequency,
  @JsonValue('contentFlag')
  contentFlag,
  @JsonValue('high_risk_sentiment')
  highRiskSentiment,
  @JsonValue('emotional_insight')
  emotionalInsight;

  String toJson() => name;
  static AlertType fromJson(String json) {
    try {
      return values.byName(json);
    } catch (_) {
      return AlertType.emotionalInsight;
    }
  }
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
  static MessageType fromJson(String json) => values.byName(json.toLowerCase());
}

/// Channel types.
enum ChannelType {
  educational,
  supportive,
  discussion,
  resourceLibrary;

  String toJson() => name;
  static ChannelType fromJson(String json) => values.byName(json.toLowerCase());
}

/// Channel interaction types.
enum InteractionType {
  reaction,
  comment;

  String toJson() => name;
  static InteractionType fromJson(String json) => values.byName(json.toLowerCase());
}

/// Guardian relationship type to adolescent.
enum RelationshipType {
  parent,
  legalGuardian,
  other;

  String toJson() => name;
  static RelationshipType fromJson(String json) => values.byName(json.toLowerCase());
}
