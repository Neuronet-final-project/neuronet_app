import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/approval_provider.dart';

class ApprovalsScreen extends ConsumerWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final approvalState = ref.watch(guardianApprovalControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(guardianApprovalControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: approvalState.when(
        data: (state) {
          if (state.error != null) {
            return Center(
              child: NeuroErrorWidget(
                message: state.error!,
                onRetry: () => ref.read(guardianApprovalControllerProvider.notifier).refresh(),
              ),
            );
          }

          if (state.pendingApprovals.isEmpty && state.historyApprovals.isEmpty) {
            return Center(
              child: NeuroEmptyState(
                title: 'No Approval Requests',
                message: 'Approval requests from your adolescents will appear here',
                icon: Icons.check_circle_outline,
                color: theme.colorScheme.primary,
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Pending'),
                          if (state.pendingApprovals.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${state.pendingApprovals.length}',
                                style: TextStyle(
                                  color: theme.colorScheme.onError,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Tab(text: 'History'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPendingList(state.pendingApprovals, theme, ref),
                      _buildHistoryList(state.historyApprovals, theme),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
         loading: () => const _ApprovalsLoadingShimmer(),
        error: (err, stack) => Center(
          child: NeuroErrorWidget(
            message: 'Failed to load approval requests',
            onRetry: () => ref.read(guardianApprovalControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingList(List<GuardianApproval> approvals, ThemeData theme, WidgetRef ref) {
    if (approvals.isEmpty) {
      return Center(
        child: NeuroEmptyState(
          title: 'No Pending Requests',
          message: 'All approval requests have been reviewed',
          icon: Icons.done_all,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: approvals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final approval = approvals[index];
        return _ApprovalCard(approval: approval, isPending: true);
      },
    );
  }

  Widget _buildHistoryList(List<GuardianApproval> approvals, ThemeData theme) {
    if (approvals.isEmpty) {
      return Center(
        child: NeuroEmptyState(
          title: 'No History',
          message: 'Reviewed approval requests will appear here',
          icon: Icons.history,
          color: theme.colorScheme.primary,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: approvals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final approval = approvals[index];
        return _ApprovalCard(approval: approval, isPending: false);
      },
    );
  }
}

class _ApprovalCard extends ConsumerStatefulWidget {
  const _ApprovalCard({
    required this.approval,
    required this.isPending,
  });

  final GuardianApproval approval;
  final bool isPending;

  @override
  ConsumerState<_ApprovalCard> createState() => _ApprovalCardState();
}

class _ApprovalCardState extends ConsumerState<_ApprovalCard> {
  bool _isResponding = false;

  Future<void> _respond(bool approved) async {
    setState(() => _isResponding = true);

    final success = await ref
        .read(guardianApprovalControllerProvider.notifier)
        .respondToApproval(widget.approval.approvalId, approved, null);

    if (mounted) {
      setState(() => _isResponding = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approved ? 'Request approved' : 'Request denied'),
            backgroundColor: approved ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _revoke() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Approval'),
        content: const Text(
          'Are you sure you want to revoke this approval? The adolescent will no longer be able to communicate with this counselor, but can request approval again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isResponding = true);

    final success = await ref
        .read(guardianApprovalControllerProvider.notifier)
        .revokeApproval(widget.approval.approvalId, null);

    if (mounted) {
      setState(() => _isResponding = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Approval revoked successfully'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    widget.approval.adolescentName?[0].toUpperCase() ?? 'A',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.approval.adolescentName ?? 'Adolescent',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'wants to communicate with counselor',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!widget.isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.approval.status == 'approved'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.approval.status.toUpperCase(),
                      style: TextStyle(
                        color: widget.approval.status == 'approved' ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Counselor',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.approval.counselorName ?? widget.approval.counselorEmail,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.approval.requestReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.message,
                          size: 16,
                          color: theme.colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reason',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.approval.requestReason!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Requested ${_formatDate(widget.approval.createdAt)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isResponding ? null : () => _respond(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Deny'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _isResponding ? null : () => _respond(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (widget.approval.status == 'approved') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isResponding ? null : _revoke,
                  icon: const Icon(Icons.block),
                  label: const Text('Revoke Approval'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

   String _formatDate(DateTime date) {
     final now = DateTime.now();
     final diff = now.difference(date);

     if (diff.inDays > 0) {
       return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
     } else if (diff.inHours > 0) {
       return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
     } else if (diff.inMinutes > 0) {
       return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
     } else {
       return 'Just now';
     }
   }
 }

// ─── Shimmer Loading for Tab Body ─────────────────────────────────────────────
class _ApprovalsLoadingShimmer extends StatelessWidget {
  const _ApprovalsLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar placeholder (static shimmer bars)
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              // Pending tab placeholder
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SkeletonBox(width: 60, height: 16, borderRadius: 4),
                      const SizedBox(width: 8),
                      _SkeletonBox(width: 20, height: 18, borderRadius: 9),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // History tab placeholder
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _SkeletonBox(width: 70, height: 16, borderRadius: 4),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Shimmer list for both tabs
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) => const _ApprovalCardSkeleton(),
          ),
        ),
      ],
    );
   }
 }

class _ApprovalCardSkeleton extends StatelessWidget {
  const _ApprovalCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: avatar + name + status
            Row(
              children: [
                // Avatar skeleton
                NeuroShimmer(
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(width: 140, height: 18, borderRadius: 6),
                      const SizedBox(height: 6),
                      _SkeletonBox(width: 180, height: 14, borderRadius: 4),
                    ],
                  ),
                ),
                // Status badge skeleton
                _SkeletonBox(width: 70, height: 24, borderRadius: 12),
              ],
            ),

            const SizedBox(height: 16),

            // Counselor info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _SkeletonBox(width: 16, height: 16, borderRadius: 4),
                  const SizedBox(width: 8),
                  _SkeletonBox(width: 80, height: 14, borderRadius: 4),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Reason box (optional)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _SkeletonBox(width: 16, height: 16, borderRadius: 4),
                      const SizedBox(width: 8),
                      _SkeletonBox(width: 50, height: 12, borderRadius: 4),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _SkeletonBox(width: double.infinity, height: 12, borderRadius: 4),
                  _SkeletonBox(width: double.infinity, height: 12, borderRadius: 4),
                  _SkeletonBox(width: 200, height: 12, borderRadius: 4),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Date text
            _SkeletonBox(width: 120, height: 12, borderRadius: 4),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _SkeletonBox(
                    width: double.infinity,
                    height: 44,
                    borderRadius: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SkeletonBox(
                    width: double.infinity,
                    height: 44,
                    borderRadius: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width,
    this.height,
    this.borderRadius = 0,
  });

  final double? width, height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return NeuroShimmer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

