import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';
import 'package:guardian_app/features/ui/bento_card.dart';

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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF9FAFB),
            surfaceTintColor: const Color(0xFFF9FAFB),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
              color: NeuroColors.onSurface,
            ),
            title: const Text(
              'Followed Pages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: _loadFollows,
                color: NeuroColors.guardianPrimary,
              ),
            ],
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: NeuroErrorWidget(
                    message: _error!,
                    onRetry: _loadFollows,
                  ),
                ),
              ),
            )
          else if (_follows.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: NeuroEmptyState(
                  title: 'No Followed Pages',
                  message: '${widget.adolescentName} hasn\'t followed any educational pages yet',
                  icon: Icons.bookmark_border,
                  color: NeuroColors.guardianPrimary,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              sliver: SliverList.separated(
                itemCount: _follows.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final follow = _follows[index];
                  return _FollowCard(follow: follow)
                      .animate()
                      .fadeIn(delay: (index * 100).ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutQuad);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FollowCard extends StatelessWidget {
  const _FollowCard({required this.follow});

  final FollowedPageSummary follow;

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Following Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      follow.pageTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: NeuroColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (follow.pageCategory != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.category_rounded,
                            size: 14,
                            color: NeuroColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            follow.pageCategory!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: NeuroColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: NeuroColors.guardianPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Following',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Followed Date
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: NeuroColors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Followed ${_formatDate(follow.followedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: NeuroColors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
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
