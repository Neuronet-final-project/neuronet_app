import 'package:flutter/material.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'dart:math' as math;

class AIQuestScreen extends StatefulWidget {
  const AIQuestScreen({super.key});

  @override
  State<AIQuestScreen> createState() => _AIQuestScreenState();
}

class _AIQuestScreenState extends State<AIQuestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;
  
  late String _currentQuest;
  bool _revealed = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _initializeQuest(AppLocalizations l10n) {
    if (_isInitialized) return;
    final List<String> quests = [
      l10n.quest1,
      l10n.quest2,
      l10n.quest3,
      l10n.quest4,
    ];
    _currentQuest = quests[math.Random().nextInt(quests.length)];
    _isInitialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    _initializeQuest(l10n);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Deep space blue
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.aiReflectiveQuest, 
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
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
                            color: const Color(0xFF7C4DFF).withValues(alpha: 0.5),
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
                    child: Text(l10n.reflectedOnThis, style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            if (!_revealed)
               Text(
                l10n.tapOrbToStart,
                style: const TextStyle(color: Colors.white38, fontSize: 14, fontStyle: FontStyle.italic),
              ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
