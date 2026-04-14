import 'dart:io';
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
            content: Text('Failed to upload voice message: ${uploadResult.failure.message}'),
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
            content: Text('Failed to upload ${type.name}: ${uploadResult.failure.message}'),
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
  /// "counselor2@example.com" → "Counselor2"
  static String _emailToDisplayName(String email) {
    final name = email.split('@').first;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(counselorChatControllerProvider);
    final callState = ref.watch(callControllerProvider);
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

    // Mark incoming call as shown when ringing state is detected
    ref.listen(callControllerProvider, (previous, next) {
      final cs = next.value;
      if (cs != null &&
          cs.status == CallStatus.ringing &&
          cs.currentCall != null &&
          cs.currentCall?.id != previous?.value?.currentCall?.id) {
        // Incoming call detected — will be shown via inline overlay
      }
    });

    // Extract counselor info from state for the AppBar
    final counselorEmail = chatState.value?.counselorEmail;
    final appBarTitle = counselorEmail != null
        ? _emailToDisplayName(counselorEmail)
        : 'Counselor Chat';

    // Determine if we should show a call overlay
    final showIncomingCall =
        callState.value?.status == CallStatus.ringing &&
        callState.value?.currentCall != null;
    // Show active call for: answered, active, OR initiated (caller waiting)
    final showActiveCall = callState.value != null &&
        callState.value!.currentCall != null &&
        (callState.value!.status == CallStatus.active ||
            callState.value!.status == CallStatus.answered ||
            callState.value!.status == CallStatus.initiated);

    return Scaffold(
      appBar: (showActiveCall || showIncomingCall) ? null : AppBar(
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
            icon: const Icon(Icons.phone),
            onPressed: _startVoiceCall,
            tooltip: 'Voice call',
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
            tooltip: 'Video call',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(counselorChatControllerProvider.notifier).refresh();
            },
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Chat content (always rendered underneath)
          chatState.when(
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
                        final isVoice = message.messageType == MessageContentType.audio;

                        return NeuroChatBubble(
                          messageContent: message.content,
                          timestamp: message.createdAt,
                          isUser: isUser,
                          senderLabel: isUser ? 'You' : appBarTitle,
                          userColor: theme.colorScheme.primary,
                          isVoiceMessage: isVoice,
                          voiceUrl: message.attachmentUrl,
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
          // Incoming call overlay (rendered inline — no navigator conflicts)
          if (showIncomingCall)
            NeuroIncomingCallScreen(
              incomingCall: callState.value!.currentCall,
              accentColor: theme.colorScheme.primary,
              onDismissed: () {
                // State change will trigger a rebuild, removing the overlay.
              },
            ),
          // Active call overlay (rendered inline — no navigator conflicts)
          if (showActiveCall && callState.value != null)
            NeuroActiveCallScreen(
              call: callState.value!.currentCall!,
              remotePeerEmail: callState.value!.remotePeerEmail,
              accentColor: theme.colorScheme.primary,
            ),
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

  Widget _buildMessageInput(BuildContext context, ThemeData theme) {
    return NeuroChatInput(
      controller: _messageController,
      onSend: _sendMessage,
      accentColor: theme.colorScheme.primary,
      onSendVoice: _sendVoiceMessage,
      onSendMedia: _sendMediaMessage,
    );
  }

  // ─── Call Methods ────────────────────────────────────────────────────────

  Future<void> _startVoiceCall() async {
    final conversationId = ref.read(counselorChatControllerProvider.notifier).conversationId;
    if (conversationId == null) return;

    final chatState = ref.read(counselorChatControllerProvider).value;
    final counselorEmail = chatState?.counselorEmail;

    debugPrint('[CounselorChat] Starting voice call...');

    await ref.read(callControllerProvider.notifier).startCall(
          conversationId: conversationId,
          callType: CallType.voice,
          remotePeerEmail: counselorEmail,
        );
    // Active call screen renders inline via the call controller state.
  }

  Future<void> _startVideoCall() async {
    final conversationId = ref.read(counselorChatControllerProvider.notifier).conversationId;
    if (conversationId == null) return;

    final chatState = ref.read(counselorChatControllerProvider).value;
    final counselorEmail = chatState?.counselorEmail;

    debugPrint('[CounselorChat] Starting video call...');

    await ref.read(callControllerProvider.notifier).startCall(
          conversationId: conversationId,
          callType: CallType.video,
          remotePeerEmail: counselorEmail,
        );
    // Active call screen renders inline via the call controller state.
  }
}
