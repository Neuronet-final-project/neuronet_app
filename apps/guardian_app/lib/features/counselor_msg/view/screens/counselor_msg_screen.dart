import 'package:flutter/material.dart';

class CounselorMsgScreen extends StatelessWidget {
  const CounselorMsgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counselor Messages')),
      body: const Center(child: Text('Guardian ↔ Counselor Communication')),
    );
  }
}
