import 'package:flutter/material.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Journal')),
      body: const Center(child: Text('Journal Entries')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to new journal entry
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
