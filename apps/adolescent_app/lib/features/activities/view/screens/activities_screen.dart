import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/activities_provider.dart';
import '../../models/activity.dart';
import 'package:adolescent_app/config/router/app_router.dart';

class ActivitiesScreen extends ConsumerWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(activitiesProvider);

    return Scaffold(
      backgroundColor: NeuroColors.background,
      body: CustomScrollView(
        slivers: [
          const _SliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final activity = activities[index];
                  return _ActivityCard(activity: activity, index: index);
                },
                childCount: activities.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBar extends StatelessWidget {
  const _SliverAppBar();

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: NeuroColors.adolescentPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(l10n.playAndRelax,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
        background: Container(
          decoration: const BoxDecoration(
            gradient: NeuroGradients.adolescent,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -20, right: -20,
                child: _Orb(size: 120, color: Colors.white.withValues(alpha: 0.1)),
              ),
              Positioned(
                bottom: 20, left: 20,
                child: _Orb(size: 80, color: Colors.white.withValues(alpha: 0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final Activity activity;
  final int index;

  const _ActivityCard({required this.activity, required this.index});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: widget.activity.color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              context.push('${AdolescentRoutes.activities}/${widget.activity.id}');
            },
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: widget.activity.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(widget.activity.icon,
                        color: widget.activity.color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getActivityTitle(context, widget.activity),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D1B6B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getActivityDescription(context, widget.activity),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.5),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 14, color: widget.activity.color),
                            const SizedBox(width: 4),
                            Text(
                              l10n.minCount(widget.activity.durationMinutes),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: widget.activity.color,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.arrow_forward_rounded,
                                size: 18, color: widget.activity.color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getActivityTitle(BuildContext context, Activity activity) {
    final l10n = context.localizations;
    return switch (activity.type) {
      ActivityType.breathing => l10n.deepBreathingTitle,
      ActivityType.focus => l10n.mindfulFocusTitle,
      ActivityType.moodMatch => l10n.moodMatcherTitle,
      ActivityType.aiQuest => l10n.aiQuestTitle,
    };
  }

  String _getActivityDescription(BuildContext context, Activity activity) {
    final l10n = context.localizations;
    return switch (activity.type) {
      ActivityType.breathing => l10n.deepBreathingDesc,
      ActivityType.focus => l10n.mindfulFocusDesc,
      ActivityType.moodMatch => l10n.moodMatcherDesc,
      ActivityType.aiQuest => l10n.aiQuestDesc,
    };
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
