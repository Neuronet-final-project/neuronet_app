import 'package:flutter/material.dart';
import 'dart:async';

class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  String _phase = "Prepare";
  int _seconds = 0;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
      _phase = "Inhale";
    });
    _runCycle();
  }

  Future<void> _runCycle() async {
    while (_isActive) {
      // Inhale
      setState(() => _phase = "Inhale");
      _controller.forward();
      await Future.delayed(const Duration(seconds: 4));
      if (!_isActive) break;

      // Hold
      setState(() => _phase = "Hold");
      await Future.delayed(const Duration(seconds: 4));
      if (!_isActive) break;

      // Exhale
      setState(() => _phase = "Exhale");
      _controller.reverse();
      await Future.delayed(const Duration(seconds: 4));
      if (!_isActive) break;
    }
  }

  @override
  void dispose() {
    _isActive = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Deep dark theme for focus
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
              'Box Breathing',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Calm your mind & find your focus.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 80),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer soft glow
                    Container(
                      width: 140 * _scaleAnimation.value,
                      height: 140 * _scaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7C4DFF).withOpacity(0.1),
                      ),
                    ),
                    // Inner pulse
                    Container(
                      width: 100 * _scaleAnimation.value,
                      height: 100 * _scaleAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFFB47CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withOpacity(0.4),
                            blurRadius: 20 * _scaleAnimation.value,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isActive ? _phase : "Ready?",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 100),
            if (!_isActive)
              ElevatedButton(
                onPressed: _startExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Start Exercise',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              )
            else
              const Text(
                'Focus on your breath...',
                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
