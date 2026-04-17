import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

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
      appBar: AppBar(
        title: const Text('Alert History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter alerts',
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (state) {
          if (state.isLoading && state.alerts.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 4,
              itemBuilder: (context, index) => const NeuroSkeletonCard(),
            );
          }

          if (state.error != null && state.alerts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: NeuroErrorWidget(
                  message: 'Error: ${state.error}',
                  onRetry: () => ref.read(guardianAlertsControllerProvider.notifier).refresh(),
                ),
              ),
            );
          }

          final alerts = state.alerts;
          final filteredAlerts = _filterSeverity == null
              ? alerts
              : alerts.where((a) => a.severityLevel.toLowerCase() == _filterSeverity!.toLowerCase()).toList();

          if (filteredAlerts.isEmpty) {
            return Center(
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredAlerts.length,
            itemBuilder: (context, index) {
              final alert = filteredAlerts[index];
              return _AlertCard(alert: alert);
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 4,
          itemBuilder: (context, index) => const NeuroSkeletonCard(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: NeuroErrorWidget(
              message: 'Failed to load alerts.',
              onRetry: () => ref.read(guardianAlertsControllerProvider.notifier).refresh(),
            ),
          ),
        ),
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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/alert-details/${alert.alertId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Severity badge + date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${alert.severityLevel.toUpperCase()} RISK',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(alert.createdAt),
                    style: const TextStyle(fontSize: 12, color: NeuroColors.onSurfaceVariant),
                  ),
                ],
              ),

              // Main concern badge
              if (alert.mainConcern.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: NeuroColors.onSurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert.mainConcern,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],

              // AI Summary
              if (alert.aiSummary.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  alert.aiSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  alert.triggerDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],

              // Emotion chips
              if (alert.detectedEmotions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: alert.detectedEmotions.take(4).map((emotion) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: color.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        emotion,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: color.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // View details
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.arrow_forward_ios, size: 14, color: color.withValues(alpha: 0.5)),
                ],
              ),
            ],
          ),
        ),
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
