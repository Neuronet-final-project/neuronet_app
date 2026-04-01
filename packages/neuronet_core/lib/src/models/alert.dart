import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

/// Matches the AlertBrief schema returned by /alerts/guardian/me.
@freezed
abstract class Alert with _$Alert {
  const factory Alert({
    required String alertId,
    required String adolescentId,
    required String adolescentName,
    required String severityLevel,
    required String alertType,
    required String triggerDescription,
    required DateTime createdAt,
    required bool viewedStatus,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
}
