import 'package:flutter/material.dart';
import 'package:neuronet_core/neuronet_core.dart';

/// Shared UI for new and edit journal flows.
class JournalComposerBottomBar extends StatelessWidget {
  const JournalComposerBottomBar({super.key, required this.isSaving, required this.onSave, this.label = 'Save'});
  final bool isSaving;
  final VoidCallback? onSave;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF0EAFF), Color(0xFFE4DAFA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(top: BorderSide(color: Color(0x26FFFFFF), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: onSave == null
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFF5A1BC7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: onSave == null ? const Color(0xFFC4B8E0) : null,
                  boxShadow: onSave == null
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFF5A1BC7).withValues(alpha: 0.45),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: FilledButton(
                  onPressed: onSave,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.6),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JournalComposerSparkStrip extends StatelessWidget {
  const JournalComposerSparkStrip({super.key, required this.sparks, required this.onSelect});
  final List<String> sparks;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, color: NeuroColors.adolescentPrimary, size: 18),
            const SizedBox(width: 4),
            const Text(
              'WRITING SPARKS',
              style: TextStyle(
                color: NeuroColors.adolescentPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: sparks.map((spark) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onSelect(spark),
                    borderRadius: BorderRadius.circular(18),
                    splashColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.12),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: NeuroColors.adolescentPrimary.withValues(alpha: 0.22),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NeuroColors.adolescentPrimary.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          spark,
                          style: const TextStyle(
                            color: Color(0xFF53477D),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

class JournalComposerMoodStrip extends StatelessWidget {
  const JournalComposerMoodStrip({super.key, required this.selectedMood, required this.onMoodSelected});
  final MoodType? selectedMood;
  final void Function(MoodType) onMoodSelected;

  static const _moods = [
    MoodType.happy, MoodType.calm, MoodType.excited,
    MoodType.hopeful, MoodType.neutral, MoodType.tired,
    MoodType.anxious, MoodType.sad,
  ];

  static const _bgColors = [
    Color(0xFFFFDF8D),
    Color(0xFFC7EBCB),
    Color(0xFFFFD1DF),
    Color(0xFFD5EDFC),
    Color(0xFFEBEBE6),
    Color(0xFFD2D5E6),
    Color(0xFFFFD4A9),
    Color(0xFFD5DAED),
  ];

  static const _labelColors = [
    Color(0xFF906636),
    Color(0xFF3F694F),
    Color(0xFF883C5A),
    Color(0xFF3B5D7C),
    Color(0xFF61615E),
    Color(0xFF4C526A),
    Color(0xFF9C5E35),
    Color(0xFF313D60),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'How are you feeling right now?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _moods.length,
            itemBuilder: (context, i) {
              final mood = _moods[i];
              final isSelected = selectedMood == mood;
              final bgColor = _bgColors[i];
              final labelColor = _labelColors[i];

              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onMoodSelected(mood),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? bgColor : NeuroColors.adolescentSurface,
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: labelColor, width: 2) : Border.all(color: NeuroColors.adolescentSurface),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: labelColor.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            mood.emoji,
                            style: TextStyle(fontSize: isSelected ? 32 : 26),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
