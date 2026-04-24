import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../../../config/router/app_router.dart';
import '../../providers/channels_provider.dart';

class ChannelsScreen extends ConsumerStatefulWidget {
  const ChannelsScreen({super.key});

  @override
  ConsumerState<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends ConsumerState<ChannelsScreen> {
  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelsControllerProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: NeuroColors.adolescentSurface,
        appBar: AppBar(
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Counselor Channels',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF6A1FDB),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => ref.read(channelsControllerProvider.notifier).refresh(),
              tooltip: 'Refresh channels',
            ),
          ],
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.72),
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            indicatorColor: Colors.white,
            indicatorWeight: 3.2,
            tabs: const [
              Tab(child: Text('Your Channels')),
              Tab(child: Text('Discover')),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF2ECFF),
                      NeuroColors.adolescentSurface,
                      const Color(0xFFE8DCF9).withValues(alpha: 0.45),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: 8,
              child: Icon(Icons.circle, size: 110, color: NeuroColors.adolescentPrimary.withValues(alpha: 0.14)),
            ),
            channelsAsync.when(
          data: (state) {
            if (state.error != null) {
              return NeuroErrorWidget(
                message: state.error!,
                onRetry: () => ref.read(channelsControllerProvider.notifier).refresh(),
              );
            }

            final channels = state.channels;
            final followedChannels = channels.where((c) => c.isFollowed).toList();
            final availableChannels = channels.where((c) => !c.isFollowed).toList();

            return RefreshIndicator(
              onRefresh: () async {
                return ref.read(channelsControllerProvider.notifier).refresh();
              },
              child: TabBarView(
                children: [
                  _buildChannelList(
                    context,
                    ref,
                    followedChannels,
                    allCount: channels.length,
                    followedCount: followedChannels.length,
                    isYourTab: true,
                  ),
                  _buildChannelList(
                    context,
                    ref,
                    availableChannels,
                    allCount: channels.length,
                    followedCount: followedChannels.length,
                    isYourTab: false,
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: NeuroColors.adolescentPrimary),
          ),
          error: (err, stack) => NeuroErrorWidget(
            message: 'Error loading channels: $err',
            onRetry: () => ref.read(channelsControllerProvider.notifier).refresh(),
          ),
        ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelList(
    BuildContext context,
    WidgetRef ref,
    List<Channel> channels, {
    required int allCount,
    required int followedCount,
    required bool isYourTab,
  }) {
    final discoverCount = allCount - followedCount;
    final shownCount = isYourTab ? followedCount : discoverCount;

    if (channels.isEmpty) {
      return _buildEmptyState(context, isYourTab);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
      itemCount: channels.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEAD9FF), Color(0xFFE2CCFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
              boxShadow: [
                BoxShadow(
                  color: NeuroColors.adolescentPrimary.withValues(alpha: 0.14),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _StatChip(label: 'Total', value: '$allCount'),
                const SizedBox(width: 8),
                _StatChip(
                  label: 'Following',
                  value: '$followedCount',
                  backgroundColor: const Color(0xFFE7F8F0),
                  borderColor: const Color(0xFFC9EEDB),
                  valueColor: const Color(0xFF1B7A4E),
                  labelColor: const Color(0xFF2C8A5D),
                ),
                const SizedBox(width: 8),
                _StatChip(
                  label: isYourTab ? 'In this tab' : 'Discover',
                  value: '$shownCount',
                  backgroundColor: const Color(0xFFFFF0DE),
                  borderColor: const Color(0xFFFFE0B8),
                  valueColor: const Color(0xFF9A4C00),
                  labelColor: const Color(0xFFB15B00),
                ),
              ],
            ),
          );
        }
        final channel = channels[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildChannelCard(context, ref, channel),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isYourChannelsTab) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isYourChannelsTab ? Icons.subscriptions_outlined : Icons.explore_outlined,
              size: 80,
              color: NeuroColors.adolescentPrimary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),
            Text(
              isYourChannelsTab ? 'No channels yet' : 'No channels to discover',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2C1C5F),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isYourChannelsTab
                  ? 'Follow channels from the Discover tab\nto see them here.'
                  : 'Check back later for new channels!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6A5C9A),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isYourChannelsTab) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  DefaultTabController.of(context).animateTo(0);
                },
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Go to Your Channels'),
                style: FilledButton.styleFrom(
                  backgroundColor: NeuroColors.adolescentPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChannelCard(
    BuildContext context,
    WidgetRef ref,
    Channel channel,
  ) {
    final typeText = switch (channel.channelType) {
      ChannelType.educational => 'Educational',
      ChannelType.supportive => 'Support',
      ChannelType.discussion => 'Discussion',
      ChannelType.resourceLibrary => 'Resources',
    };
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('${AdolescentRoutes.channels}/${channel.channelId}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE0D3F2)),
            boxShadow: [
              BoxShadow(
                color: NeuroColors.adolescentPrimary.withValues(alpha: 0.09),
                blurRadius: 18,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: NeuroColors.adolescentPrimary.withValues(alpha: 0.22),
                child: Text(
                  channel.channelName.isEmpty ? 'C' : channel.channelName[0].toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: NeuroColors.adolescentPrimaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.channelName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C1C5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel.description?.isNotEmpty == true
                          ? channel.description!
                          : 'Safe space for counselor guidance and updates.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6A5C9A),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _MetaBadge(icon: Icons.people_alt_rounded, text: '${channel.subscriberCount}'),
                        _MetaBadge(icon: Icons.sell_rounded, text: typeText),
                        if (channel.isActive)
                          const _MetaBadge(
                            icon: Icons.schedule_rounded,
                            text: 'Active',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () => ref.read(channelsControllerProvider.notifier).toggleFollow(channel.channelId),
                style: FilledButton.styleFrom(
                  backgroundColor: channel.isFollowed
                      ? const Color(0xFFD9C1FF)
                      : const Color(0xFFEDE2FF),
                  foregroundColor: const Color(0xFF4A2A8A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                child: Text(
                  channel.isFollowed ? 'Following' : 'Follow',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    this.backgroundColor = const Color(0xFFE9E0FF),
    this.borderColor = const Color(0xFFD7C9F5),
    this.valueColor = const Color(0xFF2C1C5F),
    this.labelColor = const Color(0xFF6B5A9D),
  });
  final String label;
  final String value;
  final Color backgroundColor;
  final Color borderColor;
  final Color valueColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: valueColor,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E5FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: NeuroColors.adolescentPrimaryDark),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5C4598),
            ),
          ),
        ],
      ),
    );
  }
}
