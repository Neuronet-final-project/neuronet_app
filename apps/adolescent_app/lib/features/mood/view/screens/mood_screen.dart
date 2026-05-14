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
      backgroundColor: const Color(0xFFFBF9FF),
      body: state.showSuccess
          ? _buildSuccessView(context, notifier, ref)
          : Stack(
              children: [
                // Premium Mesh Gradient Background
                Positioned.fill(
                  child: Stack(
                    children: [
                      Container(color: const Color(0xFFFBF9FF)),
                      Positioned(
                        top: -100,
                        right: -50,
                        child: Container(
                          width: 400,
                          height: 400,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFD8C2FF).withOpacity(0.4),
                                const Color(0xFFD8C2FF).withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 200,
                        left: -100,
                        child: Container(
                          width: 350,
                          height: 350,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFB388FF).withOpacity(0.2),
                                const Color(0xFFB388FF).withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHeader(context, notifier, ref, moodHistoryAsync),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6A1FDB).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                context.localizations.dailyCheckInTag,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                  color: Color(0xFF6A1FDB),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              context.localizations.howAreYouFeelingNow,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1A123D),
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              context.localizations.tapEmojiPrompt,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7B6FAD),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            _buildMoodGrid(context, state, notifier),
                            const SizedBox(height: 40),
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              child: state.selectedMood != null
                                  ? Column(
                                      children: [
                                        _buildIntensitySection(context, state, notifier),
                                        const SizedBox(height: 32),
                                        _buildNotesSection(context, state, notifier),
                                        const SizedBox(height: 48),
                                        _buildSubmitButton(state, notifier, context),
                                        const SizedBox(height: 40),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            _buildMoodHistory(context, ref, moodHistoryAsync),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context, MoodController notifier, WidgetRef ref, AsyncValue<MoodHistoryState> moodHistoryAsync) {
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
              child: Icon(Icons.circle, size: 140, color: const Color(0xFF9E8CD8).withOpacity(0.16)),
            ),
            Positioned(
              left: -28,
              bottom: -36,
              child: Icon(Icons.circle, size: 120, color: const Color(0xFFB388FF).withOpacity(0.12)),
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
            child: moodHistoryAsync.when(
              data: (hState) => hState.isLoading 
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: NeuroColors.adolescentPrimaryDark),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: NeuroColors.adolescentPrimaryDark, size: 20),
                    onPressed: () {
                      notifier.reset();
                      ref.read(moodHistoryControllerProvider.notifier).refresh();
                    },
                  ),
              loading: () => const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: NeuroColors.adolescentPrimaryDark),
              ),
              error: (_, __) => IconButton(
                icon: const Icon(Icons.refresh_rounded, color: NeuroColors.adolescentPrimaryDark, size: 20),
                onPressed: () => ref.read(moodHistoryControllerProvider.notifier).refresh(),
              ),
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
        childAspectRatio: 0.85,
      ),
      itemCount: MoodType.values.length,
      itemBuilder: (context, index) {
        final mood = MoodType.values[index];
        final isSelected = state.selectedMood == mood;
        final color = _getMoodColor(mood);

        return GestureDetector(
          onTap: () => notifier.selectMood(mood),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isSelected ? color : const Color(0xFF6A1FDB).withValues(alpha: 0.08),
                width: 2,
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ] : [
                BoxShadow(
                  color: const Color(0xFF6A1FDB).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 250),
                  scale: isSelected ? 1.25 : 1.0,
                  child: Text(
                    _getMoodEmoji(mood),
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  mood.localizedLabel(context.localizations).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: isSelected ? Colors.white : const Color(0xFF7B6FAD),
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
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF6A1FDB).withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1FDB).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
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
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1A123D),
                  letterSpacing: -0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: NeuroGradients.adolescent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: NeuroColors.adolescentPrimary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  context.localizations.intensityLevel(state.intensity).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: NeuroColors.adolescentPrimary,
              inactiveTrackColor: const Color(0xFFE0DAF0),
              thumbColor: Colors.white,
              overlayColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.15),
              trackHeight: 10,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14, elevation: 4),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
              activeTickMarkColor: Colors.white.withValues(alpha: 0.3),
              inactiveTickMarkColor: const Color(0xFFB4A8D3),
            ),
            child: Slider(
              value: state.intensity.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (value) => notifier.updateIntensity(value),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.localizations.mildLabel.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFB4A8D3), letterSpacing: 1.0),
                ),
                Text(
                  context.localizations.strongLabel.toUpperCase(),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFB4A8D3), letterSpacing: 1.0),
                ),
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
            fontSize: 19,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A123D),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF6A1FDB).withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A1FDB).withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) => notifier.updateNotes(value),
            style: const TextStyle(fontSize: 16, color: Color(0xFF1A123D), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: context.localizations.moodNoteHint,
              hintStyle: const TextStyle(color: Color(0xFFB4A8D3), fontWeight: FontWeight.w500),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(24),
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
      height: 64,
      decoration: BoxDecoration(
        gradient: NeuroGradients.adolescent,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: NeuroColors.adolescentPrimary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: state.isSubmitting ? null : () => notifier.submitMood(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        ),
        child: state.isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
              )
            : Text(
                context.localizations.logMoodButton.toUpperCase(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5),
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: _getMoodColor(r.mood),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                if (r.intensity != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 3, height: 3,
                                    decoration: BoxDecoration(color: const Color(0xFFB4A8D3), shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${context.localizations.levelAbbr} ${r.intensity}'.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFB4A8D3), letterSpacing: 0.5),
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
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A123D),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                             else
                               Text(
                                 _safeFormatDate(r.createdAt.toLocal(), 'MMMM d, h:mm a', 'en'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF7B6FAD),
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
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFB4A8D3),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (records.length > 5) ...[
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.push(AdolescentRoutes.moodHistory),
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: Text(
                    context.localizations.allMoods.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF6A1FDB),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    backgroundColor: const Color(0xFF6A1FDB).withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
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
    // CRITICAL: Force treat server time as UTC if it's not marked as such.
    // This fixes the bug where server UTC is parsed as local (creating a 3h offset in UTC+3).
    final serverTime = dt.isUtc 
        ? dt 
        : DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond, dt.microsecond);
    
    final now = DateTime.now().toUtc();
    final diff = now.difference(serverTime);
    
    if (diff.isNegative || diff.inMinutes < 1) return context.localizations.now;
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
