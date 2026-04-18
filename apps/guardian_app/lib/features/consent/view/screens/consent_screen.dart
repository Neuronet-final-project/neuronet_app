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
      backgroundColor: NeuroColors.background,
      appBar: AppBar(
        title: const Text('Privacy & Oversight'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(guardianConsentControllerProvider.notifier).refresh(),
            tooltip: 'Refresh settings',
          ),
        ],
      ),
      body: consentsAsync.when(
        data: (state) {
          if (state.isLoading && state.consents.isEmpty) {
            return _buildLoadingState();
          }

          if (state.error != null && state.consents.isEmpty) {
            return _buildErrorState(ref, state.error!);
          }

          final consents = state.consents;
          if (consents.isEmpty) {
            return _buildEmptyState();
          }

          // Group consents by adolescent email
          final grouped = <String, List<Consent>>{};
          for (final c in consents) {
            grouped.putIfAbsent(c.adolescentId, () => []).add(c);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              _buildHeader(),
              ...grouped.entries.map((entry) => _buildAdolescentGroup(context, ref, entry.key, entry.value)),
              const SizedBox(height: 40),
            ],
          );
        },
        loading: () => _buildLoadingState(),
        error: (err, stack) => _buildErrorState(ref, 'Failed to load settings'),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security & Consent Hub',
            style: NeuroStyles.h2.copyWith(color: NeuroColors.guardianPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure how Neuronet supports your adolescent. Balance their journey toward independence with the oversight needed for a safe environment.',
            style: NeuroStyles.bodyMedium.copyWith(color: NeuroColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildAdolescentGroup(BuildContext context, WidgetRef ref, String email, List<Consent> adolescentConsents) {
    // Find specific consents
    final participation = adolescentConsents.firstWhere((c) => c.consentType == ConsentType.participation);
    final aiSummaries = adolescentConsents.firstWhere((c) => c.consentType == ConsentType.shareAiSummaries);
    final alerts = adolescentConsents.firstWhere((c) => c.consentType == ConsentType.shareAlerts);
    final counselorChat = adolescentConsents.firstWhere((c) => c.consentType == ConsentType.counselorChat);

    final isParticipationGranted = participation.consentStatus == ConsentStatus.granted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
          child: Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 20, color: NeuroColors.guardianPrimary),
              const SizedBox(width: 8),
              Text(
                'Settings for $email',
                style: NeuroStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: NeuroColors.onSurface,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        
        // AI Participation Section (The Master Control)
        _buildSectionCard(
          title: 'AI Analysis & Participation',
          subtitle: 'Core data processing controls',
          statusIcon: Icons.psychology_outlined,
          children: [
            _buildConsentSwitch(
              context, 
              ref, 
              participation,
              isMaster: true,
            ),
            if (isParticipationGranted) ...[
              const Divider(indent: 72, endIndent: 20, height: 1),
              _buildConsentSwitch(
                context, 
                ref, 
                aiSummaries,
                iconPath: Icons.summarize_outlined,
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Safety & Communication Section
        _buildSectionCard(
          title: 'Safety & Communication',
          subtitle: 'Alerts and external interactions',
          statusIcon: Icons.security_outlined,
          children: [
            _buildConsentSwitch(
              context, 
              ref, 
              alerts,
              iconPath: Icons.notifications_active_outlined,
            ),
            const Divider(indent: 72, endIndent: 20, height: 1),
            _buildConsentSwitch(
              context, 
              ref, 
              counselorChat,
              iconPath: Icons.chat_bubble_outline_rounded,
            ),
          ],
        ),
        
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: NeuroColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: NeuroColors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(statusIcon, color: NeuroColors.guardianPrimary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: NeuroStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      Text(subtitle, style: NeuroStyles.bodySmall.copyWith(color: NeuroColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildConsentSwitch(
    BuildContext context, 
    WidgetRef ref, 
    Consent consent, {
    bool isMaster = false,
    IconData? iconPath,
  }) {
    final isGranted = consent.consentStatus == ConsentStatus.granted;

    return SwitchListTile.adaptive(
      value: isGranted,
      onChanged: (value) async {
        final newStatus = value ? ConsentStatus.granted : ConsentStatus.revoked;
        try {
          await ref.read(guardianConsentControllerProvider.notifier).updateConsent(
            consent,
            newStatus,
          );
          
          if (context.mounted) {
            NeuroToast.show(
              context,
              '${consent.consentType.label} updated',
              type: value ? NeuroToastType.success : NeuroToastType.info,
            );
          }
        } catch (e) {
          if (context.mounted) {
            NeuroToast.show(context, 'Update failed: $e', type: NeuroToastType.error);
          }
        }
      },
      title: Text(
        consent.consentType.label,
        style: NeuroStyles.bodyLarge.copyWith(
          fontWeight: isMaster ? FontWeight.bold : FontWeight.w500,
          color: isMaster ? NeuroColors.onSurface : NeuroColors.onSurface.withValues(alpha: 0.8),
        ),
      ),
      subtitle: Text(
        consent.consentType.description,
        style: NeuroStyles.bodySmall.copyWith(color: NeuroColors.onSurfaceVariant),
      ),
      secondary: iconPath != null 
        ? Icon(iconPath, color: isGranted ? NeuroColors.guardianPrimary : NeuroColors.onSurfaceVariant, size: 24)
        : null,
      activeColor: NeuroColors.guardianPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: NeuroSkeletonCard(height: 120),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String message) {
    return Center(
      child: NeuroErrorWidget(
        message: message,
        onRetry: () => ref.read(guardianConsentControllerProvider.notifier).refresh(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: NeuroEmptyState(
        title: 'No Linked Accounts',
        message: 'Consent management will appear once an adolescent account is linked.',
        icon: Icons.link_off_rounded,
      ),
    );
  }
}

