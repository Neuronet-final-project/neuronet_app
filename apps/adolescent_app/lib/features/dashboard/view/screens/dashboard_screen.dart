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
const _kBlue     = Color(0xFF64B5F6);
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
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _HeroAppBar(ref: ref),
            const SliverToBoxAdapter(child: _DailyCheckInCard()),
            SliverToBoxAdapter(child: _MoodCheckInRow(ref: ref)),
            SliverToBoxAdapter(child: _StatsRow(ref: ref)),
            SliverToBoxAdapter(child: _QuickActionGrid()),
            SliverToBoxAdapter(child: _RecentJournals(ref: ref)),
            SliverToBoxAdapter(child: _InsightsBanner(ref: ref)),
            SliverToBoxAdapter(child: _LearningCard(ref: ref)),
            const SliverToBoxAdapter(child: _PlayRelaxSection()),
          ],
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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        print('[Dashboard] Unread insights count: $count / ${s.alerts.length} total');
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
                            child: const Row(
                              children: [
                                Icon(Icons.self_improvement_rounded,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 5),
                                Text('ADOLESCENT',
                                    style: TextStyle(
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
                        _greeting.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hey $name 👋',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "How's your inner world today?",
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
        title: const Text('NeuroNet',
          style: TextStyle(
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
class _DailyCheckInCard extends StatelessWidget {
  const _DailyCheckInCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'A small check-in goes a long way.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280), // Neutral grey
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF4D4D), // Vibrant red
                  Color(0xFFFE6885), // Pinkish red
                  Color(0xFF7C4DFF), // Purple
                  Color(0xFF5E35B1), // Deep purple
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Take 30 seconds.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Naming what you feel is half the work.\nWe\'ll help with the rest.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go(AdolescentRoutes.mood),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5E35B1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Check in now',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('How are you feeling?',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _kBody)),
              GestureDetector(
                onTap: () => context.go(AdolescentRoutes.mood),
                child: const Text('All moods →',
                    style: TextStyle(
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
                        mood.label,
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
        final data = state.data;
        final journals = data?.totalJournals ?? 0;
        final moods = data?.totalMoods ?? 0;
        final recs = data?.educationalRecommendations.length ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              _StatPill(label: 'Journals', value: '$journals', icon: Icons.menu_book_rounded,
                  gradient: const [Color(0xFFA875FF), Color(0xFF8D53FF)]),
              const SizedBox(width: 10),
              _StatPill(label: 'Moods', value: '$moods', icon: Icons.sentiment_very_satisfied_rounded,
                  gradient: const [Color(0xFF38C7F0), Color(0xFF4DB0F6)]),
              const SizedBox(width: 10),
              _StatPill(label: 'For You', value: '$recs', icon: Icons.school_rounded,
                  gradient: const [Color(0xFFFF8A49), Color(0xFFFF9F49)]),
            ],
          ),
        );
      },
      orElse: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: LinearProgressIndicator(color: _kPurple, backgroundColor: _kSurfaceVariant),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.1,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 1),
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
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
    final actions = [
      _ActionData('Write Journal', 'Express yourself 📝',
          Icons.edit_note_rounded, _cardColors[0],
          () => context.push(AdolescentRoutes.newJournal)),
      _ActionData('AI Companion', 'Talk it out 🤖',
          Icons.smart_toy_rounded, _cardColors[1],
          () => context.push(AdolescentRoutes.aiChat)),
      _ActionData('Counselor', 'Human support 💬',
          Icons.support_agent_rounded, _cardColors[2],
          () => context.push(AdolescentRoutes.counselorChat)),
      _ActionData('Learn & Grow', 'Explore resources 📚',
          Icons.lightbulb_rounded, _cardColors[3],
          () => context.push(AdolescentRoutes.learn)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('Quick Actions',
                style: TextStyle(
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.data.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: widget.data.colors.first.withValues(alpha: 0.15)),
            boxShadow: [
              BoxShadow(
                color: widget.data.colors.first.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.data.colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(widget.data.icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.data.title,
                        style: TextStyle(
                            color: _kBody,
                            fontSize: 13,
                            fontWeight: FontWeight.w800),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    Text(widget.data.sub,
                        style: const TextStyle(
                            color: _kSubtle, fontSize: 10),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
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

  String _daysAgo(DateTime dt) {
    final d = DateTime.now().difference(dt).inDays;
    if (d == 0) return 'Today';
    if (d == 1) return 'Yesterday';
    return '$d days ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(adolescentDashboardControllerProvider);

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
                  const Text('Recent Journals',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _kBody)),
                  GestureDetector(
                    onTap: () => context.go(AdolescentRoutes.journal),
                    child: const Text('View all →',
                        style: TextStyle(
                            fontSize: 12,
                            color: _kPurple,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...journals.take(3).map((entry) => _JournalRow(
                    entry: entry,
                    daysAgo: _daysAgo(entry.createdAt),
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

class _JournalRow extends StatelessWidget {
  const _JournalRow({
    required this.entry,
    required this.daysAgo,
    required this.onTap,
  });
  final RecentJournal entry;
  final String daysAgo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kPurple.withValues(alpha: 0.08)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _kSurfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: entry.mood != null
                    ? Text(entry.mood!.emoji,
                        style: const TextStyle(fontSize: 22))
                    : const Icon(Icons.menu_book_rounded,
                        color: _kPurple, size: 22),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title ?? 'Journal Entry',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kBody),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    daysAgo +
                        (entry.mood != null
                            ? '  ·  Feeling ${entry.mood!.label}'
                            : ''),
                    style: const TextStyle(fontSize: 11, color: _kSubtle),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _kSubtle),
          ],
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
        final alert = alerts.first;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: GestureDetector(
            onTap: () => context.push(
                '${AdolescentRoutes.alerts}/${alert.alertId}',
                extra: alert),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5E35B1), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _kDeepPurple.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Personal Insight ✨',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("We've got you 💙",
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.triggerDescription,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 14),
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
  const _LearningCard({required this.ref});
  final WidgetRef ref;

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
                  const Text('Try This Today',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _kBody)),
                  GestureDetector(
                    onTap: () => context.push(AdolescentRoutes.recommendations),
                    child: const Text('More →',
                        style: TextStyle(
                            fontSize: 12,
                            color: _kPurple,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push(AdolescentRoutes.recommendations),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _kPurple.withValues(alpha: 0.12)),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 10,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF66BB6A), Color(0xFFA5D6A7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.lightbulb_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _kSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('RECOMMENDED',
                                  style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w700,
                                      color: _kPurple)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              rec.page.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: _kBody),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              rec.reason,
                              style: const TextStyle(
                                  fontSize: 12, color: _kSubtle),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 12, color: _kSubtle),
                                const SizedBox(width: 3),
                                const Text('2 min read',
                                    style: TextStyle(
                                        fontSize: 11, color: _kSubtle)),
                                const Spacer(),
                                Text('Read now →',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: _kPurple,
                                        fontWeight: FontWeight.w600)),
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
                  child: const Text('AI',
                      style: TextStyle(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Play & Relax',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _kBody)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECE0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('NEW',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFF8C00),
                        letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFA726), Color(0xFFFF7043), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF7043).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mindfulness Games',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Boost your mood with fun, science-backed activities.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push(AdolescentRoutes.activities),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFFF7043),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Play Now',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.videogame_asset_rounded,
                      color: Colors.white, size: 48),
                ),
              ],
            ),
          ),
        ],
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
