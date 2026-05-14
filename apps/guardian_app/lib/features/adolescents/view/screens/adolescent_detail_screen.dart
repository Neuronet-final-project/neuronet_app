import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:collection/collection.dart';
import 'package:guardian_app/config/router/app_router.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../ui/bento_card.dart';
import '../../providers/adolescent_provider.dart';

class AdolescentDetailScreen extends ConsumerWidget {
  final String adolescentId;

  const AdolescentDetailScreen({super.key, required this.adolescentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(
      adolescentDetailControllerProvider(adolescentId),
    );

    return Scaffold(
      body: CustomScrollView(
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
            title: Text(
              context.localizations.adolescentProfile,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
          ),
          detailState.when(
            data: (state) {
              if (state.isLoading && state.profile == null) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (state.error != null && state.profile == null) {
                return SliverFillRemaining(
                  child: _buildErrorState(ref, state.error!, adolescentId),
                );
              }

              final profile = state.profile;
              if (profile == null) {
                return SliverFillRemaining(
                  child: _buildErrorState(
                    ref,
                    context.localizations.profileNotFound,
                    adolescentId,
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: _buildContent(context, ref, state),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: _buildErrorState(
                ref,
                '${context.localizations.errorPrefix}: $err',
                adolescentId,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AdolescentDetailState state,
  ) {
    final profile = state.profile!;
    final consents = state.consents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroProfile(context, profile)
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, curve: Curves.easeOutQuad),
        const SizedBox(height: 24),
        
        _buildSectionTitle(context.localizations.interventionHub)
            .animate()
            .fadeIn(delay: 200.ms),
        _buildActionGrid(context, profile)
            .animate()
            .fadeIn(delay: 300.ms)
            .slideY(begin: 0.2, curve: Curves.easeOutQuad),
        const SizedBox(height: 32),

        _buildSectionTitle(context.localizations.registrationDetails)
            .animate()
            .fadeIn(delay: 400.ms),
        _buildSectionCard([
          _buildDetailRow(context.localizations.fullName, profile.fullName),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailRow(context.localizations.emailAddress, profile.email),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailRow(
            context.localizations.relationship,
            profile.relationship?.name.toUpperCase() ?? 'N/A',
          ),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailRow(
            context.localizations.accountStatus,
            profile.accountStatus?.name.toUpperCase() ?? context.localizations.activeStatus,
          ),
          const Divider(height: 24, thickness: 0.5),
          _buildDetailRow(
            context.localizations.linkedSince,
            profile.createdAt?.toIso8601String().split('T')[0] ?? 'N/A',
          ),
        ]).animate()
          .fadeIn(delay: 500.ms)
          .slideY(begin: 0.2, curve: Curves.easeOutQuad),
        const SizedBox(height: 32),

        _buildSectionTitle(context.localizations.activePermissions)
            .animate()
            .fadeIn(delay: 600.ms),
        _buildSectionCard([
          if (consents.isEmpty)
            NeuroEmptyState(
              isMini: true,
              title: context.localizations.noConsentsFound,
              message: context.localizations.noConsentsFoundDesc,
              icon: Icons.assignment_late_outlined,
              color: NeuroColors.guardianPrimary,
            )
          else
            ...consents.mapIndexed(
              (index, c) => Column(
                children: [
                  if (index > 0) const Divider(height: 24, thickness: 0.5),
                  _buildConsentEntry(
                    c.consentType.label,
                    c.consentStatus == ConsentStatus.granted,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => context.go(GuardianRoutes.consent),
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: Text(context.localizations.manageAllConsents),
              style: TextButton.styleFrom(
                foregroundColor: NeuroColors.guardianPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: NeuroColors.guardianPrimary.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]).animate()
          .fadeIn(delay: 700.ms)
          .slideY(begin: 0.2, curve: Curves.easeOutQuad),
        
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return GuardianBentoCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      child: Column(children: children),
    );
  }

  Widget _buildHeroProfile(BuildContext context, AdolescentResponse profile) {
    return GuardianBentoCard(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(24),
      gradient: GuardianStyles.primaryGradient,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 40,
              color: Colors.white,
            ).animate(onPlay: (c) => c.repeat())
             .shimmer(
                delay: 5.seconds,
                duration: 2.seconds,
                color: Colors.white.withValues(alpha: 0.3),
              ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.localizations.personalAccountTag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, AdolescentResponse profile) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  onTap: () {
                    final id = profile.effectiveId;
                    context.push(
                      '/adolescent/$id/chat?name=${Uri.encodeComponent(profile.fullName)}',
                    );
                  },
                  icon: Icons.chat_bubble_outline_rounded,
                  label: context.localizations.counselorLabel,
                  subtitle: context.localizations.sendMessage,
                  color: NeuroColors.guardianPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  onTap: () {
                    final id = profile.effectiveId;
                    context.push(
                      '/adolescent/$id/recommendations?name=${Uri.encodeComponent(profile.fullName)}',
                    );
                  },
                  icon: Icons.auto_awesome_outlined,
                  label: context.localizations.aiGuide,
                  subtitle: context.localizations.viewTips,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  onTap: () {
                    final id = profile.effectiveId;
                    context.push(
                      '/adolescent/$id/follows?name=${Uri.encodeComponent(profile.fullName)}',
                    );
                  },
                  icon: Icons.library_books_outlined,
                  label: context.localizations.followsLabel,
                  subtitle: context.localizations.educationalPagesSubtitle,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return GuardianBentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: NeuroColors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    ).animate(autoPlay: false).scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.97, 0.97),
          duration: 100.ms,
        );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: NeuroColors.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: NeuroColors.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: NeuroColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildConsentEntry(String title, bool isEnabled) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (isEnabled ? NeuroColors.alertLow : NeuroColors.onSurface)
                .withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isEnabled ? Icons.check_rounded : Icons.close_rounded,
            color: isEnabled ? NeuroColors.alertLow : NeuroColors.onSurfaceVariant,
            size: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isEnabled
                ? NeuroColors.alertLow.withValues(alpha: 0.1)
                : NeuroColors.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            isEnabled ? 'ACTIVE' : 'DISABLED',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: isEnabled ? NeuroColors.alertLow : NeuroColors.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(WidgetRef ref, String message, String id) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: NeuroErrorWidget(
          message: message,
          onRetry: () => ref
              .read(adolescentDetailControllerProvider(id).notifier)
              .refresh(),
        ),
      ),
    );
  }
}
