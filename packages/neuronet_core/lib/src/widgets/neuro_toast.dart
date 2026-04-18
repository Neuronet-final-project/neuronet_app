import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NeuroToastType { success, error, info, warning }

class NeuroToast {
  const NeuroToast._();

  static void show(
    BuildContext context,
    String message, {
    NeuroToastType type = NeuroToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NeuroRadius.md),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  static Color _getColor(NeuroToastType type) {
    switch (type) {
      case NeuroToastType.success:
        return NeuroColors.alertLow;
      case NeuroToastType.error:
        return NeuroColors.error;
      case NeuroToastType.warning:
        return NeuroColors.alertMedium;
      case NeuroToastType.info:
        return NeuroColors.adolescentPrimary;
    }
  }

  static IconData _getIcon(NeuroToastType type) {
    switch (type) {
      case NeuroToastType.success:
        return Icons.check_circle_outline_rounded;
      case NeuroToastType.error:
        return Icons.error_outline_rounded;
      case NeuroToastType.warning:
        return Icons.warning_amber_rounded;
      case NeuroToastType.info:
        return Icons.info_outline_rounded;
    }
  }
}
