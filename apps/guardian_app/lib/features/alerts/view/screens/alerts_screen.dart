import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../ui/bento_card.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String? _filterSeverity;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(guardianAlertsControllerProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF9FAFB),
            surfaceTintColor: const Color(0xFFF9FAFB),
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Security Alerts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilterDialog,
                tooltip: 'Filter alerts',
              ),
            ],
          ),
          alertsAsync.when(
            data: (state) {
              if (state.isLoading && state.alerts.isEmpty) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: NeuroSkeletonCard(),
                    ),
                    childCount: 4,
                  ),
                );
              }

              if (state.error != null && state.alerts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NeuroErrorWidget(
                        message: 'Error: ${state.error}',
                        onRetry: () => ref.read(guardianAlertsControllerProvider.notifier).refresh(),
                      ),
                    ),
                  ),
                );
              }

              final alerts = state.alerts;
              final filteredAlerts = _filterSeverity == null
                  ? alerts
                  : alerts.where((a) => a.severityLevel.toLowerCase() == _filterSeverity!.toLowerCase()).toList();

              if (filteredAlerts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NeuroEmptyState(
                        title: _filterSeverity == null ? 'No alerts yet' : 'No alerts found',
                        message: _filterSeverity == null 
                            ? 'We will notify you if any concerning patterns appear.'
                            : 'No alerts match the "$_filterSeverity" severity filter.',
                        icon: Icons.notifications_off_outlined,
                        color: NeuroColors.onSurfaceVariant,
                        actionLabel: _filterSeverity != null ? 'Clear Filter' : null,
                        onActionPressed: _filterSeverity != null ? () => setState(() => _filterSeverity = null) : null,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final alert = filteredAlerts[index];
                      return _AlertCard(alert: alert);
                    },
                    childCount: filteredAlerts.length,
                  ),
                ),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: NeuroSkeletonCard(),
                ),
                childCount: 4,
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: NeuroErrorWidget(
                    message: 'Failed to load alerts.',
                    onRetry: () => ref.read(guardianAlertsControllerProvider.notifier).refresh(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Severity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ignore: deprecated_member_use
            ListTile(
              title: const Text('All'),
              leading: Radio<String?>(
                value: null,
                // ignore: deprecated_member_use
                groupValue: _filterSeverity,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() => _filterSeverity = value);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                setState(() => _filterSeverity = null);
                Navigator.pop(context);
              },
            ),
            ...['Low', 'Medium', 'High'].map((s) => ListTile(
                  title: Text(s),
                  leading: Radio<String?>(
                    value: s,
                    // ignore: deprecated_member_use
                    groupValue: _filterSeverity,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      setState(() => _filterSeverity = value);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    setState(() => _filterSeverity = s);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(alert.severityLevel);

    return GuardianBentoCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: () => context.push('/alert-details/${alert.alertId}'),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${alert.severityLevel.toUpperCase()} RISK',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(alert.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: NeuroColors.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.adolescentName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.mainConcern.isEmpty ? alert.alertType.replaceAll('_', ' ').toUpperCase() : alert.mainConcern,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Text(
            alert.aiSummary.isNotEmpty ? alert.aiSummary : alert.triggerDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: NeuroColors.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
          ),

          if (alert.detectedEmotions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: alert.detectedEmotions.take(4).map((emotion) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NeuroColors.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    emotion,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: NeuroColors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('high')) return NeuroColors.alertHigh;
    if (s.contains('medium')) return NeuroColors.alertMedium;
    return NeuroColors.alertLow;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
