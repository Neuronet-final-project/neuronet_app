import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/theme/guardian_theme.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../ui/bento_card.dart';

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
      body: alertsAsync.when(
        data: (state) {
          final alert = state.alerts.where((a) => a.alertId == widget.alertId).firstOrNull;
          
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0xFFF9FAFB),
                surfaceTintColor: const Color(0xFFF9FAFB),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: () => context.pop(),
                  color: NeuroColors.onSurface,
                ),
                title: const Text(
                  'Alert Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: NeuroColors.guardianPrimaryDark,
                  ),
                ),
              ),
              if (state.isLoading && state.alerts.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null && state.alerts.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: NeuroErrorWidget(
                      message: 'Error: ${state.error}',
                      onRetry: () => ref.read(guardianAlertsControllerProvider.notifier).refresh(),
                    ),
                  ),
                )
              else if (alert == null)
                const SliverFillRemaining(
                  child: Center(
                    child: NeuroEmptyState(
                      title: 'Alert Not Found',
                      message: 'This alert may have been resolved or deleted.',
                      icon: Icons.warning_amber_outlined,
                      color: NeuroColors.onSurfaceVariant,
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeroHeader(alert)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.1, duration: 600.ms, curve: Curves.easeOut),
                        const SizedBox(height: 12),
                        
                        if (alert.aiSummary.isNotEmpty) ...[
                          _buildAiInsightCard(alert)
                              .animate(delay: 150.ms)
                              .fadeIn()
                              .slideY(begin: 0.1),
                          const SizedBox(height: 12),
                        ],
                        
                        if (alert.detectedEmotions.isNotEmpty) ...[
                          _buildEmotionsCard(alert)
                              .animate(delay: 300.ms)
                              .fadeIn()
                              .slideY(begin: 0.1),
                          const SizedBox(height: 12),
                        ],
                        
                        _buildTriggerDetailsCard(alert)
                            .animate(delay: 450.ms)
                            .fadeIn()
                            .slideY(begin: 0.1),
                        const SizedBox(height: 32),
                        
                        _buildResolutionSection()
                            .animate(delay: 600.ms)
                            .fadeIn(),
                        const SizedBox(height: 32),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: NeuroButton(
                            onPressed: () => _resolveAlert(alert),
                            label: 'Mark as Resolved',
                            borderRadius: 16,
                          ),
                        ).animate(delay: 750.ms).fadeIn().scale(begin: const Offset(0.9, 0.9)),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHeroHeader(Alert alert) {
    final isHighSeverity = alert.severityLevel.toLowerCase().contains('high');

    return GuardianBentoCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      gradient: GuardianStyles.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighSeverity 
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.severityLevel.toUpperCase(),
                  style: TextStyle(
                    color: isHighSeverity 
                        ? NeuroColors.alertHigh 
                        : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ).animate(
                target: isHighSeverity ? 1 : 0,
                onPlay: (controller) => isHighSeverity ? controller.repeat(reverse: true) : null,
              )
              .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5))
              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
              const Spacer(),
              Text(
                '${alert.createdAt.day}/${alert.createdAt.month}/${alert.createdAt.year}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            alert.adolescentName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            alert.mainConcern.isNotEmpty ? alert.mainConcern : 'General Behavioral Check',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard(Alert alert) {
    return GuardianBentoCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: NeuroColors.guardianPrimary, size: 22),
              const SizedBox(width: 10),
              Text(
                'AI Analysis'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: NeuroColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            alert.aiSummary,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: NeuroColors.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionsCard(Alert alert) {
    final color = _getSeverityColor(alert.severityLevel);

    return GuardianBentoCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emotional Context'.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: NeuroColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: alert.detectedEmotions.map((emotion) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Text(
                  emotion,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerDetailsCard(Alert alert) {
    return GuardianBentoCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trigger Pattern'.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: NeuroColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Type', alert.alertType.replaceAll('_', ' ').toUpperCase()),
          const Divider(height: 24, thickness: 0.5),
          Text(
            alert.triggerDescription,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NeuroColors.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: NeuroColors.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildResolutionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resolution & Guardrail',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter observations or actions taken...',
              hintStyle: TextStyle(color: NeuroColors.onSurface.withValues(alpha: 0.3)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: NeuroColors.guardianPrimary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('high')) return NeuroColors.alertHigh;
    if (s.contains('medium')) return NeuroColors.alertMedium;
    return NeuroColors.alertLow;
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
