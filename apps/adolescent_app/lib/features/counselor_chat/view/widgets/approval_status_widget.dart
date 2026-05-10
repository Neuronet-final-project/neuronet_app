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
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool? _triggeredByAlert;
  Map<String, dynamic>? _alertContext;

  @override
  void initState() {
    super.initState();
    _checkApproval();
    // Poll for approval status changes every 5 seconds
    _startPolling();
  }

  void _startPolling() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _checkApproval();
        _startPolling();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
        
        // If pending, try to fetch alert context
        bool? triggeredByAlert;
        Map<String, dynamic>? alertContext;
        
        if (statusValue == 'pending') {
          // Try to get alert context from the approval
          try {
            // We would need the approval_id to fetch context
            // For now, we'll assume it might be alert-triggered if status is pending
            triggeredByAlert = null; // Will be determined by backend response
          } catch (e) {
            debugPrint('Error fetching alert context: $e');
          }
        }
        
        setState(() {
          _isApproved = isApproved;
          _status = statusValue;
          _isLoading = false;
          _retryCount = 0;
          _triggeredByAlert = triggeredByAlert;
          _alertContext = alertContext;
        });

        // Update the provider cache so the chat screen knows about the approval
        final cacheKey = '${widget.adolescentId}:${widget.counselorEmail}';
        ref.read(guardianApprovalControllerProvider.notifier).updateCache(cacheKey, isApproved);
      } else {
        // If API call fails, retry up to 3 times with exponential backoff
        if (_retryCount < _maxRetries) {
          _retryCount++;
          final delayMs = 1000 * _retryCount; // 1s, 2s, 3s
          await Future.delayed(Duration(milliseconds: delayMs));
          if (mounted) {
            _checkApproval();
          }
        } else {
          // After max retries, assume no approval (show request button)
          setState(() {
            _isApproved = false;
            _status = null;
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loading indicator while checking
    if (_isLoading) {
      final l10n = context.localizations;
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.checkingApprovalStatus,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() => _isLoading = true);
                _checkApproval();
              },
              tooltip: l10n.retry,
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
      return _PendingBanner(
        theme: theme,
        triggeredByAlert: _triggeredByAlert ?? false,
        alertContext: _alertContext,
      );
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
    await service.checkApprovalStatus(
      widget.adolescentId,
      widget.counselorEmail,
    );
    
    if (mounted) {
      setState(() => _isChecking = false);
      
      // If there's a pending request, the status might indicate it
      // For now, just proceed to the request screen
      widget.onRequestApproval();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
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
                  l10n.approvalRequired,
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
            l10n.needGuardianApprovalDesc,
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
              label: Text(_isChecking ? l10n.checking : l10n.requestApproval),
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
  const _PendingBanner({
    required this.theme,
    this.triggeredByAlert = false,
    this.alertContext,
  });

  final ThemeData theme;
  final bool triggeredByAlert;
  final Map<String, dynamic>? alertContext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final riskLevel = alertContext?['risk_level'] as String? ?? 'unknown';
    final riskScore = alertContext?['risk_score'] as num? ?? 0;
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                triggeredByAlert ? Icons.warning_amber_rounded : Icons.hourglass_empty_rounded,
                color: theme.colorScheme.tertiary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.approvalPending,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    if (triggeredByAlert)
                      Text(
                        l10n.alertTriggeredRequest,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (triggeredByAlert && alertContext != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aiAlertDetails,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        l10n.riskLevelLabel,
                        style: theme.textTheme.bodySmall,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRiskColor(riskLevel).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          riskLevel.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getRiskColor(riskLevel),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.riskScoreLabel(riskScore.toDouble()),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            Text(
              l10n.guardianReviewingMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onTertiaryContainer,
              ),
            ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}

class _ApprovedBanner extends StatelessWidget {
  const _ApprovedBanner({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
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
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.approvedByGuardian,
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
    final l10n = context.localizations;
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
              const Icon(
                Icons.block_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.approvalRevoked,
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
            l10n.guardianRevokedApprovalDesc,
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
              label: Text(l10n.requestApprovalAgain),
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
    final l10n = context.localizations;
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
                  l10n.requestDenied,
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
            l10n.guardianDeniedRequestDesc,
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
              label: Text(l10n.requestAgain),
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
