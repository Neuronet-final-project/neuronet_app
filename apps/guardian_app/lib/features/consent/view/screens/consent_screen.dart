import 'package:flutter/material.dart';

class ConsentScreen extends StatelessWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consent Management')),
      body: const Center(child: Text('Manage Consent Settings')),
    );
  }
}
