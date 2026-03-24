import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A standard card used for dashboard widgets.
class NeuroDashboardCard extends StatelessWidget {
  const NeuroDashboardCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.height,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: NeuroColors.onSurface,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: NeuroColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
