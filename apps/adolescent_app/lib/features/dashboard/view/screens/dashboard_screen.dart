import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:go_router/go_router.dart';
import '../../providers/dashboard_provider.dart';
import 'package:adolescent_app/config/router/app_router.dart';
import 'package:adolescent_app/features/mood/providers/mood_provider.dart';
import 'package:adolescent_app/features/profile/providers/profile_provider.dart';
import 'package:adolescent_app/features/alerts/providers/alerts_provider.dart';
import 'package:adolescent_app/features/educational/providers/educational_provider.dart';

// ─── Local Design Tokens ──────────────────────────────────────────────────────
const _kPurple   = Color(0xFF7C4DFF);
const _kLavender = Color(0xFFB47CFF);
const _kDeepPurple = Color(0xFF5E35B1);
const _kSurface  = Color(0xFFF5F3FF);
const _kSurfaceVariant = Color(0xFFEDE7FF);
const _kBody     = Color(0xFF2D1B6B);
const _kSubtle   = Color(0xFF9E9EB8);
const _kCard     = Colors.white;

// Quick-action card accent colors (icon gradient only, card is white)
const _cardColors = [
  [Color(0xFF7C4DFF), Color(0xFFB47CFF)], // purple
  [Color(0xFF00BCD4), Color(0xFF4FC3F7)], // cyan → sky
  [Color(0xFFFF7043), Color(0xFFFFAB40)], // deep orange → amber
  [Color(0xFF43A047), Color(0xFF81C784)], // green
];

