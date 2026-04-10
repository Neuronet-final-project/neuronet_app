import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/educational_provider.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(adolescentRecommendationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Picked for You'),
        elevation: 0,
      ),
      body: recommendationsAsync.when(
        data: (recommendations) {
          if (recommendations.isEmpty) {
             return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: NeuroEmptyState(
                  title: 'No picks yet!',
                  message: 'Keep journaling and exploring! Your personalized picks will appear here as we learn more about your journey.',
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
          onRetry: () => ref.refresh(adolescentRecommendationsProvider),
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
                  Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
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
