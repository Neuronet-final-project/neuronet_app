import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class AIQuestScreen extends StatefulWidget {
  const AIQuestScreen({super.key});

  @override
  State<AIQuestScreen> createState() => _AIQuestScreenState();
}

class _AIQuestScreenState extends State<AIQuestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  
  final List<String> _quests = [
    "If your current mood was a weather pattern, what would it look like right now?",
    "Identify one thing you can control in your life today, and one thing you can let go.",
    "Imagine a future version of yourself who is completely at peace. What's the one piece of advice they'd give you?",
    "What's a small act of kindness you've witnessed or done recently that stayed with you?",
  ];
  
  late String _currentQuest;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    _currentQuest = _quests[math.Random().nextInt(_quests.length)];
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
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
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Deep space blue
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI REFLECTIVE QUEST', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _revealed = true),
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _revealed ? 1.0 : _pulse.value,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const SweepGradient(
                          colors: [Color(0xFF6A1FDB), Color(0xFF7C4DFF), Color(0xFF64B5F6), Color(0xFF6A1FDB)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C4DFF).withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _revealed 
                          ? const Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 80)
                          : const Text('?', style: TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 60),
            AnimatedOpacity(
              opacity: _revealed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: Column(
                children: [
                  Text(
                    _currentQuest,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30), side: const BorderSide(color: Colors.white24)),
                    ),
                    child: const Text('I\'ve reflected on this', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            if (!_revealed)
               const Text(
                'Tap the orb to start your quest',
                style: TextStyle(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic),
              ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
