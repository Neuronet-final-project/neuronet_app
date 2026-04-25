import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/guardian_approval_provider.dart';

class ApprovalStatusWidget extends ConsumerStatefulWidget {
  const ApprovalStatusWidget({
    super.key,
    required this.adolescentId,
    required this.counselorEmail,
    required this.onRequestApproval,
  });

  final String adolescentId;
  final String counselorEmail;
  final VoidCallback onRequestApproval;

  @override
  ConsumerState<ApprovalStatusWidget> createState() => _ApprovalStatusWidgetState();
}

class _ApprovalStatusWidgetState extends ConsumerState<ApprovalStatusWidget> {
  bool? _isApproved;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApproval();
  }

  Future<void> _checkApproval() async {
    final isApproved = await ref
        .read(guardianApprovalControllerProvider.notifier)
        .checkApproval(widget.adolescentId, widget.counselorEmail);
    
    if (mounted) {
      setState(() {
        _isApproved = isApproved;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_isApproved == true) {
      return _ApprovedBanner(theme: theme);
    }

    // Check if there's a pending request
    final approvalState = ref.watch(guardianApprovalControllerProvider);
    final hasPendingRequest = approvalState.value?.pendingRequests.any(
      (req) => req.counselorEmail == widget.counselorEmail && req.status == 'pending',
    ) ?? false;

    if (hasPendingRequest) {
      return _PendingBanner(theme: theme);
    }

    // Check if denied
    final hasDeniedRequest = approvalState.value?.historyRequests.any(
      (req) => req.counselorEmail == widget.counselorEmail && req.status == 'denied',
    ) ?? false;

    if (hasDeniedRequest) {
      return _DeniedBanner(
        onRequestApproval: widget.onRequestApproval,
        theme: theme,
      );
    }

    // Not requested
    return _NotRequestedBanner(
      onRequestApproval: widget.onRequestApproval,
      theme: theme,
    );
  }
}

class _NotRequestedBanner extends StatelessWidget {
  const _NotRequestedBanner({
    required this.onRequestApproval,
    required this.theme,
  });

  final VoidCallback onRequestApproval;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Approval Required',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You need guardian approval to communicate with this counselor. '
            'Request approval to start chatting.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRequestApproval,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Request Approval'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: theme.colorScheme.tertiary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Approval Pending',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your guardian is reviewing your request. You\'ll be notified once they respond.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovedBanner extends StatelessWidget {
  const _ApprovedBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Approved by guardian',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeniedBanner extends StatelessWidget {
  const _DeniedBanner({
    required this.onRequestApproval,
    required this.theme,
  });

  final VoidCallback onRequestApproval;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.cancel_outlined,
                color: theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Request Denied',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your guardian has denied this request. You can submit a new request with more details.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRequestApproval,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Request Again'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
