import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
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
  String? _status; // 'pending', 'approved', 'denied', 'revoked', 'expired', null
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApproval();
  }

  Future<void> _checkApproval() async {
    // Check approval status which includes pending state
    final service = ref.read(guardianApprovalServiceProvider);
    final statusResult = await service.checkApprovalStatus(
      widget.adolescentId,
      widget.counselorEmail,
    );
    
    if (mounted) {
      if (statusResult.isSuccess) {
        final status = statusResult.value;
        final isApproved = status.isApproved;
        final statusValue = status.status;
        
        setState(() {
          _isApproved = isApproved;
          _status = statusValue;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isApproved = false;
          _status = null;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loading indicator while checking
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Checking approval status...',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Show approved banner
    if (_isApproved == true && _status == 'approved') {
      return _ApprovedBanner(theme: theme);
    }

    // Show pending banner - no request button
    if (_status == 'pending') {
      return _PendingBanner(theme: theme);
    }

    // Show denied banner
    if (_status == 'denied') {
      return _DeniedBanner(
        onRequestApproval: widget.onRequestApproval,
        theme: theme,
      );
    }

    // Show revoked banner
    if (_status == 'revoked') {
      return _RevokedBanner(
        onRequestApproval: widget.onRequestApproval,
        theme: theme,
      );
    }

    // Not approved and not pending - show request banner
    return _NotRequestedBanner(
      onRequestApproval: widget.onRequestApproval,
      theme: theme,
      adolescentId: widget.adolescentId,
      counselorEmail: widget.counselorEmail,
    );
  }
}

class _NotRequestedBanner extends ConsumerStatefulWidget {
  const _NotRequestedBanner({
    super.key,
    required this.onRequestApproval,
    required this.theme,
    required this.adolescentId,
    required this.counselorEmail,
  });

  final VoidCallback onRequestApproval;
  final ThemeData theme;
  final String adolescentId;
  final String counselorEmail;

  @override
  ConsumerState<_NotRequestedBanner> createState() => _NotRequestedBannerState();
}

class _NotRequestedBannerState extends ConsumerState<_NotRequestedBanner> {
  bool _isChecking = false;

  Future<void> _handleRequestApproval() async {
    setState(() => _isChecking = true);
    
    // Check if there's already a pending request
    final service = ref.read(guardianApprovalServiceProvider);
    final statusResult = await service.checkApprovalStatus(
      widget.adolescentId,
      widget.counselorEmail,
    );
    
    if (mounted) {
      setState(() => _isChecking = false);
      
      if (statusResult.isSuccess) {
        final status = statusResult.value;
        // If there's a pending request, the status might indicate it
        // For now, just proceed to the request screen
        widget.onRequestApproval();
      } else {
        // Error checking status, proceed anyway
        widget.onRequestApproval();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.theme.colorScheme.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.theme.colorScheme.error.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: widget.theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Approval Required',
                  style: widget.theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: widget.theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You need guardian approval to communicate with this counselor. '
            'Request approval to start chatting.',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isChecking ? null : _handleRequestApproval,
              icon: _isChecking 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_rounded),
              label: Text(_isChecking ? 'Checking...' : 'Request Approval'),
              style: FilledButton.styleFrom(
                backgroundColor: widget.theme.colorScheme.error,
                foregroundColor: widget.theme.colorScheme.onError,
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

class _RevokedBanner extends StatelessWidget {
  const _RevokedBanner({
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
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.block_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Approval Revoked',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your guardian has revoked approval for this counselor. You can request approval again to continue chatting.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade900,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRequestApproval,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Request Approval Again'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
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
