import 'package:flutter/material.dart';

class MoodScreen extends StatelessWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mood Tracker')),
      body: const Center(child: Text('Record Your Mood')),
    );
  }
}
