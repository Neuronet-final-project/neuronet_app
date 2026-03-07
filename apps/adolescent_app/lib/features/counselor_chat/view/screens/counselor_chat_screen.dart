import 'package:flutter/material.dart';

class CounselorChatScreen extends StatelessWidget {
  const CounselorChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counselor Chat')),
      body: const Center(child: Text('Chat with Counselor')),
    );
  }
}
