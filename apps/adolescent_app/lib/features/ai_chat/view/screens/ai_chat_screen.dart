import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
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
            Text(context.localizations.aiAssistant, style: const TextStyle(fontWeight: FontWeight.bold)),
            chatState.when(
              data: (d) => Text(
                d.isTyping ? context.localizations.typing : context.localizations.online,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: d.isTyping ? Colors.white70 : NeuroColors.moodCalm,
                ),
              ),
              loading: () => Text(context.localizations.loading, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white70)),
              error: (_, __) => Text(context.localizations.offline, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: NeuroColors.alertHigh)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => AlertDialog(
                  backgroundColor: NeuroColors.background,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: Row(
                    children: [
                      const Icon(Icons.psychology_rounded, color: NeuroColors.adolescentPrimary),
                      const SizedBox(width: 12),
                      Text(context.localizations.aiAssistantInfo, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoItem(Icons.security_rounded, context.localizations.safetyFirst, context.localizations.safetyFirstDesc),
                      const SizedBox(height: 16),
                      _buildInfoItem(Icons.privacy_tip_rounded, context.localizations.yourData, context.localizations.yourDataDesc),
                      const SizedBox(height: 16),
                      _buildInfoItem(Icons.lightbulb_rounded, context.localizations.howToUse, context.localizations.howToUseDesc),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(context.localizations.gotIt, style: const TextStyle(fontWeight: FontWeight.bold, color: NeuroColors.adolescentPrimary)),
                    ),
                  ],
                ),
              );
            },
            tooltip: context.localizations.aboutAiAssistant,
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
                  const Icon(Icons.wifi_off_rounded, size: 64, color: NeuroColors.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    context.localizations.unableConnectAi,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: NeuroColors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.localizations.checkInternetTryAgain,
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
              _buildSafetyDisclaimer(),
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
                      senderLabel: isUser ? context.localizations.youSenderLabel : context.localizations.aiSenderLabel,
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
          context.localizations.startConversation,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: NeuroColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.localizations.aiEmptyPrompt,
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
          context.localizations.aiThinking,
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
      context.localizations.aiPrompt1,
      context.localizations.aiPrompt2,
      context.localizations.aiPrompt3,
      context.localizations.aiPrompt4,
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
      maxLength: 5000,
    );
  }

  Widget _buildSafetyDisclaimer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: NeuroCard(
          color: NeuroColors.adolescentSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: NeuroColors.adolescentPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.localizations.aiSafetyDisclaimer,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: NeuroColors.adolescentPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: NeuroColors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(description, style: TextStyle(color: NeuroColors.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
