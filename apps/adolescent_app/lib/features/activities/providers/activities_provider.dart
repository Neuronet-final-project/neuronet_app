import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity.dart';
import 'package:flutter/material.dart';

final activitiesProvider = Provider<List<Activity>>((ref) {
  // Mocking the response for now to ensure an interactive UI
  return [
    Activity(
      id: '1',
      title: 'Deep Breathing',
      description: 'A simple 4-4-4 rhythm to calm your mind and regulate your system.',
      type: ActivityType.breathing,
      durationMinutes: 3,
      color: const Color(0xFF7C4DFF),
      icon: Icons.air_rounded,
    ),
    Activity(
      id: '2',
      title: 'Mindful Focus',
      description: 'Train your attention by following the rhythmic movement of light.',
      type: ActivityType.focus,
      durationMinutes: 5,
      color: const Color(0xFFFFA726),
      icon: Icons.center_focus_strong_rounded,
    ),
    Activity(
      id: '3',
      title: 'Daily Gratitude',
      description: 'Reflect on three small wins and things you are thankful for today.',
      type: ActivityType.gratitude,
      durationMinutes: 2,
      color: const Color(0xFF66BB6A),
      icon: Icons.favorite_rounded,
    ),
  ];
});
