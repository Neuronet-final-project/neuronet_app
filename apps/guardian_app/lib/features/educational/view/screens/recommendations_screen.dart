import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/educational_provider.dart';

class GuardianRecommendationsScreen extends ConsumerWidget {
  const GuardianRecommendationsScreen({
    super.key,
    required this.adolescentId,
    required this.adolescentName,
  });

  final String adolescentId;
  final String adolescentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(
      guardianRecommendationsProvider(adolescentId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Picked for $adolescentName'),
        elevation: 0,
      ),
      body: recommendationsAsync.when(
        skipLoadingOnReload: true,
        data: (pages) {
          if (pages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: NeuroEmptyState(
                  title: 'No picks yet',
                  message:
                      'Personalized recommendations will appear here as $adolescentName continues journaling and exploring.',
                  icon: Icons.auto_fix_high_rounded,
                  color: NeuroColors.guardianPrimary,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: pages.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final page = pages[index];
              return _RecommendationCard(page: page);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => NeuroErrorWidget(
          message: 'Could not load recommendations.\n${err.toString().replaceAll('Exception: ', '').replaceAll('[GuardianRecommendations] ', '')}',
          onRetry: () => ref.invalidate(
            guardianRecommendationsProvider(adolescentId),
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.page});

  final EducationalPage page;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
        ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: NeuroColors.guardianPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      page.category?.toUpperCase() ?? 'SMART PICK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.auto_awesome, color: NeuroColors.guardianPrimary, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                page.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: NeuroColors.onSurface,
                ),
              ),
              if (page.summary != null) ...[
                const SizedBox(height: 8),
                Text(
                  page.summary!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: NeuroColors.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tap to read full article',
                            style: TextStyle(
                              fontSize: 12,
                              color: NeuroColors.onSurfaceVariant,
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
