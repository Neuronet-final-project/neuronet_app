import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../dashboard/providers/dashboard_provider.dart';

class AlertDetailsScreen extends ConsumerStatefulWidget {
  final String alertId;

  const AlertDetailsScreen({
    super.key,
    required this.alertId,
  });

  @override
  ConsumerState<AlertDetailsScreen> createState() => _AlertDetailsScreenState();
}

class _AlertDetailsScreenState extends ConsumerState<AlertDetailsScreen> {
  final _notesController = TextEditingController();
  AlertActionStatus? _selectedStatus;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(guardianAlertsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
      ),
      body: alertsAsync.when(
        data: (alerts) {
          final alert = alerts.firstWhere(
            (a) => a.alertId == widget.alertId,
            orElse: () => throw Exception('Alert not found'),
          );

          // Initialize local state if needed
          _selectedStatus ??= alert.actionStatus;
          if (_notesController.text.isEmpty && alert.actionNotes != null) {
            _notesController.text = alert.actionNotes!;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(alert),
                const SizedBox(height: 24),
                _buildDescription(alert),
                const SizedBox(height: 24),
                _buildStatusSelection(),
                const SizedBox(height: 24),
                _buildNotesField(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _updateStatus(alert),
                  child: const Text('Update Alert Status'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeader(Alert alert) {
    final color = switch (alert.severityLevel) {
      AlertSeverity.low => NeuroColors.alertLow,
      AlertSeverity.medium => NeuroColors.alertMedium,
      AlertSeverity.high => NeuroColors.alertHigh,
    };

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Text(
            alert.severityLevel.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const Spacer(),
        Text(
          'Triggered: ${alert.createdAt.toString().split('.')[0]}',
          style: const TextStyle(
            color: NeuroColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Alert alert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          alert.alertType.name.replaceAll('Pattern', ' Pattern').toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: NeuroColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          alert.triggerDescription,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: NeuroColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Action Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AlertActionStatus.values.map((status) {
            final isSelected = _selectedStatus == status;
            return ChoiceChip(
              label: Text(status.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedStatus = status);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Decision Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Enter any observations or actions taken...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  void _updateStatus(Alert alert) {
    if (_selectedStatus != null) {
      ref.read(guardianAlertsControllerProvider.notifier).updateAlertStatus(
            alert.alertId,
            _selectedStatus!,
            notes: _notesController.text,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert updated successfully')),
      );
      Navigator.of(context).pop();
    }
  }
}
