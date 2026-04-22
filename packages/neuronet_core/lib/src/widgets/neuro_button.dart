import 'package:flutter/material.dart';
import 'neuro_shimmer.dart';
import '../theme/app_theme.dart';

/// A premium, standardized button for the NEURONET ecosystem.
/// 
/// Includes a polished 'glint' shimmer effect for primary actions and
/// a built-in loading state.
/// 
/// Optimized with gradient support and robust centering to prevent text clipping.
class NeuroButton extends StatelessWidget {
  const NeuroButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.isLoading = false,
    this.isPrimary = true,
    this.showShimmer = true,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.padding,
    this.borderRadius,
    this.width,
    this.height = 56,
  });

  /// Callback when the button is pressed.
  final VoidCallback? onPressed;

  /// The text label to display on the button.
  final String label;

  /// Whether the button is in a loading state.
  final bool isLoading;

  /// Whether this is a primary action button (enables shimmer by default).
  final bool isPrimary;

  /// Whether to show the subtle glint shimmer effect.
  final bool showShimmer;

  /// Optional icon to display before the label.
  final IconData? icon;

  /// Optional background color override.
  final Color? backgroundColor;

  /// Optional foreground (text/icon) color override.
  final Color? foregroundColor;

  /// Optional gradient override.
  final Gradient? gradient;

  /// Optional padding override.
  final EdgeInsetsGeometry? padding;

  /// Optional border radius override (defaults to 16 for Bento style).
  final double? borderRadius;

  /// Optional fixed width.
  final double? width;

  /// Fixed height (defaults to 56).
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onPressed != null && !isLoading;

    final baseColor = backgroundColor ?? (isPrimary ? theme.colorScheme.primary : Colors.transparent);
    final fg = foregroundColor ?? (isPrimary ? Colors.white : theme.colorScheme.primary);
    final radius = borderRadius ?? 16;
    
    // Select the appropriate brand gradient based on the primary color
    final effectiveGradient = gradient ?? (isPrimary && isEnabled ? (
      baseColor.toARGB32() == NeuroColors.guardianPrimary.toARGB32() 
        ? NeuroGradients.guardian 
        : (baseColor.toARGB32() == NeuroColors.adolescentPrimary.toARGB32() 
            ? NeuroGradients.adolescent 
            : LinearGradient(
                colors: [baseColor, baseColor.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))
    ) : null);

    Widget buttonContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null && !isLoading) ...[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: fg,
              height: 1.1, // Improved line height control
            ),
          ),
        ),
      ],
    );

    if (isLoading) {
      buttonContent = SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(fg),
        ),
      );
    }

    // Using Container + InkWell for maximum control over gradients and alignment
    Widget button = Opacity(
      opacity: isEnabled ? 1.0 : 0.6,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: effectiveGradient == null ? baseColor : null,
          gradient: effectiveGradient,
          borderRadius: BorderRadius.circular(radius),
          border: !isPrimary ? Border.all(color: baseColor, width: 2) : null,
          boxShadow: isPrimary && isEnabled ? [
            BoxShadow(
              color: baseColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: padding ?? const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: buttonContent,
              ),
            ),
          ),
        ),
      ),
    );

    // Apply shimmer if requested and not loading
    if (showShimmer && isPrimary && isEnabled) {
      button = NeuroShimmer.glint(
        opacity: 0.18, // Slightly higher for visibility on gradients
        child: button,
      );
    }

    return button;
  }
}
