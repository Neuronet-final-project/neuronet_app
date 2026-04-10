import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/consent_status_provider.dart';

class ConsentStatusScreen extends ConsumerWidget {
  const ConsentStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentAsync = ref.watch(adolescentConsentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Status', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: consentAsync.when(
        data: (state) => _buildContent(context, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => NeuroErrorWidget(
          message: 'Could not load consent settings.',
          onRetry: () => ref.refresh(adolescentConsentControllerProvider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ConsentStatusState state) {
    final items = [
      _ConsentItem(
        icon: Icons.psychology_outlined,
        title: 'AI Summaries & Risk Levels',
        description: 'Allow your guardian and counselor to view AI-generated emotional summaries and risk assessments.',
        status: state.shareAiSummaries ? ConsentStatus.granted : ConsentStatus.revoked,
      ),
      _ConsentItem(
        icon: Icons.notifications_outlined,
        title: 'Alerts & Notifications',
        description: 'Allow your guardian to receive notifications when concerning emotional patterns are detected.',
        status: state.shareAlerts ? ConsentStatus.granted : ConsentStatus.revoked,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These are the current consent settings set by your guardian. You can always ask your guardian to change them.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Consent Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.status == ConsentStatus.granted
                          ? NeuroColors.alertLow.withValues(alpha: 0.15)
                          : NeuroColors.alertMedium.withValues(alpha: 0.15),
                      child: Icon(
                        item.icon,
                        color: item.status == ConsentStatus.granted ? NeuroColors.alertLow : NeuroColors.alertMedium,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.description,
                        style: TextStyle(
                          color: NeuroColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    trailing: Chip(
                      label: Text(
                        item.status == ConsentStatus.granted ? 'Granted' : 'Revoked',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: item.status == ConsentStatus.granted
                              ? NeuroColors.alertLow
                              : NeuroColors.alertMedium,
                        ),
                      ),
                      backgroundColor: item.status == ConsentStatus.granted
                          ? NeuroColors.alertLow.withValues(alpha: 0.1)
                          : NeuroColors.alertMedium.withValues(alpha: 0.1),
                      side: BorderSide(
                        color: item.status == ConsentStatus.granted
                            ? NeuroColors.alertLow.withValues(alpha: 0.3)
                            : NeuroColors.alertMedium.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _ConsentItem {
  final IconData icon;
  final String title;
  final String description;
  final ConsentStatus status;

  const _ConsentItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
  });
}
