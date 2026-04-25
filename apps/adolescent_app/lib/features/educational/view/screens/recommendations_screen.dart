import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/educational_provider.dart';
import '../../providers/ai_recommendation_provider.dart';

class RecommendationsScreen extends ConsumerStatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  ConsumerState<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends ConsumerState<RecommendationsScreen> {
  bool _showAIRecommendations = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiRecommendationsAsync = ref.watch(aIRecommendationControllerProvider);
    final regularRecommendationsAsync = ref.watch(adolescentRecommendationsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Picked for You'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (_showAIRecommendations) {
                ref.read(aIRecommendationControllerProvider.notifier).refresh();
              } else {
                ref.read(adolescentRecommendationsControllerProvider.notifier).refresh();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toggle between AI and regular recommendations
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('AI Picks'),
                  icon: Icon(Icons.auto_awesome_rounded),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Popular'),
                  icon: Icon(Icons.trending_up_rounded),
                ),
              ],
              selected: {_showAIRecommendations},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _showAIRecommendations = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: _showAIRecommendations
                ? _buildAIRecommendations(aiRecommendationsAsync, theme)
                : _buildRegularRecommendations(regularRecommendationsAsync, theme),
          ),
        ],
      ),
      floatingActionButton: _showAIRecommendations
          ? FloatingActionButton.extended(
              onPressed: () async {
                final success = await ref
                    .read(aIRecommendationControllerProvider.notifier)
                    .triggerAnalysis();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Analysis complete! Check for new recommendations.'
                            : 'No new recommendations at this time.',
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.psychology_rounded),
              label: const Text('Analyze Now'),
            )
          : null,
    );
  }

  Widget _buildAIRecommendations(
    AsyncValue<AIRecommendationState> aiRecommendationsAsync,
    ThemeData theme,
  ) {
    return aiRecommendationsAsync.when(
      data: (state) {
        if (state.error != null) {
          return NeuroErrorWidget(
            message: state.error!,
            onRetry: () => ref.read(aIRecommendationControllerProvider.notifier).refresh(),
          );
        }

        if (state.isAnalyzing) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Analyzing your journey...',
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        final recommendations = state.recommendations;
        if (recommendations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: NeuroEmptyState(
                title: 'No AI picks yet!',
                message:
                    'Keep journaling and exploring! Our AI will analyze your journey and suggest personalized content.',
                icon: Icons.auto_awesome_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: recommendations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final recommendation = recommendations[index];
            return _AIRecommendationCard(recommendation: recommendation);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => NeuroErrorWidget(
        message: 'Could not load AI recommendations.',
        onRetry: () => ref.read(aIRecommendationControllerProvider.notifier).refresh(),
      ),
    );
  }

  Widget _buildRegularRecommendations(
    AsyncValue<EducationalState> recommendationsAsync,
    ThemeData theme,
  ) {
    return recommendationsAsync.when(
      data: (state) {
        if (state.error != null) {
          return NeuroErrorWidget(
            message: state.error!,
            onRetry: () =>
                ref.read(adolescentRecommendationsControllerProvider.notifier).refresh(),
          );
        }

        final recommendations = state.recommendations;
        if (recommendations.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: NeuroEmptyState(
                title: 'No picks yet!',
                message:
                    'Keep journaling and exploring! Your personalized picks will appear here as we learn more about your journey.',
                icon: Icons.auto_fix_high_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: recommendations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final recommendation = recommendations[index];
            return _RecommendationCard(recommendation: recommendation);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => NeuroErrorWidget(
        message: 'Could not load your picks.',
        onRetry: () =>
            ref.read(adolescentRecommendationsControllerProvider.notifier).refresh(),
      ),
    );
  }
}

class _AIRecommendationCard extends ConsumerWidget {
  const _AIRecommendationCard({required this.recommendation});

  final AIRecommendation recommendation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: recommendation.isViewed ? 0 : 2,
      color: recommendation.isViewed
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: recommendation.isViewed
              ? theme.colorScheme.outline.withValues(alpha: 0.2)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: recommendation.isViewed ? 1 : 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: recommendation.isViewed
                        ? null
                        : LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                    color: recommendation.isViewed ? theme.colorScheme.outline : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'AI PICK',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (recommendation.isViewed)
                  Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_rounded,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation.triggerReason,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Recommended for you:',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...recommendation.recommendedPages.map((page) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _RecommendedPageTile(
                  page: page,
                  onTap: () async {
                    // Mark as viewed when tapped
                    if (!recommendation.isViewed) {
                      await ref
                          .read(aIRecommendationControllerProvider.notifier)
                          .markAsViewed(recommendation.recommendationId);
                    }
                    // Navigate to page - need to convert to EducationalPage
                    if (context.mounted) {
                      context.push('/learn/${page.slug}');
                    }
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RecommendedPageTile extends StatelessWidget {
  const _RecommendedPageTile({
    required this.page,
    required this.onTap,
  });

  final RecommendedPage page;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (page.category != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          page.category!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (page.followCount > 0) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.people_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${page.followCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.recommendation});

  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final page = recommendation.page;

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          context.push('/learn/${page.slug}', extra: page);
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'SMART PICK',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.lightbulb_outline_rounded,
                      color: theme.colorScheme.primary, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                recommendation.reason,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Related Article:',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            page.title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
