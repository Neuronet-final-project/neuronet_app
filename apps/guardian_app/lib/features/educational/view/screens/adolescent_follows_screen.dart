import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';

class AdolescentFollowsScreen extends ConsumerStatefulWidget {
  const AdolescentFollowsScreen({
    super.key,
    required this.adolescentId,
    required this.adolescentName,
  });

  final String adolescentId;
  final String adolescentName;

  @override
  ConsumerState<AdolescentFollowsScreen> createState() => _AdolescentFollowsScreenState();
}

class _AdolescentFollowsScreenState extends ConsumerState<AdolescentFollowsScreen> {
  List<FollowedPageSummary> _follows = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFollows();
  }

  Future<void> _loadFollows() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ref.read(educationalFollowServiceProvider);
      final result = await service.getGuardianView(widget.adolescentId);

      result.when(
        success: (follows) {
          if (mounted) {
            setState(() {
              _follows = follows;
              _loading = false;
            });
          }
        },
        failure: (f) {
          if (mounted) {
            setState(() {
              _error = f.message;
              _loading = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load followed pages';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Followed Pages'),
            Text(
              widget.adolescentName,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFollows,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: NeuroErrorWidget(
                    message: _error!,
                    onRetry: _loadFollows,
                  ),
                )
              : _follows.isEmpty
                  ? Center(
                      child: NeuroEmptyState(
                        title: 'No Followed Pages',
                        message: '${widget.adolescentName} hasn\'t followed any educational pages yet',
                        icon: Icons.bookmark_border,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _follows.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final follow = _follows[index];
                        return _FollowCard(follow: follow);
                      },
                    ),
    );
  }
}

class _FollowCard extends StatelessWidget {
  const _FollowCard({required this.follow});

  final FollowedPageSummary follow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    follow.pageTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Following',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (follow.pageCategory != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.category_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    follow.pageCategory!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Followed ${_formatDate(follow.followedAt)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()} week${diff.inDays > 14 ? 's' : ''} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Recently';
    }
  }
}
