import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

@freezed
abstract class Alert with _$Alert {
  const factory Alert({
    required String alertId,
    required String adolescentId,
    required AlertType alertType,
    required AlertSeverity severityLevel,
    required String triggerDescription,
    required DateTime createdAt,
    required bool viewedStatus,
    required AlertActionStatus actionStatus,
    String? actionTakenBy,
    DateTime? actionDate,
    String? actionNotes,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
}
