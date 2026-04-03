import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert.freezed.dart';
part 'alert.g.dart';

Object? _readAlertId(Map json, String key) => json['_id'] ?? json['alert_id'] ?? json['id'];

/// Matches the AlertBrief schema returned by /alerts/guardian/me.
@freezed
abstract class Alert with _$Alert {
  const factory Alert({
    @JsonKey(name: 'alertId', readValue: _readAlertId) required String alertId,
    @JsonKey(name: 'adolescent_id') required String adolescentId,
    @JsonKey(name: 'adolescent_name') required String adolescentName,
    @JsonKey(name: 'severity_level') required String severityLevel,
    @JsonKey(name: 'alert_type') required String alertType,
    @JsonKey(name: 'trigger_description') required String triggerDescription,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'viewed_status') required bool viewedStatus,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
}
