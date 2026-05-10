import 'package:flutter/material.dart';
import 'dart:math' as math;

class FocusGameScreen extends StatefulWidget {
  const FocusGameScreen({super.key});

  @override
  State<FocusGameScreen> createState() => _FocusGameScreenState();
}

class _FocusGameScreenState extends State<FocusGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mindful Focus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Follow the light with your eyes.',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 60),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Orbit
                    Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05), width: 1),
                      ),
                    ),
                    // Moving Point
                    Transform.translate(
                      offset: Offset(
                        100 * math.cos(_animation.value),
                        100 * math.sin(_animation.value),
                      ),
                      child: Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFFA726),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFA726).withValues(alpha: 0.6),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Center point
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 100),
            const Text(
              'Keep your head still and follow the dot.',
              style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
