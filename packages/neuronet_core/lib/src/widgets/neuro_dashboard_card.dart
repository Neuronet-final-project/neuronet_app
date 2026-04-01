import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neuro_card.dart';

class NeuroDashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double? height;

  const NeuroDashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return NeuroCard(
      height: height,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: NeuroColors.onSurfaceVariant,
              fontWeight: FontWeight.normal,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }
}
