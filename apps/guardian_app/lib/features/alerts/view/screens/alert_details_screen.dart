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
        data: (state) {
          if (state.isLoading && state.alerts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
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

          final alert = state.alerts.where((a) => a.alertId == widget.alertId).firstOrNull;
          if (alert == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: NeuroEmptyState(
                  title: 'Alert Not Found',
                  message: 'This alert may have been resolved or deleted.',
                  icon: Icons.warning_amber_outlined,
                  color: NeuroColors.onSurfaceVariant,
                ),
              ),
            );
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
                _buildNotesField(),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => _resolveAlert(alert),
                  child: const Text('Resolve Alert'),
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
    final color = switch (alert.severityLevel.toLowerCase()) {
      'high' => NeuroColors.alertHigh,
      'medium' => NeuroColors.alertMedium,
      _ => NeuroColors.alertLow,
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
            alert.severityLevel.toUpperCase(),
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
          alert.alertType.replaceAll('_', ' ').toUpperCase(),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: NeuroColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adolescent: ${alert.adolescentName}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: NeuroColors.onSurface,
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

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resolution Notes (Optional)',
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

  Future<void> _resolveAlert(Alert alert) async {
    try {
      final notifier = ref.read(guardianAlertsControllerProvider.notifier);
      await notifier.resolveAlert(
        alert.alertId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert resolved successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resolve alert: $e')),
        );
      }
    }
  }
}
