import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/consent_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';
import 'package:guardian_app/features/ui/bento_card.dart';
import 'package:guardian_app/features/ui/l10n_utils.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';

class ConsentScreen extends ConsumerWidget {
  const ConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentsAsync = ref.watch(guardianConsentControllerProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF9FAFB),
            surfaceTintColor: const Color(0xFFF9FAFB),
            elevation: 0,
            title: Text(
              context.localizations.privacyOversight,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () =>
                    ref.read(guardianConsentControllerProvider.notifier).refresh(),
                tooltip: context.localizations.refreshSettingsTooltip,
              ),
            ],
          ),
          consentsAsync.when(
            data: (state) {
              if (state.isLoading && state.consents.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.error != null && state.consents.isEmpty) {
                return SliverFillRemaining(
                  child: _buildErrorState(ref, state.error!),
                );
              }

              final consents = state.consents;
              if (consents.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(context),
                );
              }

              // Group consents by adolescent ID
              final grouped = <String, List<Consent>>{};
              for (final c in consents) {
                grouped.putIfAbsent(c.adolescentId, () => []).add(c);
              }

              return SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: Column(
                    children: [
                      _buildHeroSection(context)
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
                      ...grouped.entries.mapIndexed(
                        (index, entry) => _buildAdolescentGroup(
                          context,
                          ref,
                          entry.key,
                          entry.value,
                        ).animate(delay: (200 * (index + 1)).ms)
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.1, curve: Curves.easeOutQuad),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
            loading: () => SliverToBoxAdapter(
              child: Column(
                children: [
                  const _ConsentSkeletonHero(),
                  const SizedBox(height: 16),
                  const _ConsentSkeletonAdolescentGroup(),
                  const _ConsentSkeletonAdolescentGroup(),
                  const _ConsentSkeletonAdolescentGroup(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: _buildErrorState(ref, 'Failed to load settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return GuardianBentoCard(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      gradient: GuardianStyles.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Text(
                context.localizations.securityHub,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            context.localizations.consentHeroDesc,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdolescentGroup(
    BuildContext context,
    WidgetRef ref,
    String email,
    List<Consent> adolescentConsents,
  ) {
    // Find specific consents
    final participation = adolescentConsents.firstWhere(
      (c) => c.consentType == ConsentType.participation,
    );
    final aiSummaries = adolescentConsents.firstWhere(
      (c) => c.consentType == ConsentType.shareAiSummaries,
    );
    final alerts = adolescentConsents.firstWhere(
      (c) => c.consentType == ConsentType.shareAlerts,
    );
    final counselorChat = adolescentConsents.firstWhere(
      (c) => c.consentType == ConsentType.counselorChat,
    );

    final isParticipationGranted =
        participation.consentStatus == ConsentStatus.granted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Center(
                  child: const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: NeuroColors.guardianPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.localizations.settingsForAdolescent(email).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: NeuroColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        GuardianBentoCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              _buildInnerSectionHeader(
                title: context.localizations.dataAndPrivacy,
                subtitle: context.localizations.manageDataProcessed,
                icon: Icons.psychology_outlined,
              ),
              const SizedBox(height: 12),
              _buildConsentToggle(
                context,
                ref,
                participation,
                isMaster: true,
                icon: Icons.psychology_outlined,
              ),
              if (isParticipationGranted) ...[
                _buildConsentToggle(
                  context,
                  ref,
                  aiSummaries,
                  icon: Icons.summarize_outlined,
                  isNested: true,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Divider(height: 1, thickness: 0.5),
              ),
              _buildInnerSectionHeader(
                title: context.localizations.safetyMonitoring,
                subtitle: context.localizations.proactiveAlertsSupport,
                icon: Icons.security_outlined,
              ),
              const SizedBox(height: 12),
              _buildConsentToggle(context, ref, alerts, icon: Icons.notifications_active_outlined),
              _buildConsentToggle(
                context,
                ref,
                counselorChat,
                icon: Icons.chat_bubble_outline_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInnerSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: NeuroColors.guardianPrimary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: NeuroColors.guardianPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: NeuroColors.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: NeuroColors.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentToggle(
    BuildContext context,
    WidgetRef ref,
    Consent consent, {
    bool isMaster = false,
    bool isNested = false,
    IconData? icon,
  }) {
    final isGranted = consent.consentStatus == ConsentStatus.granted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
          onTap: () => _handleToggle(context, ref, consent, !isGranted),
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: icon != null
                      ? Center(
                        child: Icon(
                          icon,
                          size: 20,
                          color:
                              isGranted
                                  ? NeuroColors.guardianPrimary
                                  : NeuroColors.onSurfaceVariant,
                        ),
                      )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consent.consentType.localizedLabel(context.localizations),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isMaster ? FontWeight.w700 : FontWeight.w600,
                          color: isMaster
                              ? NeuroColors.onSurface
                              : NeuroColors.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        consent.consentType.localizedDescription(context.localizations),
                        style: TextStyle(
                          fontSize: 12,
                          color: NeuroColors.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Switch.adaptive(
                  value: isGranted,
                  activeTrackColor: NeuroColors.guardianPrimary,
                  onChanged: (value) => _handleToggle(context, ref, consent, value),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    WidgetRef ref,
    Consent consent,
    bool value,
  ) async {
    final newStatus = value ? ConsentStatus.granted : ConsentStatus.revoked;
    try {
      await ref.read(guardianConsentControllerProvider.notifier).updateConsent(
        consent,
        newStatus,
      );

      if (context.mounted) {
        NeuroToast.show(
          context,
          '${consent.consentType.localizedLabel(context.localizations)} ${value ? context.localizations.granted : context.localizations.revoked}',
          type: value ? NeuroToastType.success : NeuroToastType.info,
        );
      }
    } catch (e) {
      if (context.mounted) {
        NeuroToast.show(context, '${context.localizations.errorPrefix}: $e', type: NeuroToastType.error);
      }
    }
  }


  Widget _buildErrorState(WidgetRef ref, String message) {
    return Center(
      child: NeuroErrorWidget(
        message: message,
        onRetry: () => ref.read(guardianConsentControllerProvider.notifier).refresh(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: NeuroEmptyState(
        title: context.localizations.noLinkedAccounts,
        message: context.localizations.consentManagementAwaitsLink,
        icon: Icons.link_off_rounded,
      ),
    );
  }
}


// --- Skeleton Loading Widgets ------------------------------------------------

const _kSkeletonGrey = Color(0xFFE5E7EB);

class _ConsentSkeletonHero extends StatelessWidget {
  const _ConsentSkeletonHero();

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      gradient: GuardianStyles.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeuroShimmer(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeuroShimmer(
                      child: Container(
                        width: 140,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    NeuroShimmer(
                      child: Container(
                        width: 280,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConsentSkeletonAdolescentGroup extends StatelessWidget {
  const _ConsentSkeletonAdolescentGroup();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Center(
                  child: NeuroShimmer(
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _kSkeletonGrey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NeuroShimmer(
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: _kSkeletonGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        GuardianBentoCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              // Section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    NeuroShimmer(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _kSkeletonGrey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeuroShimmer(
                            child: Container(
                              width: 120,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _kSkeletonGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          NeuroShimmer(
                            child: Container(
                              width: 180,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _kSkeletonGrey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 16),
              // 4 toggle rows
              const _ConsentSkeletonToggleRow(),
              const _ConsentSkeletonToggleRow(),
              const _ConsentSkeletonToggleRow(),
              const _ConsentSkeletonToggleRow(),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ConsentSkeletonToggleRow extends StatelessWidget {
  const _ConsentSkeletonToggleRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 36), // icon placeholder space
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeuroShimmer(
                  child: Container(
                    width: 140,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _kSkeletonGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                NeuroShimmer(
                  child: Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _kSkeletonGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          NeuroShimmer(
            child: Container(
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                color: _kSkeletonGrey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
