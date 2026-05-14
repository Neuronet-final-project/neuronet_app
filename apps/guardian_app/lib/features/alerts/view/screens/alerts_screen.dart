import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../dashboard/providers/dashboard_provider.dart';
import '../../../ui/bento_card.dart';
import '../../../ui/l10n_utils.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  String? _filterSeverity;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(guardianAlertsControllerProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF9FAFB),
            surfaceTintColor: const Color(0xFFF9FAFB),
            elevation: 0,
            title: Text(
              context.localizations.securityAlerts,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: NeuroColors.guardianPrimaryDark,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: _showFilterDialog,
                tooltip: context.localizations.filterBySeverity,
              ),
            ],
          ),
          alertsAsync.when(
            data: (state) {
               if (state.isLoading && state.alerts.isEmpty) {
                 return SliverList(
                   delegate: SliverChildBuilderDelegate(
                     (context, index) => const Padding(
                       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                       child: _AlertCardSkeleton(),
                     ),
                     childCount: 4,
                   ),
                 );
               }

              if (state.error != null && state.alerts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NeuroErrorWidget(
                        message: '${context.localizations.errorPrefix}: ${state.error}',
                        onRetry: () => ref.read(guardianAlertsControllerProvider.notifier).refresh(),
                      ),
                    ),
                  ),
                );
              }

              final alerts = state.alerts;
              final filteredAlerts = _filterSeverity == null
                  ? alerts
                  : alerts.where((a) => a.severityLevel.toLowerCase() == _filterSeverity!.toLowerCase()).toList();

              if (filteredAlerts.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NeuroEmptyState(
                        title: _filterSeverity == null ? context.localizations.noAlertsYet : context.localizations.noAlertsFound,
                        message: _filterSeverity == null 
                            ? context.localizations.noAlertsYetDesc
                            : context.localizations.noAlertsFoundDescFiltered(_filterSeverity!),
                        icon: Icons.notifications_off_outlined,
                        color: NeuroColors.onSurfaceVariant,
                        actionLabel: _filterSeverity != null ? context.localizations.clearFilter : null,
                        onActionPressed: _filterSeverity != null ? () => setState(() => _filterSeverity = null) : null,
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final alert = filteredAlerts[index];
                      return _AlertCard(alert: alert)
                          .animate(
                            delay: (100 * index).ms,
                          )
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutQuad);
                    },
                    childCount: filteredAlerts.length,
                  ),
                ),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: _AlertCardSkeleton(),
                ),
                childCount: 4,
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: NeuroErrorWidget(
                    message: context.localizations.failedToLoadAlerts,
                    onRetry: () => ref.read(guardianAlertsControllerProvider.notifier).refresh(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.localizations.filterBySeverity),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ignore: deprecated_member_use
            ListTile(
              title: Text(context.localizations.filterAll),
              leading: Radio<String?>(
                value: null,
                // ignore: deprecated_member_use
                groupValue: _filterSeverity,
                // ignore: deprecated_member_use
                onChanged: (value) {
                  setState(() => _filterSeverity = value);
                  Navigator.pop(context);
                },
              ),
              onTap: () {
                setState(() => _filterSeverity = null);
                Navigator.pop(context);
              },
            ),
            ...['Low', 'Medium', 'High'].map((s) => ListTile(
                  title: Text(translateAlertSeverity(context, s)),
                  leading: Radio<String?>(
                    value: s,
                    // ignore: deprecated_member_use
                    groupValue: _filterSeverity,
                    // ignore: deprecated_member_use
                    onChanged: (value) {
                      setState(() => _filterSeverity = value);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    setState(() => _filterSeverity = s);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});

  final Alert alert;

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(alert.severityLevel);
    final isHighSeverity = alert.severityLevel.toLowerCase().contains('high');

    return RepaintBoundary(
      child: GuardianBentoCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        onTap: () => context.push('/alert-details/${alert.alertId}'),
        padding: const EdgeInsets.all(18),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // ── Header: severity badge + date ───────────────────────────────────
             Row(
               children: [
                 Container(
                   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                   decoration: BoxDecoration(
                     color: color.withValues(alpha: 0.15),
                     borderRadius: BorderRadius.circular(10),
                     border: Border.all(color: color.withValues(alpha: 0.4)),
                   ),
                   child: Text(
                     context.localizations.severityRisk(translateAlertSeverity(context, alert.severityLevel).toUpperCase()),
                     style: TextStyle(
                       color: color,
                       fontWeight: FontWeight.w900,
                       fontSize: 9,
                       letterSpacing: 1.0,
                     ),
                   ),
                 ),
                 const Spacer(),
                 Text(
                   _formatDate(context, alert.createdAt),
                   style: TextStyle(
                     fontSize: 11,
                     fontWeight: FontWeight.w600,
                     color: NeuroColors.onSurface.withValues(alpha: 0.45),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             // ── Body: icon + name/concern ───────────────────────────────────────
             Row(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 // Severity icon with subtle ring
                 Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     color: color.withValues(alpha: 0.08),
                     shape: BoxShape.circle,
                     border: Border.all(color: color.withValues(alpha: 0.25), width: 1.5),
                   ),
                   child: Icon(Icons.warning_amber_rounded, size: 20, color: color),
                 ),
                 const SizedBox(width: 14),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         alert.adolescentName,
                         style: const TextStyle(
                           fontSize: 16,
                           fontWeight: FontWeight.w800,
                           color: NeuroColors.onSurface,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         alert.mainConcern.isEmpty
                             ? alert.alertType.replaceAll('_', ' ').toUpperCase()
                             : alert.mainConcern,
                         style: TextStyle(
                           fontSize: 12,
                           fontWeight: FontWeight.w700,
                           color: color,
                           letterSpacing: 0.4,
                         ),
                       ),
                     ],
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 16),
             // ── Summary ─────────────────────────────────────────────────────────
             Text(
               alert.aiSummary.isNotEmpty ? alert.aiSummary : alert.triggerDescription,
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
               style: TextStyle(
                 fontSize: 14,
                 fontWeight: FontWeight.w500,
                 color: NeuroColors.onSurface.withValues(alpha: 0.75),
                 height: 1.45,
               ),
             ),
             // ── Emotion chips ───────────────────────────────────────────────────
             if (alert.detectedEmotions.isNotEmpty) ...[
               const SizedBox(height: 14),
               Wrap(
                 spacing: 8,
                 runSpacing: 6,
                 children: alert.detectedEmotions.take(4).map((emotion) {
                   return Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                     decoration: BoxDecoration(
                       color: NeuroColors.onSurface.withValues(alpha: 0.06),
                       borderRadius: BorderRadius.circular(10),
                       border: Border.all(
                         color: NeuroColors.onSurface.withValues(alpha: 0.12),
                         width: 1,
                       ),
                     ),
                     child: Text(
                       emotion,
                       style: TextStyle(
                         fontSize: 11,
                         fontWeight: FontWeight.w700,
                         color: NeuroColors.onSurface.withValues(alpha: 0.75),
                       ),
                     ),
                   );
                 }).toList(),
               ),
             ],
           ],
         ).animate(onPlay: (c) => c.repeat())
          .custom(
            duration: 10.seconds,
            builder: (context, value, child) {
              if (!isHighSeverity) return child;

              // Create a 1s pulse within a 10s cycle
              double intensity = 0;
              if (value < 0.1) {
                double t = value / 0.1;
                intensity = t < 0.5 ? t * 2 : (1 - t) * 2;
                // Apply smooth curve to intensity
                intensity = Curves.easeInOut.transform(intensity);
              }

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15 * intensity),
                      blurRadius: 12 * intensity,
                      spreadRadius: 2 * intensity,
                    ),
                  ],
                ),
                child: child,
              );
            },
          ),
      ),
    ).animate(autoPlay: false).scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(0.98, 0.98),
          duration: 100.ms,
        );
  }

  Color _getSeverityColor(String severity) {
    final s = severity.toLowerCase();
    if (s.contains('high')) return NeuroColors.alertHigh;
    if (s.contains('medium')) return NeuroColors.alertMedium;
    return NeuroColors.alertLow;
  }

   String _formatDate(BuildContext context, DateTime date) {
     final now = DateTime.now();
     final diff = now.difference(date);
     final l10n = context.localizations;
     if (diff.inDays == 0) return l10n.today;
     if (diff.inDays == 1) return l10n.yesterday;
     return DateFormat('dd/MM/yyyy').format(date);
   }
 }

