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
      title: 'Mood Matcher',
      description: 'A fun pattern-matching game to sharpen your focus.',
      type: ActivityType.moodMatch,
      durationMinutes: 3,
      color: const Color(0xFFFF7043),
      icon: Icons.games_rounded,
    ),
    Activity(
      id: '4',
      title: 'AI Reflective Quest',
      description: 'Embark on a personal journey of self-discovery powered by AI.',
      type: ActivityType.aiQuest, 
      durationMinutes: 4,
      color: const Color(0xFF6A1FDB),
      icon: Icons.auto_awesome_rounded,
    ),
  ];
});
