import 'package:flutter/material.dart';

/// A shimmer effect widget that animates a gradient sweep across its child.
/// Used for skeleton loading states before real data is available.
///
/// Example:
/// ```dart
/// NeuroShimmer(
///   child: Container(
///     height: 20,
///     decoration: BoxDecoration(
///       color: Colors.grey[300],
///       borderRadius: BorderRadius.circular(8),
///     ),
///   ),
/// )
/// ```
class NeuroShimmer extends StatefulWidget {
  const NeuroShimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
  });

  /// The widget to apply the shimmer effect to.
  final Widget child;

  /// Duration of one complete shimmer cycle.
  final Duration duration;

  /// Base color of the shimmer (defaults to grey[200]).
  final Color? baseColor;

  /// Highlight color that sweeps across (defaults to grey[100]).
  final Color? highlightColor;

  @override
  State<NeuroShimmer> createState() => _NeuroShimmerState();
}

class _NeuroShimmerState extends State<NeuroShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.baseColor ?? Colors.grey[200]!;
    final highlight = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.3, 0.5],
              colors: [base, highlight, base],
              transform: _SlidingGradientTransform(slidePercent: _animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// A skeleton loading card that mimics the shape of a list tile or card.
class NeuroSkeletonCard extends StatelessWidget {
  const NeuroSkeletonCard({
    super.key,
    this.height = 72,
    this.borderRadius = 16,
    this.showIcon = true,
  });

  final double height;
  final double borderRadius;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: NeuroShimmer(
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: showIcon
              ? Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 12,
                              width: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 10,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }
}

/// A skeleton circle for avatar/loading placeholders.
class NeuroSkeletonCircle extends StatelessWidget {
  const NeuroSkeletonCircle({
    super.key,
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return NeuroShimmer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
