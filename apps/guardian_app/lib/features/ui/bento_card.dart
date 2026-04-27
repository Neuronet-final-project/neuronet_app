import 'package:flutter/material.dart';

class GuardianBentoCard extends StatefulWidget {
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
  State<GuardianBentoCard> createState() => _GuardianBentoCardState();
}

class _GuardianBentoCardState extends State<GuardianBentoCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutBack,
      child: Container(
        margin: widget.margin,
        child: GestureDetector(
          onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: widget.onTap != null ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: widget.onTap != null ? () => setState(() => _isPressed = false) : null,
          onTap: widget.onTap,
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: widget.gradient == null ? widget.backgroundColor : null,
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: widget.gradient == null 
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
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
