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
        data: (alerts) {
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(alert.alertType, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(alert.triggerDescription),
                  leading: CircleAvatar(
                    backgroundColor: _getSeverityColor(alert.severityLevel).withValues(alpha: 0.1),
                    child: Icon(Icons.warning, color: _getSeverityColor(alert.severityLevel)),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('/alert-details/${alert.alertId}'),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('high')) return NeuroColors.alertHigh;
    if (s.contains('medium')) return NeuroColors.alertMedium;
    return NeuroColors.alertLow;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Severity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              leading: Radio<String?>(
                value: null,
                groupValue: _filterSeverity,
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
                    groupValue: _filterSeverity,
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
