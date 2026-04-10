import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/counselor_chat_provider.dart';

class CounselorChatScreen extends ConsumerStatefulWidget {
  const CounselorChatScreen({super.key});

  @override
  ConsumerState<CounselorChatScreen> createState() => _CounselorChatScreenState();
}

class _CounselorChatScreenState extends ConsumerState<CounselorChatScreen> {
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
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(counselorChatControllerProvider.notifier).sendMessage(text);
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  /// Derive a display name from an email address.
  /// "counselor2@example.com" → "Counselor2"
  static String _emailToDisplayName(String email) {
    final name = email.split('@').first;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(counselorChatControllerProvider);
    final theme = Theme.of(context);

    // Scroll to bottom when messages are added
    ref.listen(counselorChatControllerProvider, (previous, next) {
      next.whenData((data) {
        final prevCount = previous?.value?.messages.length ?? 0;
        if (data.messages.length > prevCount) {
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      });
    });

    // Extract counselor info from state for the AppBar
    final counselorEmail = chatState.value?.counselorEmail;
    final appBarTitle = counselorEmail != null
        ? _emailToDisplayName(counselorEmail)
        : 'Counselor Chat';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appBarTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (counselorEmail != null)
              Text(
                counselorEmail,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(counselorChatControllerProvider.notifier).refresh();
            },
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: chatState.when(
        data: (data) {
          final messages = data.messages;
          if (messages.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUser = message.senderRole == 'adolescent';
                    return NeuroChatBubble(
                      messageContent: message.content,
                      timestamp: message.createdAt,
                      isUser: isUser,
                      senderLabel: isUser ? 'You' : appBarTitle,
                      userColor: theme.colorScheme.primary,
                    );
                  },
                ),
              ),
              _buildMessageInput(context, theme),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_outlined, size: 64, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Unable to Start Counselor Chat',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tip: Try logging out and back in to refresh your profile.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(counselorChatControllerProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Messages Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start a conversation\nwith your counselor.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            _buildSuggestedPrompts(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedPrompts(BuildContext context, ThemeData theme) {
    final prompts = [
      "I'd like to talk about something",
      "Can you help me with some concerns?",
      "I need some guidance",
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: prompts.map((prompt) {
        return ActionChip(
          label: Text(prompt),
          labelStyle: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
          backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () {
            _messageController.text = prompt;
            _sendMessage();
          },
        );
      }).toList(),
    );
  }

  Widget _buildMessageInput(BuildContext context, ThemeData theme) {
    return NeuroChatInput(
      controller: _messageController,
      onSend: _sendMessage,
      accentColor: theme.colorScheme.primary,
    );
  }
}
