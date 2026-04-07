import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/mood_provider.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodControllerProvider);
    final notifier = ref.read(moodControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    // Show error snackbar when error changes
    ref.listen(moodControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: colorScheme.errorContainer,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    final moodHistoryAsync = ref.watch(moodHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Tracker'),
        actions: [
          IconButton(
            onPressed: () {
              notifier.reset();
              ref.invalidate(moodHistoryProvider);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: state.showSuccess
          ? _buildSuccessView(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How are you feeling right now?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select the emoji that best matches your current mood.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: NeuroColors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildMoodGrid(context, state, notifier),
                  const SizedBox(height: 32),
                  if (state.selectedMood != null) ...[
                    _buildIntensitySection(context, state, notifier),
                    const SizedBox(height: 32),
                    _buildNotesSection(context, state, notifier),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: state.isSubmitting ? null : () => notifier.submitMood(),
                      child: state.isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Mood Entry'),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildMoodHistory(context, moodHistoryAsync),
                ],
              ),
            ),
    );
  }

  Widget _buildMoodHistory(BuildContext context, AsyncValue<List<MoodRecord>> historyAsync) {
    return historyAsync.when(
      data: (records) {
        if (records.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Recent Check-ins',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...records.take(5).map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(r.mood.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.mood.label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (r.note != null && r.note!.isNotEmpty)
                          Text(
                            r.note!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: NeuroColors.onSurfaceVariant,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatTimeAgo(r.createdAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: NeuroColors.onSurfaceVariant,
                            ),
                      ),
                      if (r.intensity != null)
                        Text(
                          'Intensity: ${r.intensity}/5',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: NeuroColors.onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildMoodGrid(BuildContext context, MoodState state, MoodController notifier) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: MoodType.values.length,
      itemBuilder: (context, index) {
        final mood = MoodType.values[index];
        return NeuroMoodIcon(
          moodType: mood,
          isSelected: state.selectedMood == mood,
          onTap: () => notifier.selectMood(mood),
        );
      },
    );
  }

  Widget _buildIntensitySection(BuildContext context, MoodState state, MoodController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'How intense is this feeling?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Intensity: ${state.intensity}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Slider(
          value: state.intensity.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: state.intensity.toString(),
          onChanged: (value) => notifier.updateIntensity(value),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mild', style: TextStyle(fontSize: 12)),
              Text('Strong', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context, MoodState state, MoodController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Any context? (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) => notifier.updateNotes(value),
          decoration: const InputDecoration(
            hintText: 'What happened? How are you dealing with it?',
            alignLabelWithHint: true,
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 100,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            'Mood Saved!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your emotional check-in helps us understand your needs.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: NeuroColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
