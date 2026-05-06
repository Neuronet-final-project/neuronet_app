import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/consent_status_provider.dart';

class ConsentStatusScreen extends ConsumerWidget {
  const ConsentStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentAsync = ref.watch(adolescentConsentControllerProvider);
    final l10n = context.localizations;

    return Scaffold(
      backgroundColor: NeuroColors.background,
      appBar: AppBar(
        title: Text(
          l10n.privacyHubTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: NeuroColors.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: NeuroColors.onSurface,
        iconTheme: const IconThemeData(color: NeuroColors.onSurface),
      ),
      body: consentAsync.when(
        data: (state) => _buildContent(context, state),
        loading: () => const _ConsentStatusSkeletonLoading(),
        error: (err, stack) => NeuroErrorWidget(
          message: l10n.couldNotLoadPrivacy,
          onRetry: () => ref.refresh(adolescentConsentControllerProvider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ConsentStatusState state) {
    final l10n = context.localizations;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrivacyStatusHeader(context),
          const SizedBox(height: 32),

          Text(
            l10n.coreTransparency,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // AI Analysis Section
          _buildPrivacyCard(
            context,
            title: l10n.generalParticipation,
            description: l10n.generalParticipationDesc,
            isGranted: state.participation,
            icon: Icons.psychology_rounded,
          ),

          const SizedBox(height: 24),
          Text(
            l10n.sharingVisibility,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Sub-sharing controls
          _buildPrivacyCard(
            context,
            title: l10n.aiInsightsSummaries,
            description: l10n.aiInsightsSummariesDesc,
            isGranted: state.shareAiSummaries && state.participation,
            icon: Icons.summarize_rounded,
            isDisabled: !state.participation,
            warning: !state.participation ? l10n.participationPausedNote : null,
          ),
          
          const SizedBox(height: 16),
          _buildPrivacyCard(
            context,
            title: l10n.safetyAlerts,
            description: l10n.safetyAlertsDesc,
            isGranted: state.shareAlerts && state.participation,
            icon: Icons.notifications_active_rounded,
            isDisabled: !state.participation,
          ),

          const SizedBox(height: 24),
          Text(
            l10n.interactionControls,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildPrivacyCard(
            context,
            title: l10n.counselorConnection,
            description: l10n.counselorConnectionDesc,
            isGranted: state.counselorChat,
            icon: Icons.forum_rounded,
          ),
          
          const SizedBox(height: 32),
          _buildPrivacyEducation(context),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildPrivacyStatusHeader(BuildContext context) {
    final l10n = context.localizations;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NeuroColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [NeuroShadows.lg],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: NeuroColors.adolescentPrimary,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.yourPrivacyMatters,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.transparencyNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: NeuroColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard(
    BuildContext context, {
    required String title,
    required String description,
    required bool isGranted,
    required IconData icon,
    bool isDisabled = false,
    String? warning,
  }) {
    final l10n = context.localizations;
    final statusColor = isDisabled 
      ? NeuroColors.onSurfaceVariant.withValues(alpha: 0.5)
      : (isGranted ? NeuroColors.alertLow : NeuroColors.alertHigh);
      
    final statusText = isDisabled ? l10n.paused : (isGranted ? l10n.granted : l10n.revoked);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeuroColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isGranted && !isDisabled 
            ? NeuroColors.alertLow.withValues(alpha: 0.2) 
            : NeuroColors.outline,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: statusColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              _buildStatusIndicator(context, statusText, statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NeuroColors.onSurfaceVariant, height: 1.4),
          ),
          if (warning != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: NeuroColors.alertMedium.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 14, color: NeuroColors.alertMedium),
                  const SizedBox(width: 6),
                  Text(
                    warning,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: NeuroColors.alertMedium, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPrivacyEducation(BuildContext context) {
    final l10n = context.localizations;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NeuroColors.adolescentPrimary.withValues(alpha: 0.05),
            NeuroColors.adolescentPrimaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_center_outlined, color: NeuroColors.adolescentPrimary),
              const SizedBox(width: 12),
              Text(
                l10n.understandingPrivacy,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEducationItem(context, l10n.privacyEducation1),
          _buildEducationItem(context, l10n.privacyEducation2),
          _buildEducationItem(context, l10n.privacyEducation3),
        ],
      ),
    );
  }

  Widget _buildEducationItem(BuildContext context, String text) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 12),
       child: Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
           Expanded(
             child: Text(
               text,
               style: Theme.of(context).textTheme.bodySmall?.copyWith(color: NeuroColors.onSurfaceVariant),
             ),
           ),
         ],
       ),
     );
   }
}

const _kSkeletonGrey = Color(0xFFE5E7EB);

class _ConsentStatusSkeletonLoading extends StatelessWidget {
  const _ConsentStatusSkeletonLoading();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ConsentStatusSkeletonHero(),
          const SizedBox(height: 32),
          Text(
            'Core Transparency',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const _ConsentStatusSkeletonCard(),
          const SizedBox(height: 24),
          Text(
            'Sharing & Visibility',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const _ConsentStatusSkeletonCard(),
          const SizedBox(height: 16),
          const _ConsentStatusSkeletonCard(isDisabled: true),
          const SizedBox(height: 24),
          Text(
            'Interaction Controls',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const _ConsentStatusSkeletonCard(),
          const SizedBox(height: 32),
          const _ConsentStatusSkeletonEducation(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _ConsentStatusSkeletonHero extends StatelessWidget {
  const _ConsentStatusSkeletonHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NeuroColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [NeuroShadows.lg],
      ),
      child: Column(
        children: [
          NeuroShimmer(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kSkeletonGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_rounded, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          NeuroShimmer(
            child: Container(
              width: 220,
              height: 24,
              decoration: BoxDecoration(
                color: _kSkeletonGrey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          NeuroShimmer(
            child: Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: _kSkeletonGrey.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentStatusSkeletonCard extends StatelessWidget {
  final bool isDisabled;
  const _ConsentStatusSkeletonCard({this.isDisabled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeuroColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _kSkeletonGrey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeuroShimmer(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _kSkeletonGrey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeuroShimmer(
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: _kSkeletonGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              NeuroShimmer(
                child: Container(
                  width: 64,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _kSkeletonGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          NeuroShimmer(
            child: Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: _kSkeletonGrey.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (isDisabled) ...[
            const SizedBox(height: 12),
            NeuroShimmer(
              child: Container(
                width: 180,
                height: 20,
                decoration: BoxDecoration(
                  color: _kSkeletonGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConsentStatusSkeletonEducation extends StatelessWidget {
  const _ConsentStatusSkeletonEducation();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NeuroColors.adolescentPrimary.withValues(alpha: 0.05),
            NeuroColors.adolescentPrimaryLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeuroShimmer(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _kSkeletonGrey,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              NeuroShimmer(
                child: Container(
                  width: 200,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _kSkeletonGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _ConsentStatusSkeletonEducationItem(),
          const _ConsentStatusSkeletonEducationItem(),
          const _ConsentStatusSkeletonEducationItem(),
        ],
      ),
    );
  }
}

class _ConsentStatusSkeletonEducationItem extends StatelessWidget {
  const _ConsentStatusSkeletonEducationItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Expanded(
            child: NeuroShimmer(
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  color: _kSkeletonGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
