import 'package:flutter/material.dart';
import 'package:neuronet_core/neuronet_core.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuroColors.adolescentSurface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.spa_rounded,
              size: 80,
              color: NeuroColors.adolescentPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'NEURONET',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: NeuroColors.adolescentPrimary,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(NeuroColors.adolescentPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
