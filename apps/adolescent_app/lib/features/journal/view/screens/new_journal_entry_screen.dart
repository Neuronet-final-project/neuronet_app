import 'dart:math' as math;
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
        const SnackBar(
          content: Text('Please write something first'),
          behavior: SnackBarBehavior.floating,
        ),
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
        // Success feedback usually handled by navigation or a toast
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuroColors.paper,
      body: Stack(
        children: [
          // Subtle Paper Grain Texture
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _PaperGrainPainter()),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // 1. Editorial Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: NeuroColors.ink),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'COMPOSE',
                        style: TextStyle(
                          color: NeuroColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      TextButton(
                        onPressed: _isSaving ? null : _handleSave,
                        style: TextButton.styleFrom(
                          foregroundColor: NeuroColors.adolescentPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: _isSaving
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text(
                                'Save',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                      ),
                    ],
                  ),
                ),

                // 2. Mood Selector Strip (Top Alignment)
                _TopMoodSelector(
                  selectedMood: _selectedMood,
                  onMoodSelected: (mood) => setState(() => _selectedMood = mood),
                ),

                const Divider(height: 1, color: NeuroColors.hairline),

                // 3. Main Composition Area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _SparkStrip(
                        sparks: _sparks,
                        onSelect: (spark) => setState(() => _contentController.text = '$spark\n\n'),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: NeuroColors.ink,
                          letterSpacing: -0.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Untitled entry',
                          hintStyle: TextStyle(color: NeuroColors.inkSoft),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.6,
                          color: NeuroColors.inkSoft,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Start writing...',
                          hintStyle: TextStyle(color: NeuroColors.inkMuted),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkStrip extends StatelessWidget {
  const _SparkStrip({required this.sparks, required this.onSelect});
  final List<String> sparks;
  final Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NEED A SPARK?',
          style: TextStyle(
            color: NeuroColors.adolescentPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 10,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sparks.map((spark) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => onSelect(spark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: NeuroColors.hairline),
                    ),
                    child: Text(
                      spark,
                      style: const TextStyle(
                        color: NeuroColors.inkSoft,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _TopMoodSelector extends StatelessWidget {
  const _TopMoodSelector({required this.selectedMood, required this.onMoodSelected});
  final MoodType? selectedMood;
  final Function(MoodType) onMoodSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: MoodType.values.map((mood) {
            final isSelected = selectedMood == mood;
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onMoodSelected(mood),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? NeuroColors.ink : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? NeuroColors.ink : NeuroColors.hairline,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getMoodEmoji(mood),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
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
      case MoodType.sad: return '😢';
      case MoodType.stressed: return '😫';
      case MoodType.angry: return '😠';
      case MoodType.tired: return '😴';
      default: return '😐';
    }
  }
}

class _PaperGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final paint = Paint()..color = NeuroColors.ink;
    final random = math.Random(42);
    for (var i = 0; i < 2000; i++) {
       canvas.drawCircle(
         Offset(random.nextDouble() * size.width, random.nextDouble() * size.height),
         0.5,
         paint,
       );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
