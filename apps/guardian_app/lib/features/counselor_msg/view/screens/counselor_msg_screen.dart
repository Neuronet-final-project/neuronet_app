import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:intl/intl.dart';
import 'package:guardian_app/features/counselor_msg/providers/counselor_chat_provider.dart';

class CounselorMsgScreen extends ConsumerStatefulWidget {
  final String adolescentId;
  final String adolescentName;

  const CounselorMsgScreen({
    super.key,
    required this.adolescentId,
    required this.adolescentName,
  });

  @override
  ConsumerState<CounselorMsgScreen> createState() => _CounselorMsgScreenState();
}

class _CounselorMsgScreenState extends ConsumerState<CounselorMsgScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(counselorChatControllerProvider(widget.adolescentId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Counselor Messaging'),
            Text(
              'Regarding: ${widget.adolescentName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: chatAsync.when(
        data: (state) {
          if (state.isNoCounselor) {
            return _NoCounselorView(adolescentName: widget.adolescentName);
          }

          if (state.error != null && state.messages.isEmpty) {
            return Center(child: Text(state.error!));
          }

          // Auto-scroll when new messages arrive
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

          return Column(
            children: [
              Expanded(
                child: state.messages.isEmpty
                    ? const _EmptyChatView()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          final isMe = message.senderRole == 'guardian';
                          return NeuroChatBubble(
                            messageContent: message.content,
                            timestamp: message.createdAt,
                            isUser: isMe,
                            senderLabel: isMe ? 'You' : 'Counselor',
                            userColor: NeuroColors.guardianPrimary,
                          );
                        },
                      ),
              ),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              _ChatInputSection(
                controller: _messageController,
                onSend: (content) {
                  ref
                      .read(counselorChatControllerProvider(widget.adolescentId).notifier)
                      .sendMessage(content);
                  _messageController.clear();
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NoCounselorView extends StatelessWidget {
  final String adolescentName;
  const _NoCounselorView({required this.adolescentName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'No Counselor Assigned',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'An assigned counselor is required to start a conversation. Please wait for the school administration to assign a professional to $adolescentName.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Start a conversation with the counselor',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _ChatInputSection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;

  const _ChatInputSection({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return NeuroChatInput(
      controller: controller,
      onSend: () {
        if (controller.text.isNotEmpty) {
          onSend(controller.text);
        }
      },
      accentColor: theme.primaryColor,
    );
  }
}
