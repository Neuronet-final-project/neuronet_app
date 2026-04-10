import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/channels_provider.dart';

class ChannelDetailScreen extends ConsumerWidget {
  final String channelId;

  const ChannelDetailScreen({super.key, required this.channelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[ChannelDetailScreen] Building for channelId: $channelId');
    final channelsAsync = ref.watch(channelsControllerProvider);

    // Find channel info to show in the header
    final channel = channelsAsync.value?.firstWhere(
      (c) => c.channelId == channelId,
      orElse: () {
        debugPrint('[ChannelDetailScreen] Channel not found in list, using fallback');
        return Channel(
          channelId: channelId,
          channelName: 'Channel',
          counselorId: '',
          channelType: ChannelType.educational,
          createdAt: DateTime.now(),
        );
      },
    );

    debugPrint('[ChannelDetailScreen] Channel loaded: ${channel?.channelName ?? 'unknown'}, followed: ${channel?.isFollowed ?? false}');

    return Scaffold(
      appBar: AppBar(
        title: Text(channel?.channelName ?? 'Channel'),
        actions: [
          IconButton(
            icon: Icon(channel?.isFollowed == true ? Icons.check_circle : Icons.add_circle_outline),
            onPressed: () => ref
                .read(channelsControllerProvider.notifier)
                .toggleFollow(channelId),
            tooltip: channel?.isFollowed == true ? 'Following channel' : 'Follow channel',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ..._buildDescriptionSection(context, channel),
          Text(
            '${channel?.subscriberCount ?? 0} members',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => ref
                  .read(channelsControllerProvider.notifier)
                  .toggleFollow(channelId),
              icon: Icon(
                channel?.isFollowed == true
                    ? Icons.check_circle
                    : Icons.add_circle_outline,
              ),
              label: Text(
                channel?.isFollowed == true ? 'Following' : 'Follow Channel',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDescriptionSection(BuildContext context, Channel? channel) {
    final description = channel?.description;
    if (description == null || description.isEmpty) {
      return [];
    }
    
    return [
      Text(
        'About',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 8),
      Text(
        description,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.5,
            ),
      ),
      const SizedBox(height: 24),
    ];
  }
}
