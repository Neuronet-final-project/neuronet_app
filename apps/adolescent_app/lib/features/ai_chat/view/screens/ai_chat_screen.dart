import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:intl/intl.dart';
import '../../providers/ai_chat_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final authState = ref.watch(authControllerProvider);
    final currentUserId = authState.user?.id;

    // Scroll to bottom whenever messages change
    ref.listen(aiChatProvider, (previous, next) {
      next.when(
        data: (data) {
          final prevCount = previous?.value?.messages.length ?? 0;
          if (data.messages.length != prevCount || data.isTyping) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        loading: () {},
        error: (_, __) {},
      );
    });

    return Scaffold(
      backgroundColor: NeuroColors.background,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold)),
            chatState.when(
              data: (d) => Text(
                d.isTyping ? 'Typing...' : 'Online',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: d.isTyping ? Colors.white70 : NeuroColors.moodCalm,
                ),
              ),
              loading: () => Text('Loading...', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70)),
              error: (_, __) => Text('Offline', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: NeuroColors.alertHigh)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info about AI counselor
            },
            tooltip: 'About AI Assistant',
          ),
        ],
      ),
      body: chatState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          final theme = Theme.of(context);
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 64, color: NeuroColors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to connect to AI Assistant',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: NeuroColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your internet connection and try again.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: NeuroColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
        data: (data) {
          if (data.messages.isEmpty) {
            return _buildEmptyState();
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: data.messages.length,
                  itemBuilder: (context, index) {
                    final message = data.messages[index];
                    final isUser = message.senderId == currentUserId;
                    return NeuroChatBubble(
                      messageContent: message.messageContent,
                      timestamp: message.timestamp,
                      isUser: isUser,
                      senderLabel: isUser ? 'You' : 'NEURO Assistant',
                      userColor: NeuroColors.adolescentPrimary,
                    );
                  },
                ),
              ),
              if (data.isTyping) _buildTypingIndicator(),
              _buildQuickPrompts(),
              _buildMessageInput(data),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.psychology_outlined, size: 80, color: NeuroColors.onSurfaceVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text(
          'Start a Conversation',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: NeuroColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Ask me anything about your well-being.\nI'm here to help you reflect.",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: NeuroColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 32),
        _buildQuickPrompts(),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'AI Assistant is thinking...',
          style: theme.textTheme.labelSmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: NeuroColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      "What can you help me with?",
      "How do I add a journal entry?",
      "Who can see my data?",
      "How do I contact my counselor?",
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(prompts[index]),
              labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: NeuroColors.adolescentPrimary,
              ),
              backgroundColor: NeuroColors.adolescentSurface,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onPressed: () {
                ref.read(aiChatProvider.notifier).sendMessage(prompts[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput(AiChatState state) {
    return NeuroChatInput(
      controller: _messageController,
      onSend: () {
        final text = _messageController.text;
        if (text.isNotEmpty) {
          ref.read(aiChatProvider.notifier).sendMessage(text);
          _messageController.clear();
        }
      },
      accentColor: NeuroColors.adolescentPrimary,
      isEnabled: !state.isTyping,
    );
  }
}
