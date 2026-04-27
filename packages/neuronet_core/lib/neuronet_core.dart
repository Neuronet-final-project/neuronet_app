/// NEURONET Core — Shared models, services, theme, and widgets.
library;

// Models
export 'src/models/models.dart';

// Network
export 'src/network/network.dart';

// Errors
export 'src/errors/failures.dart';

// Services
export 'src/services/auth_service.dart';
export 'src/services/ai_chat_service.dart';
export 'src/services/dashboard_service.dart';
export 'src/services/journal_service.dart';
export 'src/services/notification_service.dart';
export 'src/services/alert_service.dart';
export 'src/services/educational_service.dart';
export 'src/services/consent_service.dart';
export 'src/services/channel_service.dart';
export 'src/services/messaging_service.dart';
export 'src/services/onboarding_service.dart';
export 'src/services/voice_recorder_service.dart';
export 'src/services/call_service.dart';
export 'src/services/call_controller.dart';

// Network
export 'src/network/api_endpoints.dart';

// Theme
export 'src/theme/app_theme.dart';

// Design tokens
export 'src/theme/app_theme.dart' show NeuroSpacing, NeuroRadius, NeuroShadows, NeuroGradients;

// Widgets
export 'src/widgets/neuro_error_widget.dart';
export 'src/widgets/neuro_card.dart';
export 'src/widgets/neuro_mood_icon.dart';
export 'src/widgets/neuro_journal_card.dart';
export 'src/widgets/neuro_alert_card.dart';
export 'src/widgets/neuro_summary_card.dart';
export 'src/widgets/neuro_trend_chart.dart';
export 'src/widgets/neuro_empty_state.dart';
export 'src/widgets/neuro_onboarding.dart';
export 'src/widgets/neuro_chat_bubble.dart';
export 'src/widgets/neuro_chat_input.dart';
export 'src/widgets/neuro_shimmer.dart';
export 'src/widgets/neuro_incoming_call.dart';
export 'src/widgets/neuro_active_call.dart';
export 'src/widgets/neuro_button.dart';
export 'src/widgets/neuro_toast.dart';

// Constants
export 'src/constants/app_constants.dart';
