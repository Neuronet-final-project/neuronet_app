import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';

class ChannelPostDetailScreen extends ConsumerStatefulWidget {
  const ChannelPostDetailScreen({
    super.key,
    required this.channelId,
    required this.postId,
  });

  final String channelId;
  final String postId;

  @override
  ConsumerState<ChannelPostDetailScreen> createState() =>
      _ChannelPostDetailScreenState();
}

class _ChannelPostDetailScreenState
    extends ConsumerState<ChannelPostDetailScreen> {
  bool _isLoading = true;
  String? _error;
  ChannelPost? _post;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final service = ref.read(channelServiceProvider);
    final normalizedPostId = Uri.decodeComponent(widget.postId).replaceAll('/', '');
    final result = await service.getPost(widget.channelId, normalizedPostId);
    if (!mounted) return;
    result.when(
      success: (value) {
        setState(() {
          _post = value;
          _isLoading = false;
        });
      },
      failure: (f) {
        setState(() {
          _error = f.message;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuroColors.adolescentSurface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1FDB),
        foregroundColor: Colors.white,
        title: const Text(
          'Post',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: NeuroColors.adolescentPrimary,
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: NeuroErrorWidget(
                      message: _error!,
                      onRetry: _loadPost,
                    ),
                  ),
                )
              : _post == null
                  ? const SizedBox.shrink()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFD7C5EE)),
                          boxShadow: [
                            BoxShadow(
                              color: NeuroColors.adolescentPrimary.withValues(alpha: 0.1),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      NeuroColors.adolescentPrimary.withValues(alpha: 0.2),
                                  child: Text(
                                    (_post!.counselorName ?? 'C')
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: NeuroColors.adolescentPrimaryDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _post!.counselorName ?? 'Counselor',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF2C1C5F),
                                        ),
                                      ),
                                      Text(
                                        _post!.createdAt
                                            .toLocal()
                                            .toString()
                                            .split(' ')
                                            .first,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8A7DAC),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              _post!.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 22,
                                color: Color(0xFF2C1C5F),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _post!.content,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Color(0xFF4F3F7C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}