// ── Alert Card Skeleton ────────────────────────────────────────────────────────
class _AlertCardSkeleton extends StatelessWidget {
  const _AlertCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GuardianBentoCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: severity badge + date
          Row(
            children: [
              NeuroShimmer(
                child: Container(
                  width: 75,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Spacer(),
              NeuroShimmer(
                child: Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Body: icon (circle with border) + name/concern
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              NeuroShimmer(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[400]!, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NeuroShimmer(
                      child: Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    NeuroShimmer(
                      child: Container(
                        width: 140,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
           const SizedBox(height: 16),
           // Summary text (can be 2 lines)
           NeuroShimmer(
             child: Container(
               width: double.infinity,
               height: 28,
               decoration: BoxDecoration(
                 color: Colors.grey[300],
                 borderRadius: BorderRadius.circular(4),
               ),
             ),
           ),
           const SizedBox(height: 14),
           // Emotion chips (Wrap like real card)
           Wrap(
             spacing: 8,
             runSpacing: 6,
             children: [
               NeuroShimmer(
                 child: Container(
                   width: 60,
                   height: 22,
                   decoration: BoxDecoration(
                     color: Colors.grey[300],
                     borderRadius: BorderRadius.circular(10),
                   ),
                 ),
               ),
               NeuroShimmer(
                 child: Container(
                   width: 70,
                   height: 22,
                   decoration: BoxDecoration(
                     color: Colors.grey[300],
                     borderRadius: BorderRadius.circular(10),
                   ),
                 ),
               ),
               NeuroShimmer(
                 child: Container(
                   width: 55,
                   height: 22,
                   decoration: BoxDecoration(
                     color: Colors.grey[300],
                     borderRadius: BorderRadius.circular(10),
                   ),
                 ),
               ),
             ],
           ),
        ],
      ),
    );
  }
}
