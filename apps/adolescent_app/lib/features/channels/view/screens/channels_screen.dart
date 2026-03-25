import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/channels_provider.dart';
import '../widgets/channel_card.dart';

class ChannelsScreen extends ConsumerWidget {
  const ChannelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channelsAsync = ref.watch(channelsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counselor Channels'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: channelsAsync.when(
        data: (channels) => RefreshIndicator(
          onRefresh: () async => ref.refresh(channelsControllerProvider.future),
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: channels.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final channel = channels[index];
              return ChannelCard(
                channel: channel,
                onTap: () => context.push('/channels/${channel.channelId}'),
                onFollowToggle: () => ref
                    .read(channelsControllerProvider.notifier)
                    .toggleFollow(channel.channelId),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading channels: $err')),
      ),
    );
  }
}
