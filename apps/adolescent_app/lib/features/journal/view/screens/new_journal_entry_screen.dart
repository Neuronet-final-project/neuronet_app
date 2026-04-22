import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/journal_provider.dart';

class NewJournalEntryScreen extends ConsumerStatefulWidget {
  const NewJournalEntryScreen({super.key});

  @override
  ConsumerState<NewJournalEntryScreen> createState() => _NewJournalEntryScreenState();
}

class _NewJournalEntryScreenState extends ConsumerState<NewJournalEntryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  MoodType? _selectedMood;
  bool _isSaving = false;

  final List<String> _sparks = [
    'What made me smile today?',
    "One thing I'm grateful for",
    'A small victory I had',
    'How I handled a challenge',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final content = _contentController.text.trim();
    final title = _titleController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      await ref.read(journalControllerProvider.notifier).addEntry(
        content,
        title: title.isEmpty ? null : title,
        mood: _selectedMood ?? MoodType.neutral,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry saved!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New Entry',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB388FF).withOpacity(0.4),
                foregroundColor: const Color(0xFF7C4DFF),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Row(
                      children: [
                        Icon(Icons.check_rounded, size: 18),
                        SizedBox(width: 8),
                        Text('Save', style: TextStyle(fontWeight: FontWeight.w900)),
                      ],
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: Color(0xFF7C4DFF), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'NEED A SPARK?',
                      style: TextStyle(
                        color: Color(0xFF7C4DFF),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sparks.map((spark) => _SparkChip(
                      label: spark,
                      onTap: () {
                        setState(() {
                          _contentController.text = '$spark\n\n';
                        });
                      },
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Give it a title (optional)',
                          hintStyle: TextStyle(color: Color(0xFFCBD5E1)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const Divider(height: 32, color: Color(0xFFF1F5F9)),
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        minLines: 8,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFF475569),
                        ),
                        decoration: const InputDecoration(
                          hintText: "What's on your mind today?\nNo rules — just write.",
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _MoodSelector(
            selectedMood: _selectedMood,
            charCount: _contentController.text.length,
            onMoodSelected: (mood) => setState(() => _selectedMood = mood),
          ),
        ],
      ),
    );
  }
}

class _SparkChip extends StatelessWidget {
  const _SparkChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  const _MoodSelector({
    required this.selectedMood,
    required this.onMoodSelected,
    required this.charCount,
  });

  final MoodType? selectedMood;
  final Function(MoodType) onMoodSelected;
  final int charCount;

  @override
  Widget build(BuildContext context) {
    final moods = [
      MoodType.happy,
      MoodType.calm,
      MoodType.hopeful,
      MoodType.excited,
      MoodType.anxious,
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).padding.bottom + 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.sentiment_satisfied_rounded, color: Color(0xFF7C4DFF), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'HOW ARE YOU FEELING?',
                    style: TextStyle(
                      color: Color(0xFF7C4DFF),
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                '$charCount / 5000',
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: moods.map((mood) {
              final isSelected = selectedMood == mood;
              return GestureDetector(
                onTap: () => onMoodSelected(mood),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF7C4DFF).withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF7C4DFF) : const Color(0xFFF1F5F9),
                          width: 2,
                        ),
                      ),
                      child: mood == MoodType.hopeful
                          ? const _PremiumRainbowIcon()
                          : Text(_getMoodEmoji(mood), style: const TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood.name.substring(0, 1).toUpperCase() + mood.name.substring(1),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                        color: isSelected ? const Color(0xFF7C4DFF) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return '😊';
      case MoodType.calm: return '🍃';
      case MoodType.hopeful: return '🌈';
      case MoodType.excited: return '✨';
      case MoodType.anxious: return '😰';
      default: return '😐';
    }
  }
}

class _PremiumRainbowIcon extends StatefulWidget {
  const _PremiumRainbowIcon();

  @override
  State<_PremiumRainbowIcon> createState() => _PremiumRainbowIconState();
}

class _PremiumRainbowIconState extends State<_PremiumRainbowIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return SweepGradient(
              center: Alignment.center,
              startAngle: 0.0,
              endAngle: 3.14 * 2,
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.yellow,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
                Colors.red,
              ],
              transform: GradientRotation(_controller.value * 3.14 * 2),
            ).createShader(bounds);
          },
          child: const Icon(
            Icons.looks_rounded,
            size: 32,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
