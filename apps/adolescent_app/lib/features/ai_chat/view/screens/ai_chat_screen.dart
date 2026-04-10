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
                style: TextStyle(
                  fontSize: 12,
                  color: d.isTyping ? Colors.white70 : Colors.greenAccent,
                ),
              ),
              loading: () => const Text('Loading...', style: TextStyle(fontSize: 12, color: Colors.white70)),
              error: (_, __) => const Text('Offline', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
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
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Unable to connect to AI Assistant',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Check your internet connection and try again.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.psychology_outlined, size: 80, color: Colors.grey[300]),
        const SizedBox(height: 16),
        Text(
          'Start a Conversation',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ask me anything about your well-being.\nI\'m here to help you reflect.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
        ),
        const SizedBox(height: 32),
        _buildQuickPrompts(),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'AI Assistant is thinking...',
          style: TextStyle(
            fontSize: 12,
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
              labelStyle: const TextStyle(fontSize: 13, color: NeuroColors.adolescentPrimary),
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
