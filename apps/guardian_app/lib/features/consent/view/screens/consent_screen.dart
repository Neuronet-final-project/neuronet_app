import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/consent_provider.dart';

class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentsAsync = ref.watch(guardianConsentControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Consents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(guardianConsentControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          _buildInfoSection(),
          consentsAsync.when(
            data: (consents) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final consent = consents[index];
                  return _buildConsentTile(context, ref, consent);
                },
                childCount: consents.length,
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(child: Text('Error loading consents: $err')),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guardian Oversight Controls',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: NeuroColors.onSurface,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Manage which aspects of the adolescent\'s data and interactions you wish to monitor or authorize. These settings help maintain a balance between support and independence.',
              style: TextStyle(
                fontSize: 14,
                color: NeuroColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentTile(BuildContext context, WidgetRef ref, Consent consent) {
    final isGranted = consent.consentStatus == ConsentStatus.granted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: NeuroColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted 
              ? NeuroColors.adolescentPrimary.withValues(alpha: 0.3) 
              : NeuroColors.onSurfaceVariant.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SwitchListTile(
          value: isGranted,
          onChanged: (value) async {
            final newStatus = value ? ConsentStatus.granted : ConsentStatus.revoked;
            await ref.read(guardianConsentControllerProvider.notifier).updateConsent(
                  consent.consentId,
                  newStatus,
                );
            
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${consent.consentType.label} ${value ? 'granted' : 'revoked'} successfully',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          title: Text(
            consent.consentType.label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              consent.consentType.description,
              style: const TextStyle(
                fontSize: 12,
                color: NeuroColors.onSurfaceVariant,
              ),
            ),
          ),
          activeThumbColor: NeuroColors.adolescentPrimary,
          activeTrackColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
