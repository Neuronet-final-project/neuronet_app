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

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Emotional Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            onPressed: () => context.push(AdolescentRoutes.alerts),
            tooltip: 'View insights',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adolescentDashboardProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(context, ref),
              _buildMoodCheckIn(context, ref),
              _buildDataSection(context, ref),
              _buildInsightsSnippet(context, ref),
              _buildLearningSnippet(context, ref),
              _buildActionCards(context),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AdolescentRoutes.aiChat),
        backgroundColor: NeuroColors.adolescentPrimary,
        icon: const Icon(Icons.assistant, color: Colors.white),
        label: const Text('AI Assistant', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(adolescentProfileControllerProvider);
    final name = profileAsync.maybeWhen(
      data: (user) => user.fullName.split(' ')[0],
      orElse: () => 'there',
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi $name,',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's how you've been feeling lately.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: NeuroColors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendSection(BuildContext context, DashboardData data) {
    if (data.moodDistribution.isEmpty) return const SizedBox.shrink();

    return NeuroDashboardCard(
      title: 'Mood Distribution',
      subtitle: 'Recent check-ins',
      height: null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: data.moodDistribution.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('${entry.value} entries'),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, DashboardData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _StatCard(
            label: 'Recent Journals',
            value: data.recentJournals.length.toString(),
            icon: Icons.book,
            color: NeuroColors.moodSad,
          ),
          _StatCard(
            label: 'Mood Variants',
            value: data.moodDistribution.length.toString(),
            icon: Icons.mood,
            color: NeuroColors.moodAnxious,
          ),
          _StatCard(
            label: 'Recommendations',
            value: data.educationalRecommendations.length.toString(),
            icon: Icons.school,
            color: NeuroColors.adolescentPrimary,
          ),
          _StatCard(
            label: 'Active Streak',
            value: '3', // Mock for now until backend adds it
            icon: Icons.local_fire_department,
            color: NeuroColors.alertHigh,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCheckIn(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            'How are you feeling right now?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: MoodType.values.length,
            itemBuilder: (context, index) {
              final mood = MoodType.values[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    ref.read(moodControllerProvider.notifier).selectMood(mood);
                    context.go(AdolescentRoutes.mood);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mood.label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: NeuroColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecentJournals(BuildContext context, DashboardData data) {
    if (data.recentJournals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Journals',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AdolescentRoutes.journal),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        Column(
          children: data.recentJournals.map((entry) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: NeuroColors.adolescentSurface,
                  child: Text(
                    entry.mood?.emoji ?? '📔',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                title: Text(entry.title ?? 'Journal Entry', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Mood: ${entry.mood?.label ?? 'Unspecified'}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: NeuroColors.adolescentSurface,
              child: Icon(Icons.add, color: NeuroColors.adolescentPrimary),
            ),
            title: const Text('Add Journal Entry'),
            subtitle: const Text('How was your day?'),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.white,
            onTap: () => context.push(AdolescentRoutes.newJournal),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: NeuroColors.adolescentSurface,
              child: Icon(Icons.chat_bubble_outline, color: NeuroColors.adolescentPrimary),
            ),
            title: const Text('Chat with AI'),
            subtitle: const Text('Get support anytime'),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.white,
            onTap: () => context.push(AdolescentRoutes.aiChat),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: NeuroColors.adolescentSurface,
              child: Icon(Icons.person_outline, color: NeuroColors.adolescentPrimary),
            ),
            title: const Text('Chat with Counselor'),
            subtitle: const Text('Message your human counselor'),
            trailing: const Icon(Icons.chevron_right),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.white,
            onTap: () => context.push(AdolescentRoutes.counselorChat),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adolescentDashboardProvider);

    return dashboardAsync.when(
      data: (data) {
        final isFallback = data.recentJournals.isEmpty && data.moodDistribution.isEmpty;

        return Column(
          children: [
            if (isFallback)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: NeuroEmptyState(
                  isMini: true,
                  title: 'Data Unavailable',
                  message: 'Activity data is currently unavailable. Quick Actions are active.',
                  icon: Icons.cloud_off,
                  color: Colors.orange,
                ),
              ),
            _buildTrendSection(context, data),
            _buildStatsGrid(context, data),
            _buildRecentJournals(context, data),
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(16),
        child: NeuroErrorWidget(
          message: 'Dashboard data failed to load.',
          onRetry: () => ref.invalidate(adolescentDashboardProvider),
        ),
      ),
    );
  }

  Widget _buildInsightsSnippet(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(adolescentAlertsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Insights',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push(AdolescentRoutes.alerts),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        alertsAsync.when(
          data: (alerts) {
            if (alerts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NeuroEmptyState(
                  isMini: true,
                  title: 'No Insights Yet',
                  message: 'Keep journaling to unlock patterns and deeper insights!',
                  icon: Icons.insights_rounded,
                  color: theme.primaryColor,
                ),
              );
            }
            final recentAlerts = alerts.take(2).toList();
            return Column(
              children: recentAlerts.map((alert) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
                    ),
                    title: Text(alert.alertType, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(alert.triggerDescription, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => context.push('${AdolescentRoutes.alerts}/${alert.alertId}', extra: alert),
                  ),
                ),
              )).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildLearningSnippet(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(adolescentRecommendationsProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Learning Nook',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.push(AdolescentRoutes.learn),
                child: const Text('Explore'),
              ),
            ],
          ),
        ),
        recommendationsAsync.when(
          data: (recs) {
            if (recs.isEmpty) return const SizedBox.shrink();
            final topRec = recs.first;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    'Picked for You',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        topRec.reason,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Read: ${topRec.page.title}'),
                    ],
                  ),
                  onTap: () => context.push(AdolescentRoutes.recommendations),
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 24),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: NeuroColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
