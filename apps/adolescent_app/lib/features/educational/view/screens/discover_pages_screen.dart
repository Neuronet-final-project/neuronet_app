import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/educational_follow_provider.dart';
import '../widgets/page_follow_button.dart';

class DiscoverPagesScreen extends ConsumerStatefulWidget {
  const DiscoverPagesScreen({super.key});

  @override
  ConsumerState<DiscoverPagesScreen> createState() => _DiscoverPagesScreenState();
}

class _DiscoverPagesScreenState extends ConsumerState<DiscoverPagesScreen> {
  String? _selectedCategory;
  String? _searchQuery;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query.isEmpty ? null : query;
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final discoveryAsync = ref.watch(
      pageDiscoveryControllerProvider(
        category: _selectedCategory,
        search: _searchQuery,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Pages'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search pages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
              ),
              onChanged: _onSearch,
            ),
          ),

          // Category Filters
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onSelected: () => _onCategorySelected(null),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Mood',
                  isSelected: _selectedCategory == 'mood',
                  onSelected: () => _onCategorySelected('mood'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Stress',
                  isSelected: _selectedCategory == 'stress',
                  onSelected: () => _onCategorySelected('stress'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Sleep',
                  isSelected: _selectedCategory == 'sleep',
                  onSelected: () => _onCategorySelected('sleep'),
                ),
                const SizedBox(width: 8),
                _CategoryChip(
                  label: 'Relationships',
                  isSelected: _selectedCategory == 'relationships',
                  onSelected: () => _onCategorySelected('relationships'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Pages List
          Expanded(
            child: discoveryAsync.when(
              data: (state) {
                if (state.error != null) {
                  return NeuroErrorWidget(
                    message: state.error!,
                    onRetry: () => ref.read(
                      pageDiscoveryControllerProvider(
                        category: _selectedCategory,
                        search: _searchQuery,
                      ).notifier,
                    ).refresh(),
                  );
                }

                final pages = state.discoveredPages;
                if (pages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NeuroEmptyState(
                        title: 'No pages found',
                        message: _searchQuery != null
                            ? 'Try a different search term'
                            : 'No pages available in this category',
                        icon: Icons.search_off,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(
                    pageDiscoveryControllerProvider(
                      category: _selectedCategory,
                      search: _searchQuery,
                    ).notifier,
                  ).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return _DiscoverPageCard(page: page);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => NeuroErrorWidget(
                message: 'Could not load pages.',
                onRetry: () => ref.read(
                  pageDiscoveryControllerProvider(
                    category: _selectedCategory,
                    search: _searchQuery,
                  ).notifier,
                ).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _DiscoverPageCard extends ConsumerWidget {
  const _DiscoverPageCard({required this.page});

  final EducationalPageWithFollowStatus page;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // Navigate to page detail
          context.push('/learn/${page.slug}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                        const SizedBox(height: 4),
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
                    isFollowed: page.isFollowed,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                page.content.length > 150
                    ? '${page.content.substring(0, 150)}...'
                    : page.content,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (page.counselorName != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      page.counselorName!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.people_outline,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${page.followCount} ${page.followCount == 1 ? 'follower' : 'followers'}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (page.popularityScore > 10) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 12,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Popular',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}