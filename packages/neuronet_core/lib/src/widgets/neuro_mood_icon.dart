import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../theme/app_theme.dart';

class NeuroMoodIcon extends StatelessWidget {
  const NeuroMoodIcon({
    super.key,
    required this.moodType,
    this.isSelected = false,
    this.size = 40,
    this.onTap,
  });

  final MoodType moodType;
  final bool isSelected;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : NeuroColors.outline.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              moodType.emoji,
              style: TextStyle(fontSize: size),
            ),
            const SizedBox(height: 8),
            Text(
              moodType.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).colorScheme.onPrimary : NeuroColors.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
