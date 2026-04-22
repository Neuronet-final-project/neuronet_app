import 'package:flutter/material.dart';

enum ActivityType {
  breathing,
  focus,
  gratitude;

  factory ActivityType.fromString(String value) {
    return ActivityType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ActivityType.breathing,
    );
  }
}

class Activity {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final int durationMinutes;
  final Color color;
  final IconData icon;

  Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.durationMinutes,
    required this.color,
    required this.icon,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ActivityType.fromString(json['type'] ?? 'breathing'),
      durationMinutes: json['duration_minutes'] ?? 0,
      color: Color(int.parse(json['color_hex'].replaceFirst('#', '0xFF'))),
      icon: _getIconFromName(json['icon_name'] ?? ''),
    );
  }

  static IconData _getIconFromName(String name) {
    switch (name) {
      case 'air_rounded':
        return Icons.air_rounded;
      case 'center_focus_strong_rounded':
        return Icons.center_focus_strong_rounded;
      case 'favorite_rounded':
        return Icons.favorite_rounded;
      default:
        return Icons.extension_rounded;
    }
  }
}
