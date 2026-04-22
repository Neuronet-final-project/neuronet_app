import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoodMatcherScreen extends StatefulWidget {
  const MoodMatcherScreen({super.key});

  @override
  State<MoodMatcherScreen> createState() => _MoodMatcherScreenState();
}

class _MoodMatcherScreenState extends State<MoodMatcherScreen> {
  final List<IconData> _icons = [
    Icons.sentiment_very_satisfied_rounded,
    Icons.sentiment_satisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.sentiment_very_dissatisfied_rounded,
  ];

  late IconData _targetIcon;
  late List<IconData> _gridIcons;
  int _score = 0;
  int _timeLeft = 30;
  bool _isPlaying = false;
  math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _setupLevel();
  }

  void _setupLevel() {
    _targetIcon = _icons[_random.nextInt(_icons.length)];
    _gridIcons = List.generate(12, (_) => _icons[_random.nextInt(_icons.length)]);
    // Ensure at least one target icon exists
    if (!_gridIcons.contains(_targetIcon)) {
      _gridIcons[_random.nextInt(12)] = _targetIcon;
    }
  }

  void _startGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isPlaying = true;
    });
    _tick();
  }

  void _tick() async {
    while (_timeLeft > 0 && _isPlaying) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() {
        _timeLeft--;
      });
    }
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
      _showResult();
    }
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Game Over!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: Text('Your Mood Match score: $_score', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again', style: TextStyle(color: Color(0xFF7C4DFF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  void _handleTap(IconData tappedIcon) {
    if (!_isPlaying) return;
    if (tappedIcon == _targetIcon) {
      setState(() {
        _score += 10;
        _setupLevel();
      });
    } else {
      setState(() {
        _score = math.max(0, _score - 5);
      });
    }
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
        title: Text(
          _isPlaying ? 'Time: $_timeLeft' : 'Mood Matcher',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (!_isPlaying) ...[
              const SizedBox(height: 40),
              const Icon(Icons.games_rounded, size: 80, color: Color(0xFF7C4DFF)),
              const SizedBox(height: 20),
              const Text(
                'How to Play',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tap the mood icon that matches the target as fast as you can!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text('START GAME', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(height: 40),
            ] else ...[
              const SizedBox(height: 20),
              const Text(
                'FIND THIS MOOD:',
                style: TextStyle(color: Colors.white38, letterSpacing: 2, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
                ),
                child: Icon(_targetIcon, size: 60, color: const Color(0xFF7C4DFF)),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final icon = _gridIcons[index];
                    return GestureDetector(
                      onTap: () => _handleTap(icon),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Icon(icon, size: 40, color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
