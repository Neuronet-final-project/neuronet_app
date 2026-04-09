import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/channels_provider.dart';
import '../widgets/channel_card.dart';

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
        appBar: AppBar(
          title: const Text('Counselor Channels'),
          bottom: TabBar(
            labelColor: Theme.of(context).colorScheme.onPrimaryContainer,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs: const [
              Tab(child: Text('Your Channels')),
              Tab(child: Text('Discover')),
            ],
          ),
        ),
        body: channelsAsync.when(
          data: (channels) {
            print('DEBUG: [ChannelsScreen] Rendering ${channels.length} channels');
            
            final followedChannels = channels.where((c) => c.isFollowed).toList();
            final availableChannels = channels.where((c) => !c.isFollowed).toList();

            return RefreshIndicator(
              onRefresh: () async {
                print('DEBUG: [ChannelsScreen] Refreshing channels');
                return ref.refresh(channelsControllerProvider.future);
              },
              child: TabBarView(
                children: [
                  // Tab 1: Your Channels
                  _buildChannelList(context, ref, followedChannels, isEmpty: true),
                  // Tab 2: Discover Channels
                  _buildChannelList(context, ref, availableChannels, isEmpty: false),
                ],
              ),
            );
          },
          loading: () {
            print('DEBUG: [ChannelsScreen] Loading channels...');
            return const Center(child: CircularProgressIndicator());
          },
          error: (err, stack) {
            print('DEBUG: [ChannelsScreen] Error: $err\nStack: $stack');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading channels',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      print('DEBUG: [ChannelsScreen] Retrying load');
                      ref.invalidate(channelsControllerProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChannelList(
    BuildContext context,
    WidgetRef ref,
    List<Channel> channels, {
    required bool isEmpty,
  }) {
    if (channels.isEmpty) {
      return _buildEmptyState(context, isEmpty);
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: channels.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return _buildChannelCard(context, ref, channel);
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
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              isYourChannelsTab ? 'No channels yet' : 'No channels to discover',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              isYourChannelsTab
                  ? 'Follow channels from the Discover tab\nto see them here.'
                  : 'Check back later for new channels!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
            ),
            if (!isYourChannelsTab) ...[
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () {
                  DefaultTabController.of(context).animateTo(0);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go to Your Channels'),
                style: OutlinedButton.styleFrom(
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
    print('DEBUG: [ChannelsScreen] Building card for channel: ${channel.channelName} (followed: ${channel.isFollowed})');
    return ChannelCard(
      channel: channel,
      onTap: () {
        print('DEBUG: [ChannelsScreen] Navigating to channel: ${channel.channelId}');
        context.push('/channels/${channel.channelId}');
      },
      onFollowToggle: () {
        print('DEBUG: [ChannelsScreen] Toggle follow for: ${channel.channelId}');
        ref.read(channelsControllerProvider.notifier).toggleFollow(channel.channelId);
      },
    );
  }
}
