import 'package:flutter/material.dart';
import 'package:neuronet_core/neuronet_core.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuroColors.guardianSurface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.health_and_safety_rounded,
              size: 80,
              color: NeuroColors.guardianPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'NEURONET',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: NeuroColors.guardianPrimary,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'G U A R D I A N',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: NeuroColors.guardianPrimary,
                    letterSpacing: 4,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(NeuroColors.guardianPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