// ─── Main Screen ──────────────────────────────────────────────────────────────
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh dashboard when app comes back to foreground
      ref.invalidate(adolescentDashboardControllerProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: RefreshIndicator(
        color: _kPurple,
        onRefresh: () => ref.refresh(adolescentDashboardControllerProvider.future),
        child: Consumer(
          builder: (context, ref, _) {
            final dashboardState = ref.watch(adolescentDashboardControllerProvider);

            return dashboardState.when(
              loading: () => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: const [
                  _HeroAppBarSkeleton(),
                  SliverToBoxAdapter(child: _DailyCheckInCardSkeleton()),
                  SliverToBoxAdapter(child: _MoodCheckInRowSkeleton()),
                  SliverToBoxAdapter(child: _StatsRowSkeleton()),
                  SliverToBoxAdapter(child: _QuickActionGridSkeleton()),
                  SliverToBoxAdapter(child: _RecentJournalsSkeleton()),
                  SliverToBoxAdapter(child: _InsightsBannerSkeleton()),
                  SliverToBoxAdapter(child: _LearningCardSkeleton()),
                  SliverToBoxAdapter(child: _PlayRelaxSectionSkeleton()),
                ],
              ),
              error: (err, stack) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _HeroAppBar(ref: ref),
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('${context.localizations.failedToLoadDashboard}\n$err'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => ref.refresh(adolescentDashboardControllerProvider.future),
                              child: Text(context.localizations.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              data: (_) => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _HeroAppBar(ref: ref),
                  const SliverToBoxAdapter(child: _DailyCheckInCard()),
                  SliverToBoxAdapter(child: _MoodCheckInRow(ref: ref)),
                  SliverToBoxAdapter(child: _StatsRow(ref: ref)),
                  SliverToBoxAdapter(child: _QuickActionGrid()),
                  SliverToBoxAdapter(child: _RecentJournals(ref: ref)),
                  SliverToBoxAdapter(child: _InsightsBanner(ref: ref)),
                  SliverToBoxAdapter(child: const _LearningCard()),
                  const SliverToBoxAdapter(child: _PlayRelaxSection()),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _SageAIButton(
        onTap: () => context.push(AdolescentRoutes.aiChat),
      ),
    );
  }
}

// ─── Hero SliverAppBar ────────────────────────────────────────────────────────
class _HeroAppBar extends ConsumerWidget {
  const _HeroAppBar({required this.ref});
  final WidgetRef ref;

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    final l10n = context.localizations;
    if (h < 12) return l10n.goodMorning;
    if (h < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.localizations;
    final profileAsync = ref.watch(adolescentProfileControllerProvider);
    final alertsAsync  = ref.watch(adolescentAlertsControllerProvider);

    final name = profileAsync.maybeWhen(
      data: (s) => s.user?.fullName.split(' ').first ?? 'there',
      orElse: () => 'there',
    );
    final unread = alertsAsync.maybeWhen(
      data: (s) {
        final count = s.alerts.where((a) => !a.viewedStatus).length;
        // Debug: Print unread count
        debugPrint('[Dashboard] Unread insights count: $count / ${s.alerts.length} total');
        return count;
      },
      orElse: () => 0,
    );

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: _kPurple,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1FDB), _kPurple, _kLavender],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative orbs
              Positioned(top: -30, right: -30,
                child: _Orb(size: 140, color: Colors.white.withValues(alpha: 0.06))),
              Positioned(bottom: 10, left: -20,
                child: _Orb(size: 100, color: Color(0xFF64B5F6).withValues(alpha: 0.15))),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo tile
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.self_improvement_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 5),
                                Text(l10n.adolescent,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        letterSpacing: 1.2)),
                              ],
                            ),
                          ),
                          // Removed redundant insight button from here to consolidate in actions
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _greeting(context).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.heyUser(name),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.innerWorldPrompt,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        title: Text(l10n.appTitle,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.push(AdolescentRoutes.alerts),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded,
                        color: Colors.white, size: 24),
                  ),
                  if (unread > 0)
                    Positioned(
                      right: -2, top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B6B), Color(0xFFFF4757)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: _kPurple, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]),
                        child: Center(
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.white,
                                fontWeight: FontWeight.w900,
                                height: 1.0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Daily Check-in Card ──────────────────────────────────────────────────────
class _DailyCheckInCard extends StatefulWidget {
  const _DailyCheckInCard();

  @override
  State<_DailyCheckInCard> createState() => _DailyCheckInCardState();
}

class _DailyCheckInCardState extends State<_DailyCheckInCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4D4D), Color(0xFF7C4DFF)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.smallCheckIn,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
            child: GestureDetector(
              onTapDown: (_) {
                _controller.forward();
              },
              onTapUp: (_) {
                _controller.reverse();
                context.go(AdolescentRoutes.mood);
              },
              onTapCancel: () {
                _controller.reverse();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF4D4D),
                      Color(0xFFFE6885),
                      Color(0xFF7C4DFF),
                      Color(0xFF5E35B1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF4D4D).withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // Content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                l10n.today,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.take30Seconds,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.namingFeelings,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => context.go(AdolescentRoutes.mood),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF5E35B1),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.checkInNow,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Mood Check-in Row ────────────────────────────────────────────────────────
class _MoodCheckInRow extends ConsumerWidget {
  const _MoodCheckInRow({required this.ref});
  final WidgetRef ref;

  static const _moods = [
    MoodType.happy, MoodType.calm, MoodType.excited,
    MoodType.hopeful, MoodType.neutral, MoodType.tired,
    MoodType.anxious, MoodType.sad,
  ];

  // Precise hex colors extracted from screenshots
  static const _bg = [
    Color(0xFFFFDF8D), // happy   (yellow)
    Color(0xFFC7EBCB), // calm    (mint)
    Color(0xFFFFD1DF), // excited (pink)
    Color(0xFFD5EDFC), // hopeful (light blue)
    Color(0xFFEBEBE6), // neutral (beige/grey)
    Color(0xFFD2D5E6), // tired   (periwinkle)
    Color(0xFFFFD4A9), // anxious (peach)
    Color(0xFFD5DAED), // sad     (soft violet/blue)
  ];

  static const _labelColors = [
    Color(0xFF906636), // happy
    Color(0xFF3F694F), // calm
    Color(0xFF883C5A), // excited
    Color(0xFF3B5D7C), // hopeful
    Color(0xFF61615E), // neutral
    Color(0xFF4C526A), // tired
    Color(0xFF9C5E35), // anxious
    Color(0xFF313D60), // sad
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(l10n.howAreYouFeeling,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: _kBody)),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => context.go(AdolescentRoutes.mood),
                child: Text(l10n.allMoods,
                    style: const TextStyle(
                        fontSize: 12,
                        color: _kPurple,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _moods.length,
            itemBuilder: (context, i) {
              final mood = _moods[i];
              return GestureDetector(
                onTap: () {
                  ref.read(moodControllerProvider.notifier).selectMood(mood);
                  context.go(AdolescentRoutes.mood);
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 74, height: 74,
                        decoration: BoxDecoration(
                          color: _bg[i],
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: Center(
                          child: Text(
                            mood.emoji,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood.localizedLabel(l10n),
                        style: TextStyle(
                            fontSize: 12,
                            color: _labelColors[i],
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────
class _StatsRow extends ConsumerWidget {
  const _StatsRow({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(adolescentDashboardControllerProvider);

    return dashAsync.maybeWhen(
      data: (state) {
        final l10n = context.localizations;
        final data = state.data;
        final journals = data?.totalJournals ?? 0;
        final moods = data?.totalMoods ?? 0;
        final recs = data?.educationalRecommendations.length ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _StatPill(label: l10n.journals, value: '$journals', icon: Icons.menu_book_rounded,
                  gradient: const [Color(0xFFA875FF), Color(0xFF8D53FF)]),
              const SizedBox(width: 10),
              _StatPill(label: l10n.moods, value: '$moods', icon: Icons.sentiment_very_satisfied_rounded,
                  gradient: const [Color(0xFF38C7F0), Color(0xFF4DB0F6)]),
              const SizedBox(width: 10),
              _StatPill(label: l10n.forYou, value: '$recs', icon: Icons.school_rounded,
                  gradient: const [Color(0xFFFF8A49), Color(0xFFFF9F49)]),
            ],
          ),
        );
      },
      orElse: () => const _StatsRowSkeleton(),
    );
  }
}

class _StatPill extends StatefulWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });
  final String label, value;
  final IconData icon;
  final List<Color> gradient;

  @override
  State<_StatPill> createState() => _StatPillState();
}

class _StatPillState extends State<_StatPill> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.last.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            height: 1.0,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(widget.label,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 12,
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Quick Action 2×2 Grid ────────────────────────────────────────────────────
class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid();

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final actions = [
      _ActionData(l10n.writeJournal, l10n.expressYourself,
          Icons.edit_note_rounded, _cardColors[0],
          () => context.push(AdolescentRoutes.newJournal)),
      _ActionData(l10n.aiCompanion, l10n.talkItOut,
          Icons.smart_toy_rounded, _cardColors[1],
          () => context.push(AdolescentRoutes.aiChat)),
      _ActionData(l10n.checkYourMood, l10n.moodEmojiPrompt,
          Icons.mood_rounded, _cardColors[2],
          () => context.go(AdolescentRoutes.mood)),
      _ActionData(l10n.learnAndGrow, l10n.exploreResources,
          Icons.lightbulb_rounded, _cardColors[3],
          () => context.push(AdolescentRoutes.learn)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(l10n.quickActions,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _kBody)),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: actions.map((a) => _ActionCard(data: a)).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  const _ActionData(this.title, this.sub, this.icon, this.colors, this.onTap);
  final String title, sub;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;
}

class _ActionCard extends StatefulWidget {
  const _ActionCard({required this.data});
  final _ActionData data;

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.data.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.data.colors.first.withValues(alpha: 0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.data.colors.first.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.data.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: widget.data.colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(widget.data.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.data.title,
                        style: const TextStyle(
                            color: _kBody,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.1),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(widget.data.sub,
                        style: const TextStyle(
                            color: _kSubtle, fontSize: 10, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recent Journals ──────────────────────────────────────────────────────────
class _RecentJournals extends ConsumerWidget {
  const _RecentJournals({required this.ref});
  final WidgetRef ref;

  String _daysAgo(BuildContext context, DateTime dt) {
    final l10n = context.localizations;
    final d = DateTime.now().difference(dt).inDays;
    if (d == 0) return l10n.journalToday;
    if (d == 1) return l10n.journalYesterday;
    return l10n.daysAgo(d);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(adolescentDashboardControllerProvider);
    final l10n = context.localizations;

    return dashAsync.maybeWhen(
      data: (state) {
        final journals = state.data?.recentJournals ?? [];
        if (journals.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(l10n.recentJournals,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _kBody)),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.go(AdolescentRoutes.journal),
                    child: Text(l10n.viewAll,
                        style: const TextStyle(
                            fontSize: 12,
                            color: _kPurple,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...journals.take(3).map((entry) => _JournalRow(
                    entry: entry,
                    daysAgo: _daysAgo(context, entry.createdAt),
                    onTap: () => context.push(
                        '${AdolescentRoutes.journal}/${entry.id}'),
                  )),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _JournalRow extends StatefulWidget {
  const _JournalRow({
    required this.entry,
    required this.daysAgo,
    required this.onTap,
  });
  final RecentJournal entry;
  final String daysAgo;
  final VoidCallback onTap;

  @override
  State<_JournalRow> createState() => _JournalRowState();
}

class _JournalRowState extends State<_JournalRow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kPurple.withValues(alpha: 0.12), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: _kPurple.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0)
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kSurfaceVariant, _kSurfaceVariant.withValues(alpha: 0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _kPurple.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: widget.entry.mood != null
                      ? Text(widget.entry.mood!.emoji,
                          style: const TextStyle(fontSize: 24))
                      : const Icon(Icons.menu_book_rounded,
                          color: _kPurple, size: 24),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.entry.title ?? l10n.journalEntryDefault,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _kBody,
                          letterSpacing: 0.1),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.daysAgo +
                          (widget.entry.mood != null
                              ? '  ·  ${l10n.feelingLabel(widget.entry.mood!.label)}'
                              : ''),
                      style: const TextStyle(fontSize: 11, color: _kSubtle, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _kSurfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.chevron_right_rounded, color: _kPurple, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Insights Banner ──────────────────────────────────────────────────────────
class _InsightsBanner extends ConsumerWidget {
  const _InsightsBanner({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(adolescentAlertsControllerProvider);

    return alertsAsync.maybeWhen(
      data: (state) {
        final alerts = state.alerts;
        if (alerts.isEmpty) return const SizedBox.shrink();
        
        // Sort alerts by created_at (most recent first) and prioritize unread
        final sortedAlerts = [...alerts];
        sortedAlerts.sort((a, b) {
          // First, prioritize unread alerts
          if (!a.viewedStatus && b.viewedStatus) return -1;
          if (a.viewedStatus && !b.viewedStatus) return 1;
          
          // Then sort by creation date (most recent first)
          return b.createdAt.compareTo(a.createdAt);
        });
        
        final alert = sortedAlerts.first;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: GestureDetector(
            onTap: () => context.push(
                '${AdolescentRoutes.alerts}/${alert.alertId}',
                extra: alert),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E35B1), Color(0xFF7C4DFF), Color(0xFF9C6FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _kDeepPurple.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Stack(
                children: [
                  // Decorative orb
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  // Content
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(context.localizations.personalInsight,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.2),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(context.localizations.weGotYou,
                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              alert.triggerDescription,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ─── Learning Card ────────────────────────────────────────────────────────────
class _LearningCard extends ConsumerWidget {
  const _LearningCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(adolescentRecommendationsControllerProvider);

    return recsAsync.maybeWhen(
      data: (state) {
        if (state.recommendations.isEmpty) return const SizedBox.shrink();
        final rec = state.recommendations.first;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFFA5D6A7)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(context.localizations.tryThisToday,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: _kBody)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.push(AdolescentRoutes.learn),
                    child: Text(context.localizations.more,
                        style: const TextStyle(
                            fontSize: 12,
                            color: _kPurple,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push(AdolescentRoutes.learn),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color(0xFF66BB6A).withValues(alpha: 0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                          spreadRadius: 0)
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFFA5D6A7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF66BB6A).withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF66BB6A).withValues(alpha: 0.15),
                                    const Color(0xFFA5D6A7).withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(context.localizations.recommendedForYou.toUpperCase(),
                                  style: const TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF66BB6A))),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              rec.page.title,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: _kBody,
                                  letterSpacing: 0.1),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              rec.reason,
                              style: const TextStyle(
                                  fontSize: 12, color: _kSubtle, fontWeight: FontWeight.w500, height: 1.4),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _kSurfaceVariant,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.access_time_rounded,
                                            size: 12, color: _kPurple),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            context.localizations.minRead(2),
                                            style: const TextStyle(
                                                fontSize: 11, color: _kPurple, fontWeight: FontWeight.w700),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF66BB6A), Color(0xFFA5D6A7)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            context.localizations.readNow,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

// ─── SAGE AI FAB ──────────────────────────────────────────────────────────────
class _SageAIButton extends StatefulWidget {
  const _SageAIButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SageAIButton> createState() => _SageAIButtonState();
}

class _SageAIButtonState extends State<_SageAIButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A1FDB), _kPurple, _kLavender],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: const [NeuroShadows.adolescentGlow],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 28),
              Positioned(
                top: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x22000000), blurRadius: 4)
                    ],
                  ),
                  child: Text(context.localizations.ai,
                      style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          color: _kPurple)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Play & Relax Section ─────────────────────────────────────────────────────
class _PlayRelaxSection extends StatelessWidget {
  const _PlayRelaxSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFA726), Color(0xFFFF7043)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.videogame_asset_rounded, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.playAndRelax,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _kBody)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFECE0), Color(0xFFFFE0CC)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFF8C00).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(l10n.newTag,
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF8C00),
                        letterSpacing: 1.2)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFF7043), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7043).withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                )
              ],
            ),
            child: Stack(
              children: [
                // Decorative elements
                Positioned(
                  top: -15,
                  right: -15,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -10,
                  left: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                // Content
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.mindfulnessGames,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.boostYourMood,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () => context.push(AdolescentRoutes.activities),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFFF7043),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.playNow,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.play_arrow_rounded, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.videogame_asset_rounded,
                          color: Colors.white, size: 50),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton Loading Widgets ──────────────────────────────────────────────────

class _HeroAppBarSkeleton extends StatelessWidget {
  const _HeroAppBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _kPurple,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1FDB), Color(0xFF7C4DFF), Color(0xFFB47CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Padding(
                 padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 40, 20, 0),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     NeuroShimmer(
                       child: Container(
                         width: 100,
                         height: 24,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(20),
                         ),
                       ),
                     ),
                     NeuroShimmer(
                       child: Container(
                         width: 32,
                         height: 32,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           shape: BoxShape.circle,
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
               const Spacer(),
               Padding(
                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     NeuroShimmer(
                       child: Container(
                         width: 100,
                         height: 14,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(6),
                         ),
                       ),
                     ),
                     const SizedBox(height: 8),
                     NeuroShimmer(
                       child: Container(
                         width: 160,
                         height: 36,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(12),
                         ),
                       ),
                     ),
                     const SizedBox(height: 16),
                     NeuroShimmer(
                       child: Container(
                         width: 200,
                         height: 16,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(6),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ],
          ),
        ),
      ),
    );
  }
}

class _DailyCheckInCardSkeleton extends StatelessWidget {
  const _DailyCheckInCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: _SkeletonBox(height: 180, borderRadius: 24),
    );
  }
}

class _MoodCheckInRowSkeleton extends StatelessWidget {
  const _MoodCheckInRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (_) => 
          const Column(
            children: [
              _SkeletonCircle(radius: 28),
              SizedBox(height: 6),
              _SkeletonBox(width: 40, height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _StatPillSkeleton()),
          const SizedBox(width: 10),
          Expanded(child: _StatPillSkeleton()),
          const SizedBox(width: 10),
          Expanded(child: _StatPillSkeleton()),
        ],
      ),
    );
  }
}

class _StatPillSkeleton extends StatelessWidget {
  const _StatPillSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[300]!, Colors.grey[200]!],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
    );
  }
}

