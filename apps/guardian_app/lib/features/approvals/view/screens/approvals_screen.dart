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
        title: Text(context.localizations.approvalRequests),
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
                title: context.localizations.noApprovalRequests,
                message: context.localizations.noApprovalRequestsDesc,
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
                          Text(context.localizations.pending),
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
                    Tab(text: context.localizations.history),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildPendingList(context, state.pendingApprovals, theme, ref),
                      _buildHistoryList(context, state.historyApprovals, theme),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: NeuroErrorWidget(
            message: context.localizations.failedToLoadApprovals,
            onRetry: () => ref.read(guardianApprovalControllerProvider.notifier).refresh(),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingList(BuildContext context, List<GuardianApproval> approvals, ThemeData theme, WidgetRef ref) {
    if (approvals.isEmpty) {
      return Center(
        child: NeuroEmptyState(
          title: context.localizations.noPendingRequests,
          message: context.localizations.noPendingRequestsDesc,
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

  Widget _buildHistoryList(BuildContext context, List<GuardianApproval> approvals, ThemeData theme) {
    if (approvals.isEmpty) {
      return Center(
        child: NeuroEmptyState(
          title: context.localizations.noHistory,
          message: context.localizations.noHistoryDesc,
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
        title: Text(context.localizations.revokeApproval),
        content: Text(context.localizations.revokeApprovalDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.localizations.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(context.localizations.revoke),
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
                        widget.approval.adolescentName ?? context.localizations.adolescent,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        context.localizations.wantsToCommunicate,
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
                        context.localizations.counselorLabel,
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
                          context.localizations.reasonLabel,
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
              context.localizations.requestedDateLabel(_formatDate(context, widget.approval.createdAt)),
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
                      label: Text(context.localizations.deny),
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
                      label: Text(context.localizations.approve),
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
                  label: Text(context.localizations.revokeApproval),
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

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return context.localizations.daysAgo(diff.inDays);
    } else if (diff.inHours > 0) {
      return context.localizations.hoursAgo(diff.inHours);
    } else if (diff.inMinutes > 0) {
      return context.localizations.minutesAgo(diff.inMinutes);
    } else {
      return context.localizations.justNow;
    }
  }
}
