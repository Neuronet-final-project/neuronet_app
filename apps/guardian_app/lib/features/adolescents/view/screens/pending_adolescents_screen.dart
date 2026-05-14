import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:guardian_app/features/ui/bento_card.dart';
import 'package:guardian_app/features/ui/l10n_utils.dart';
import 'package:guardian_app/config/theme/guardian_theme.dart';
import '../../providers/adolescent_provider.dart';

class PendingAdolescentsScreen extends ConsumerWidget {
  const PendingAdolescentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingAdolescentsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF9FAFB),
            surfaceTintColor: const Color(0xFFF9FAFB),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.of(context).pop(),
              color: NeuroColors.guardianPrimaryDark,
            ),
            title: Text(
              context.localizations.pendingActivations,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: () => ref.invalidate(pendingAdolescentsProvider),
                color: NeuroColors.guardianPrimaryDark,
              ),
            ],
          ),
          pendingAsync.when(
            data: (pending) {
              if (pending.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return const Column(
                          children: [
                            _HeaderSection(),
                            SizedBox(height: 16),
                          ],
                        );
                      }
                      final adolescent = pending[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PendingAdolescentCard(adolescent: adolescent),
                      );
                    },
                    childCount: pending.length + 1,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: _buildErrorState(context, ref, err),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              context.localizations.failedToLoadAdolescents,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: NeuroColors.guardianPrimaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$err',
              style: const TextStyle(color: NeuroColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(pendingAdolescentsProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.localizations.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GuardianBentoCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_add_outlined,
                      size: 64,
                      color: NeuroColors.guardianPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.localizations.noPendingRequests,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: NeuroColors.guardianPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.localizations.noPendingRequestsDesc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: NeuroColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/register-adolescent'),
                      icon: const Icon(Icons.person_add_rounded),
                      label: Text(context.localizations.registerNewAdolescent),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NeuroColors.guardianPrimary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      padding: const EdgeInsets.all(20),
      gradient: GuardianStyles.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pending_actions_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.localizations.waitingForConnection,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            context.localizations.waitingForConnectionDesc,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingAdolescentCard extends StatelessWidget {
  final AdolescentResponse adolescent;

  const _PendingAdolescentCard({required this.adolescent});

  @override
  Widget build(BuildContext context) {
    final createdDate = adolescent.createdAt != null
        ? DateFormat('MMM d, yyyy').format(adolescent.createdAt!)
        : context.localizations.unknownDate;
    
    final status = adolescent.accountStatus;
    final isPending = status == AccountStatus.pendingActivation;

    return GuardianBentoCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: NeuroColors.guardianPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adolescent.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: NeuroColors.guardianPrimaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      adolescent.email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: NeuroColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context, status),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoTag(
                icon: Icons.calendar_today_rounded,
                label: context.localizations.addedDateLabel(createdDate),
              ),
              const SizedBox(width: 12),
              if (adolescent.relationship != null)
                _buildInfoTag(
                  icon: Icons.family_restroom_rounded,
                  label: adolescent.relationship!.localizedLabel(context.localizations).toUpperCase(),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showActivationInfo(context, status),
              icon: Icon(
                isPending ? Icons.qr_code_scanner_rounded : Icons.info_outline_rounded,
                size: 18,
              ),
              label: Text(
                isPending ? context.localizations.viewActivationInfo : context.localizations.accountDetails,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: NeuroColors.guardianPrimary,
                side: BorderSide(
                  color: NeuroColors.guardianPrimary.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, AccountStatus? status) {
    final isPending = status == AccountStatus.pendingActivation;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isPending
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPending
              ? const Color(0xFFFFEDD5)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        isPending ? context.localizations.pending.toUpperCase() : (status?.localizedLabel(context.localizations) ?? context.localizations.statusInactive).toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: isPending
              ? const Color(0xFF9A3412)
              : NeuroColors.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildInfoTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: NeuroColors.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: NeuroColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showActivationInfo(BuildContext context, AccountStatus? status) {
    String message = context.localizations.accountIsActive;
    if (status == AccountStatus.pendingActivation) {
      message = context.localizations.activationCodeSharedInfo;
    } else if (status == AccountStatus.inactive) {
      message = context.localizations.accountIsInactiveInfo;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: NeuroColors.guardianPrimaryDark,
      ),
    );
  }
}