class _QuickActionGridSkeleton extends StatelessWidget {
  const _QuickActionGridSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(width: 180, height: 20),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ActionCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _ActionCardSkeleton()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _ActionCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _ActionCardSkeleton()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCardSkeleton extends StatelessWidget {
  const _ActionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _RecentJournalsSkeleton extends StatelessWidget {
  const _RecentJournalsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(width: 180, height: 20),
          const SizedBox(height: 12),
          ...List.generate(3, (_) => 
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _SkeletonBox(height: 80, borderRadius: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightsBannerSkeleton extends StatelessWidget {
  const _InsightsBannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[300]!, Colors.purple[400]!],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: _SkeletonCircle(radius: 32, color: Colors.white24),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _SkeletonBox(width: 160, height: 18),
                  SizedBox(height: 6),
                  _SkeletonBox(width: 220, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LearningCardSkeleton extends StatelessWidget {
  const _LearningCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: _SkeletonBox(width: 200, height: 20),
        ),
      ),
    );
  }
}

class _PlayRelaxSectionSkeleton extends StatelessWidget {
  const _PlayRelaxSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[300]!, Colors.orange[400]!],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: _SkeletonBox(width: 180, height: 24),
        ),
      ),
    );
  }
}

 class _SkeletonBox extends StatelessWidget {
   const _SkeletonBox({
     this.width,
     this.height,
     this.borderRadius = 0,
   });

   final double? width, height;
   final double borderRadius;

   @override
   Widget build(BuildContext context) {
     return NeuroShimmer(
       child: Container(
         width: width,
         height: height,
         decoration: BoxDecoration(
           color: Colors.grey[300],
           borderRadius: BorderRadius.circular(borderRadius),
         ),
       ),
     );
   }
 }

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.radius, this.color});

  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: color ?? Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
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
