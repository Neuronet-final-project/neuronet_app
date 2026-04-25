import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/educational_provider.dart';
import '../../providers/educational_follow_provider.dart';
import '../widgets/page_follow_button.dart';

class EducationalLibraryScreen extends ConsumerWidget {
  const EducationalLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pagesAsync = ref.watch(educationalPagesControllerProvider);
    final followedPagesAsync = ref.watch(educationalFollowControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner\'s Nook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_outline_rounded),
            onPressed: () => context.push('/recommendations'),
            tooltip: 'My Recommendations',
          ),
          IconButton(
            icon: const Icon(Icons.explore_outlined),
            onPressed: () => context.push('/discover-pages'),
            tooltip: 'Discover Pages',
          ),
        ],
      ),
      body: pagesAsync.when(
        data: (state) {
          if (state.error != null) {
            return NeuroErrorWidget(
              message: state.error!,
              onRetry: () => ref.read(educationalPagesControllerProvider.notifier).refresh(),
            );
          }

          final pages = state.pages;
          if (pages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: NeuroEmptyState(
                  title: 'Library is empty',
                  message: 'No articles in the nook just yet. Check back soon for new content!',
                  icon: Icons.library_books_outlined,
                  color: NeuroColors.onSurfaceVariant,
                ),
              ),
            );
          }

          // Get followed page slugs
          final followedSlugs = followedPagesAsync.when(
            data: (followState) => followState.followedPages.map((p) => p.pageSlug).toSet(),
            loading: () => <String>{},
            error: (_, __) => <String>{},
          );

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              final isFollowed = followedSlugs.contains(page.slug);
              return _PageCard(page: page, isFollowed: isFollowed);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => NeuroErrorWidget(
          message: 'Could not load library.',
          onRetry: () => ref.read(educationalPagesControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _PageCard extends ConsumerWidget {
  const _PageCard({required this.page, required this.isFollowed});

  final EducationalPage page;
  final bool isFollowed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/learn/${page.slug}', extra: page),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getCategoryIcon(page.category),
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (page.category != null)
                          Text(
                            page.category!.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        Text(
                          page.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CompactFollowButton(
                    pageSlug: page.slug,
                    isFollowed: isFollowed,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                page.summary ?? 'Read more about ${page.title}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'mood': return Icons.face_retouching_natural_rounded;
      case 'stress': return Icons.waves_rounded;
      case 'sleep': return Icons.nights_stay_rounded;
      case 'relationships': return Icons.people_outline_rounded;
      default: return Icons.chrome_reader_mode_outlined;
    }
  }
}
