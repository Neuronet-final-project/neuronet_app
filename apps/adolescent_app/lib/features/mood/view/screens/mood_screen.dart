import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';
import '../../providers/mood_provider.dart';

/// Safely formats a date with locale fallback.
String _safeFormatDate(DateTime date, String pattern, String locale) {
  try {
    return intl.DateFormat(pattern, locale).format(date);
  } on ArgumentError {
    return intl.DateFormat(pattern, 'en').format(date);
  }
}

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodControllerProvider);
    final notifier = ref.read(moodControllerProvider.notifier);
    final moodHistoryAsync = ref.watch(moodHistoryControllerProvider);

    // Show error snackbar when error changes
    ref.listen(moodControllerProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: NeuroColors.adolescentSurface,
      body: state.showSuccess
          ? _buildSuccessView(context, notifier, ref)
          : Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF2ECFF),
                          NeuroColors.adolescentSurface,
                          const Color(0xFFE7DDFC).withValues(alpha: 0.35),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.38, 1.0],
                      ),
                    ),
                  ),
                ),
                CustomScrollView(
                  slivers: [
                    _buildHeader(context, notifier, ref),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFE8FF),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              context.localizations.dailyCheckInTag,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Color(0xFF6A1FDB),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            context.localizations.howAreYouFeelingNow,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2C1C5F),
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            context.localizations.tapEmojiPrompt,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6A5C9A),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildMoodGrid(context, state, notifier),
                          const SizedBox(height: 40),
                          if (state.selectedMood != null) ...[
                            _buildIntensitySection(context, state, notifier),
                            const SizedBox(height: 32),
                            _buildNotesSection(context, state, notifier),
                            const SizedBox(height: 48),
                            _buildSubmitButton(state, notifier, context),
                            const SizedBox(height: 32),
                          ],
                          _buildMoodHistory(context, ref, moodHistoryAsync),
                          const SizedBox(height: 80),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, MoodController notifier, WidgetRef ref) {
    return SliverAppBar(
      expandedHeight: 132,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Icon(Icons.circle, size: 140, color: const Color(0xFF9E8CD8).withValues(alpha: 0.16)),
            ),
            Positioned(
              left: -28,
              bottom: -36,
              child: Icon(Icons.circle, size: 120, color: const Color(0xFFB388FF).withValues(alpha: 0.12)),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2C1C5F), size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AdolescentRoutes.home);
              }
            },
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: NeuroColors.adolescentPrimaryDark, size: 20),
              onPressed: () {
                notifier.reset();
                ref.read(moodHistoryControllerProvider.notifier).refresh();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodGrid(BuildContext context, MoodState state, MoodController notifier) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: MoodType.values.length,
      itemBuilder: (context, index) {
        final mood = MoodType.values[index];
        final isSelected = state.selectedMood == mood;
        final color = _getMoodColor(mood);

        return GestureDetector(
          onTap: () => notifier.selectMood(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected ? color : NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
                width: 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ] : [
                BoxShadow(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getMoodEmoji(mood),
                  style: TextStyle(fontSize: isSelected ? 36 : 28),
                ),
                const SizedBox(height: 8),
                Text(
                  mood.localizedLabel(context.localizations).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isSelected ? Colors.white : const Color(0xFF8A7DAC),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntensitySection(BuildContext context, MoodState state, MoodController notifier) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: NeuroColors.adolescentPrimary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.localizations.intensityLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2C1C5F),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: NeuroGradients.adolescent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  context.localizations.intensityLevel(state.intensity),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: NeuroColors.adolescentPrimary,
              inactiveTrackColor: NeuroColors.adolescentPrimaryLight.withValues(alpha: 0.3),
              thumbColor: NeuroColors.adolescentPrimaryDark,
              overlayColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.2),
              trackHeight: 8,
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
              activeTickMarkColor: Colors.white.withValues(alpha: 0.5),
              inactiveTickMarkColor: NeuroColors.adolescentPrimaryLight.withValues(alpha: 0.5),
            ),
            child: Slider(
              value: state.intensity.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) => notifier.updateIntensity(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(context.localizations.mildLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8A7DAC))),
                Text(context.localizations.strongLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF8A7DAC))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, MoodState state, MoodController notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.localizations.moodReasonPrompt,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C1C5F),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: NeuroColors.adolescentPrimary.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: NeuroColors.adolescentPrimary.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) => notifier.updateNotes(value),
            style: const TextStyle(fontSize: 16, color: Color(0xFF53477D), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: context.localizations.moodNoteHint,
              hintStyle: const TextStyle(color: Color(0xFFB4A8D3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
            ),
            maxLines: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(MoodState state, MoodController notifier, BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: NeuroGradients.adolescent,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [NeuroShadows.adolescentGlow],
      ),
      child: ElevatedButton(
        onPressed: state.isSubmitting ? null : () => notifier.submitMood(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: state.isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
              )
            : Text(
                context.localizations.logMoodButton,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, MoodController notifier, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.favorite_rounded, size: 80, color: NeuroColors.adolescentPrimary),
          ),
          const SizedBox(height: 48),
          Text(
            context.localizations.moodLoggedSuccess,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF2C1C5F),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.localizations.thanksCheckingIn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6A5C9A),
            ),
          ),
          const SizedBox(height: 48),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: NeuroGradients.adolescent,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => context.go(AdolescentRoutes.home), // Keep go here as it is a final success state
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(
                context.localizations.home.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              notifier.reset();
              ref.read(moodHistoryControllerProvider.notifier).refresh();
            },
            style: TextButton.styleFrom(
              foregroundColor: NeuroColors.adolescentPrimaryDark,
            ),
            child: Text(context.localizations.logAnotherMood, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodHistory(BuildContext context, WidgetRef ref, AsyncValue<MoodHistoryState> historyAsync) {
    return historyAsync.when(
      data: (state) {
        if (state.isLoading && state.records.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: NeuroColors.adolescentPrimary));
        }

        if (state.error != null && state.records.isEmpty) {
           return NeuroErrorWidget(
             message: '${context.localizations.failedToLoadHistory}: ${state.error}',
             onRetry: () => ref.read(moodHistoryControllerProvider.notifier).refresh(),
           );
        }

        final records = state.records;
        if (records.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Color(0xFFE0DAF0), height: 1),
            const SizedBox(height: 32),
            Text(
              context.localizations.pastCheckInsHeader,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C1C5F),
              ),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: records.take(5).length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final r = records[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: NeuroColors.adolescentPrimary.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getMoodColor(r.mood).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Text(r.mood.emoji, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  r.mood.localizedLabel(context.localizations).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: _getMoodColor(r.mood),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                if (r.intensity != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4, height: 4,
                                    decoration: const BoxDecoration(color: Color(0xFF8A7DAC), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${context.localizations.levelAbbr} ${r.intensity}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF8A7DAC)),
                                  ),
                                ]
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (r.note != null && r.note!.isNotEmpty)
                              Text(
                                r.note!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF53477D),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                             else
                               Text(
                                 _safeFormatDate(r.createdAt, 'MMMM d, y h:mm a', 'en'),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8A7DAC),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatTimeAgo(r.createdAt, context),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB4A8D3),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: NeuroColors.adolescentPrimary)),
      error: (err, stack) => NeuroErrorWidget(
        message: '${context.localizations.errorPrefix}: $err',
        onRetry: () => ref.read(moodHistoryControllerProvider.notifier).refresh(),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt, BuildContext context) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return context.localizations.now;
    if (diff.inMinutes < 60) return '${diff.inMinutes}${context.localizations.minAbbr}';
    if (diff.inHours < 24) return '${diff.inHours}${context.localizations.hourAbbr}';
    return '${diff.inDays}${context.localizations.dayAbbr}';
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return const Color(0xFFFFA726);
      case MoodType.calm: return const Color(0xFF66BB6A);
      case MoodType.anxious: return const Color(0xFFFF7043);
      case MoodType.sad: return const Color(0xFF42A5F5);
      case MoodType.hopeful: return const Color(0xFFAB47BC);
      case MoodType.excited: return const Color(0xFFEC407A);
      case MoodType.tired: return const Color(0xFF7E57C2);
      case MoodType.angry: return const Color(0xFFEF5350);
      default: return NeuroColors.adolescentPrimary;
    }
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
