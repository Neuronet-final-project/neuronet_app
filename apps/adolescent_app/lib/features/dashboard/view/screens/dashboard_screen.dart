import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(adolescentDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Emotional Health'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adolescentDashboardProvider.future),
        child: dashboardAsync.when(
          data: (data) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeHeader(context),
                _buildTrendSection(context, data),
                _buildStatsGrid(context, data),
                _buildActionCards(context),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hi Alex,',
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
    return NeuroDashboardCard(
      title: 'Emotional Trend',
      subtitle: 'Last 7 days',
      height: 300,
      child: NeuroTrendChart(trends: data.trends),
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
            label: 'Journal Entries',
            value: data.totalJournals.toString(),
            icon: Icons.book,
            color: Colors.blue,
          ),
          _StatCard(
            label: 'Mood Records',
            value: data.totalMoodEntries.toString(),
            icon: Icons.mood,
            color: Colors.orange,
          ),
          _StatCard(
            label: 'Active Alerts',
            value: data.activeAlerts.toString(),
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
          ),
          _StatCard(
            label: 'Unread Messages',
            value: data.unreadMessages.toString(),
            icon: Icons.message_outlined,
            color: Colors.green,
          ),
        ],
      ),
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
            onTap: () {},
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
            onTap: () {},
          ),
        ],
      ),
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
    return Container(
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
    );
  }
}
