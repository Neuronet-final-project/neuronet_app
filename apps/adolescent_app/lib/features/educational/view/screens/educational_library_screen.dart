import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';

class EducationalLibraryScreen extends ConsumerStatefulWidget {
  const EducationalLibraryScreen({super.key});

  @override
  ConsumerState<EducationalLibraryScreen> createState() => _EducationalLibraryScreenState();
}

class _EducationalLibraryScreenState extends ConsumerState<EducationalLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingCategories = false;
  bool _isLoadingFeed = false;
  List<Category> _categories = [];
  List<EducationalPage> _feedArticles = [];
  String? _categoriesError;
  String? _feedError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
    _loadFeed();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    final service = ref.read(educationalServiceProvider);
    final result = await service.getAvailableCategories();

    result.when(
      success: (categories) {
        if (mounted) {
          setState(() {
            _categories = categories;
            _isLoadingCategories = false;
          });
        }
      },
      failure: (failure) {
        if (mounted) {
          setState(() {
            _categoriesError = failure.message;
            _isLoadingCategories = false;
          });
        }
      },
    );
  }

  Future<void> _loadFeed() async {
    setState(() {
      _isLoadingFeed = true;
      _feedError = null;
    });

    final service = ref.read(educationalServiceProvider);
    final result = await service.getMyFeed();

    result.when(
      success: (articles) {
        if (mounted) {
          setState(() {
            _feedArticles = articles;
            _isLoadingFeed = false;
          });
        }
      },
      failure: (failure) {
        if (mounted) {
          setState(() {
            _feedError = failure.message;
            _isLoadingFeed = false;
          });
        }
      },
    );
  }

  Future<void> _toggleCategoryFollow(Category category) async {
    final followService = ref.read(educationalFollowServiceProvider);
    
    if (category.isFollowed) {
      final result = await followService.unfollowCategory(category.value);
      result.when(
        success: (_) {
          _loadCategories();
          _loadFeed();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Unfollowed ${category.label}')),
            );
          }
        },
        failure: (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
      );
    } else {
      final result = await followService.followCategory(category.value);
      result.when(
        success: (_) {
          _loadCategories();
          _loadFeed();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Following ${category.label}')),
            );
          }
        },
        failure: (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${failure.message}')),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learner\'s Nook'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Browse Topics', icon: Icon(Icons.explore_outlined)),
            Tab(text: 'My Feed', icon: Icon(Icons.article_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseTopicsTab(theme),
          _buildMyFeedTab(theme),
        ],
      ),
    );
  }

  Widget _buildBrowseTopicsTab(ThemeData theme) {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categoriesError != null) {
      return NeuroErrorWidget(
        message: _categoriesError!,
        onRetry: _loadCategories,
      );
    }

    if (_categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: NeuroEmptyState(
            title: 'No topics available',
            message: 'Check back soon for new topics!',
            icon: Icons.category_outlined,
            color: NeuroColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return _CategoryCard(
            category: category,
            onToggleFollow: () => _toggleCategoryFollow(category),
          );
        },
      ),
    );
  }

  Widget _buildMyFeedTab(ThemeData theme) {
    if (_isLoadingFeed) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_feedError != null) {
      return NeuroErrorWidget(
        message: _feedError!,
        onRetry: _loadFeed,
      );
    }

    if (_feedArticles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: NeuroEmptyState(
            title: 'Your feed is empty',
            message: 'Follow some topics to see articles here!',
            icon: Icons.article_outlined,
            color: NeuroColors.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFeed,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _feedArticles.length,
        itemBuilder: (context, index) {
          final article = _feedArticles[index];
          return _ArticleCard(article: article);
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onToggleFollow,
  });

  final Category category;
  final VoidCallback onToggleFollow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = _getCategoryGradient(category.value);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: category.isFollowed
              ? theme.colorScheme.primary
              : theme.colorScheme.outline.withValues(alpha: 0.1),
          width: category.isFollowed ? 2 : 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onToggleFollow,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Category icon with gradient
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getCategoryIcon(category.value),
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${category.articleCount} articles',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${category.followerCount} followers',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Follow button
              FilledButton.icon(
                onPressed: onToggleFollow,
                icon: Icon(
                  category.isFollowed ? Icons.check : Icons.add,
                  size: 18,
                ),
                label: Text(category.isFollowed ? 'Following' : 'Follow'),
                style: FilledButton.styleFrom(
                  backgroundColor: category.isFollowed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primaryContainer,
                  foregroundColor: category.isFollowed
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LinearGradient _getCategoryGradient(String value) {
    switch (value.toLowerCase()) {
      case 'anxiety':
        return const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        );
      case 'depression':
        return const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        );
      case 'stress':
        return const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
        );
      case 'self-care':
        return const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
      case 'relationships':
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        );
      case 'coping':
        return const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
        );
      case 'mindfulness':
        return const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
        );
      case 'wellness':
        return const LinearGradient(
          colors: [Color(0xFF84CC16), Color(0xFF22C55E)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF6B7280), Color(0xFF4B5563)],
        );
    }
  }

  IconData _getCategoryIcon(String value) {
    switch (value.toLowerCase()) {
      case 'anxiety':
        return Icons.psychology_outlined;
      case 'depression':
        return Icons.sentiment_dissatisfied_outlined;
      case 'stress':
        return Icons.waves_rounded;
      case 'self-care':
        return Icons.self_improvement_outlined;
      case 'relationships':
        return Icons.people_outline_rounded;
      case 'coping':
        return Icons.healing_outlined;
      case 'mindfulness':
        return Icons.spa_outlined;
      case 'wellness':
        return Icons.favorite_outline;
      default:
        return Icons.category_outlined;
    }
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.article});

  final EducationalPage article;

  @override
  Widget build(BuildContext context) {
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
        onTap: () => context.push('/learn/${article.slug}', extra: article),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Featured image or icon
                  if (article.featuredImageUrl != null && article.featuredImageUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        article.featuredImageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _getCategoryIcon(article.category),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getCategoryIcon(article.category),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (article.category != null)
                          Text(
                            article.category!.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          article.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                article.summary ?? 'Read more about ${article.title}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Meta info
              if (article.estimatedReadTime > 0 || article.viewCount > 0) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    if (article.estimatedReadTime > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${article.estimatedReadTime} min',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    if (article.viewCount > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${article.viewCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'anxiety': return Icons.psychology_outlined;
      case 'depression': return Icons.sentiment_dissatisfied_outlined;
      case 'stress': return Icons.waves_rounded;
      case 'self-care': return Icons.self_improvement_outlined;
      case 'relationships': return Icons.people_outline_rounded;
      case 'coping': return Icons.healing_outlined;
      case 'mindfulness': return Icons.spa_outlined;
      case 'wellness': return Icons.favorite_outline;
      default: return Icons.chrome_reader_mode_outlined;
    }
  }
}
