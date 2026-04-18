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
      backgroundColor: NeuroColors.background,
      appBar: AppBar(
        title: const Text('Privacy Hub'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: consentAsync.when(
        data: (state) => _buildContent(context, state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => NeuroErrorWidget(
          message: 'Could not load privacy settings.',
          onRetry: () => ref.refresh(adolescentConsentControllerProvider),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ConsentStatusState state) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPrivacyStatusHeader(context),
          const SizedBox(height: 32),
          
          Text(
            'Core Transparency',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // AI Analysis Section
          _buildPrivacyCard(
            context,
            title: 'General Participation',
            description: 'This allows Neuronet AI to analyze your journal entries for emotional patterns. If disabled, entries are stored but not analyzed.',
            isGranted: state.participation,
            icon: Icons.psychology_rounded,
          ),
          
          const SizedBox(height: 24),
          Text(
            'Sharing & Visibility',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Sub-sharing controls
          _buildPrivacyCard(
            context,
            title: 'AI Insights & Summaries',
            description: 'Your guardian and counselor can view summaries of your emotional trends.',
            isGranted: state.shareAiSummaries && state.participation,
            icon: Icons.summarize_rounded,
            isDisabled: !state.participation,
            warning: !state.participation ? 'Paused: General Participation is off' : null,
          ),
          
          const SizedBox(height: 16),
          _buildPrivacyCard(
            context,
            title: 'Safety Alerts',
            description: 'Real-time notifications sent to your guardian when high-risk patterns are identified.',
            isGranted: state.shareAlerts && state.participation,
            icon: Icons.notifications_active_rounded,
            isDisabled: !state.participation,
          ),

          const SizedBox(height: 24),
          Text(
            'Interaction Controls',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildPrivacyCard(
            context,
            title: 'Counselor Communication',
            description: 'Private messaging channel with your assigned counselor.',
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
            'Your Privacy Matters',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We value transparency. Below are the oversight settings currently active for your account.',
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
    final statusColor = isDisabled 
      ? NeuroColors.onSurfaceVariant.withValues(alpha: 0.5)
      : (isGranted ? NeuroColors.alertLow : NeuroColors.alertHigh);
      
    final statusText = isDisabled ? 'Paused' : (isGranted ? 'Granted' : 'Revoked');

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
          const Row(
            children: [
              Icon(Icons.help_center_outlined, color: NeuroColors.adolescentPrimary),
              SizedBox(width: 12),
              Text(
                'Understanding Your Privacy',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEducationItem(context, 'Your guardian manages these settings to ensure you have the right support.'),
          _buildEducationItem(context, 'If you have questions about these settings, we encourage you to discuss them with your guardian.'),
          _buildEducationItem(context, 'Neuronet uses AI only for emotional insight, never for clinical diagnosis.'),
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

