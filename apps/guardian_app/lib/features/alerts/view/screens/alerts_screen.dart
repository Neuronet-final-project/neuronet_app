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
  AlertActionStatus? _filterStatus;

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
          ),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) {
          final filteredAlerts = _filterStatus == null
              ? alerts
              : alerts.where((a) => a.actionStatus == _filterStatus).toList();

          if (filteredAlerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 64, color: NeuroColors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    _filterStatus == null 
                        ? 'No alerts yet' 
                        : 'No alerts with status: ${_filterStatus!.name}',
                    style: const TextStyle(color: NeuroColors.onSurfaceVariant),
                  ),
                  if (_filterStatus != null)
                    TextButton(
                      onPressed: () => setState(() => _filterStatus = null),
                      child: const Text('Clear Filter'),
                    ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredAlerts.length,
            itemBuilder: (context, index) {
              final alert = filteredAlerts[index];
              return NeuroAlertCard(
                alert: alert,
                onTap: () => context.push('/alert-details/${alert.alertId}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AlertActionStatus?>(
              title: const Text('All'),
              value: null,
              groupValue: _filterStatus,
              onChanged: (value) {
                setState(() => _filterStatus = value);
                Navigator.pop(context);
              },
            ),
            ...AlertActionStatus.values.map((status) => RadioListTile<AlertActionStatus?>(
                  title: Text(status.name.toUpperCase()),
                  value: status,
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() => _filterStatus = value);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}
