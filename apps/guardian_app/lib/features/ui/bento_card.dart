import 'package:flutter/material.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';

class GuardianBentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double borderRadius;
  final VoidCallback? onTap;

  const GuardianBentoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor = Colors.white,
    this.gradient,
    this.borderRadius = 24.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget currentContent = Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: gradient == null ? backgroundColor : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: gradient == null 
            ? Border.all(color: const Color(0xFFE5E7EB), width: 0.8)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      currentContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: currentContent,
      );
    }

    return Container(
      margin: margin,
      child: currentContent,
    );
  }
}
