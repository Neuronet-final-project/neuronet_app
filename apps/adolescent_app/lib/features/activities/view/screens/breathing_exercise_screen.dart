import 'package:flutter/material.dart';
import 'package:neuronet_core/neuronet_core.dart';
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

  void _startExercise(AppLocalizations l10n) {
    setState(() {
      _isActive = true;
      _phase = l10n.phaseInhale;
    });
    _runCycle(l10n);
  }

  Future<void> _runCycle(AppLocalizations l10n) async {
    while (_isActive) {
      // Inhale
      if (!mounted) break;
      setState(() => _phase = l10n.phaseInhale);
      _controller.forward();
      await Future.delayed(const Duration(seconds: 4));
      if (!_isActive || !mounted) break;

      // Hold
      setState(() => _phase = l10n.phaseHold);
      await Future.delayed(const Duration(seconds: 4));
      if (!_isActive || !mounted) break;

      // Exhale
      setState(() => _phase = l10n.phaseExhale);
      _controller.reverse();
      await Future.delayed(const Duration(seconds: 4));
      if (!_isActive || !mounted) break;
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
    final l10n = context.localizations;
    
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
            Text(
              l10n.boxBreathingTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.boxBreathingDesc,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
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
                        color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
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
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                            blurRadius: 20 * _scaleAnimation.value,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _isActive ? _phase : l10n.phaseReady,
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
                onPressed: () => _startExercise(l10n),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(l10n.startExercise,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              )
            else
              Text(
                l10n.focusOnBreath,
                style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
