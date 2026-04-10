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
            onPressed: () =>
                ref.read(guardianConsentControllerProvider.notifier).refresh(),
            tooltip: 'Refresh consents',
          ),
        ],
      ),
      body: consentsAsync.when(
        data: (consents) {
          if (consents.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: NeuroEmptyState(
                  title: 'No Consents to Manage',
                  message: 'Register an adolescent first to manage consent settings.',
                  icon: Icons.verified_user_outlined,
                  color: NeuroColors.guardianPrimary,
                ),
              ),
            );
          }

          // Group consents by adolescent email
          final grouped = <String, List<Consent>>{};
          for (final c in consents) {
            grouped.putIfAbsent(c.adolescentId, () => []).add(c);
          }

          return CustomScrollView(
            slivers: [
              _buildInfoSection(),
              ...grouped.entries.expand((entry) => [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                        child: Text(
                          'Controls for ${entry.key}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: NeuroColors.guardianPrimary,
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _buildConsentTile(
                              context, ref, entry.value[index]);
                        },
                        childCount: entry.value.length,
                      ),
                    ),
                  ]),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
        loading: () => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const NeuroSkeletonCard(),
                childCount: 3,
              ),
            ),
          ],
        ),
        error: (err, stack) => Center(child: Text('Error loading consents: $err')),
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
              ? NeuroColors.guardianPrimary.withValues(alpha: 0.3) 
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
            try {
              await ref.read(guardianConsentControllerProvider.notifier).updateConsent(
                consent,
                newStatus,
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${consent.consentType.label} ${value ? 'granted' : 'revoked'} successfully',
                    ),
                    backgroundColor: NeuroColors.alertLow,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update ${consent.consentType.label}: $e'),
                    backgroundColor: NeuroColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
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
          activeThumbColor: NeuroColors.guardianPrimary,
          activeTrackColor: NeuroColors.guardianPrimary.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
