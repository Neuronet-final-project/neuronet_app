import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import 'package:adolescent_app/features/counselor_chat/providers/counselor_chat_provider.dart';
import 'package:adolescent_app/features/consent_status/providers/consent_status_provider.dart';

class CounselorChatScreen extends ConsumerStatefulWidget {
  const CounselorChatScreen({super.key});

  @override
  ConsumerState<CounselorChatScreen> createState() => _CounselorChatScreenState();
}

class _CounselorChatScreenState extends ConsumerState<CounselorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

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

  Future<void> _sendVoiceMessage(File audioFile) async {
    debugPrint('[CounselorChat] Sending voice message: ${audioFile.path}');
    
    // Upload the audio file
    final messagingService = ref.read(messagingServiceProvider);
    final uploadResult = await messagingService.uploadMedia(audioFile);
    
    if (uploadResult.isFailure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.localizations.failedToUploadVoice(uploadResult.failure.message)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final attachmentUrl = uploadResult.value;
    
    final notifier = ref.read(counselorChatControllerProvider.notifier);
    await notifier.sendVoiceMessage(attachmentUrl);
  }

  Future<void> _sendMediaMessage(File mediaFile, MediaAttachmentType type) async {
    debugPrint('[CounselorChat] Sending ${type.name} message: ${mediaFile.path}');

    // Upload the media file
    final messagingService = ref.read(messagingServiceProvider);
    final uploadResult = await messagingService.uploadMedia(mediaFile);

    if (uploadResult.isFailure) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.localizations.failedToUploadMedia(type.name, uploadResult.failure.message)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final attachmentUrl = uploadResult.value;
    final messageType = type == MediaAttachmentType.image ? MessageContentType.image : MessageContentType.video;

    // Send the message with the attachment URL
    final notifier = ref.read(counselorChatControllerProvider.notifier);
    await notifier.sendMediaMessage(attachmentUrl, messageType);
  }

  /// Derive a display name from an email address.
  static String _emailToDisplayName(String email) {
    final name = email.split('@').first;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(counselorChatControllerProvider);
    final callState = ref.watch(callControllerProvider);
    final consentAsync = ref.watch(adolescentConsentControllerProvider);
    final theme = Theme.of(context);

    ref.listen(counselorChatControllerProvider, (previous, next) {
      next.whenData((data) {
        final prevCount = previous?.value?.messages.length ?? 0;
        if (data.messages.length > prevCount) {
          Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
        }
      });
    });

    final isConsentGranted = consentAsync.value?.counselorChat ?? true;
    final counselorEmail = chatState.value?.counselorEmail;
    final appBarTitle = counselorEmail != null
        ? _emailToDisplayName(counselorEmail)
        : context.localizations.counselorChat;

    final showIncomingCall =
        callState.value?.status == CallStatus.ringing &&
        callState.value?.currentCall != null;
    final showActiveCall = callState.value != null &&
        callState.value!.currentCall != null &&
        (callState.value!.status == CallStatus.active ||
            callState.value!.status == CallStatus.answered ||
            callState.value!.status == CallStatus.initiated);

    return Scaffold(
      appBar: (showActiveCall || showIncomingCall)
          ? null
          : AppBar(
              title: Text(
                appBarTitle,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.phone),
                  onPressed: _startVoiceCall,
                  tooltip: context.localizations.voiceCall,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: _startVideoCall,
                  tooltip: context.localizations.videoCall,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(counselorChatControllerProvider.notifier).refresh();
                  },
                  tooltip: context.localizations.refreshMessages,
                ),
              ],
            ),
      body: Column(
        children: [
          // Consent status banner — always visible
          if (!showActiveCall && !showIncomingCall)
            consentAsync.when(
              data: (consentState) {
                final granted = consentState.counselorChat;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
                  child: NeuroCard(
                    color: granted
                        ? NeuroColors.alertLow.withValues(alpha: 0.15)
                        : NeuroColors.alertMedium.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          granted ? Icons.check_circle : Icons.warning_amber_rounded,
                          size: 20,
                          color: granted ? NeuroColors.alertLow : NeuroColors.alertMedium,
                        ),
                      SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            granted
                                ? context.localizations.chatEnabledBanner
                                : context.localizations.chatDisabledBanner,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: NeuroColors.onSurface,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => Padding(
                padding: EdgeInsets.all(12.0),
                child: NeuroCard(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                       SizedBox(
                         width: 20,
                         height: 20,
                         child: CircularProgressIndicator(strokeWidth: 2),
                       ),
                       SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.localizations.loadingConsent,
                          style: TextStyle(
                            color: NeuroColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          // Chat area
          Expanded(
            child: Stack(
              children: [
                chatState.when(
                  data: (data) {
                    final messages = data.messages;
                    if (messages.isEmpty) {
                      return _buildEmptyState(context, theme);
                    }
                    return ListView.builder(
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
                          senderLabel: isUser ? context.localizations.you : appBarTitle,
                          userColor: theme.colorScheme.primary,
                          messageType: message.messageType,
                          attachmentUrl: message.attachmentUrl,
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_circle_outlined,
                              size: 64, color: theme.colorScheme.error),
                          const SizedBox(height: 16),
                          Text(
                            context.localizations.unableToStartChat,
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
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.invalidate(counselorChatControllerProvider);
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(context.localizations.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (showIncomingCall)
                  NeuroIncomingCallScreen(
                    incomingCall: callState.value!.currentCall,
                    accentColor: theme.colorScheme.primary,
                    onDismissed: () {},
                  ),
                if (showActiveCall && callState.value != null)
                  Positioned.fill(
                    child: NeuroActiveCallScreen(
                      call: callState.value!.currentCall!,
                      remotePeerEmail: callState.value!.remotePeerEmail,
                      accentColor: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          _buildMessageInput(context, theme, isConsentGranted),
        ],
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
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.localizations.noMessagesYet,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.localizations.startConversationWithCounselor,
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
      context.localizations.counselorPrompt1,
      context.localizations.counselorPrompt2,
      context.localizations.counselorPrompt3,
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
          backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          onPressed: () {
            _messageController.text = prompt;
            _sendMessage();
          },
        );
      }).toList(),
    );
  }

  Widget _buildMessageInput(BuildContext context, ThemeData theme, bool isEnabled) {
    return NeuroChatInput(
      controller: _messageController,
      onSend: _sendMessage,
      accentColor: theme.colorScheme.primary,
      onSendVoice: _sendVoiceMessage,
      onSendMedia: _sendMediaMessage,
      isEnabled: isEnabled,
    );
  }

  Future<void> _startVoiceCall() async {
    final conversationId = ref.read(counselorChatControllerProvider.notifier).conversationId;
    if (conversationId == null) return;

    final chatState = ref.read(counselorChatControllerProvider).value;
    final counselorEmail = chatState?.counselorEmail;

    await ref.read(callControllerProvider.notifier).startCall(
          conversationId: conversationId,
          callType: CallType.voice,
          remotePeerEmail: counselorEmail,
        );
  }

  Future<void> _startVideoCall() async {
    final conversationId = ref.read(counselorChatControllerProvider.notifier).conversationId;
    if (conversationId == null) return;

    final chatState = ref.read(counselorChatControllerProvider).value;
    final counselorEmail = chatState?.counselorEmail;

    await ref.read(callControllerProvider.notifier).startCall(
          conversationId: conversationId,
          callType: CallType.video,
          remotePeerEmail: counselorEmail,
        );
  }
}
