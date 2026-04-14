import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
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
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendVoiceMessage(File audioFile) async {
    debugPrint('[GuardianCounselorMsg] Sending voice message: ${audioFile.path}');
    
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
    final notifier = ref.read(counselorChatControllerProvider(widget.adolescentId).notifier);
    await notifier.sendVoiceMessage(attachmentUrl);
  }

  Future<void> _sendMediaMessage(File mediaFile, MediaAttachmentType type) async {
    debugPrint('[GuardianCounselorMsg] Sending ${type.name} message: ${mediaFile.path}');

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
    final notifier = ref.read(counselorChatControllerProvider(widget.adolescentId).notifier);
    await notifier.sendMediaMessage(attachmentUrl, messageType);
  }

  /// Derive a display name from an email address.
  static String _emailToDisplayName(String email) {
    final name = email.split('@').first;
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(counselorChatControllerProvider(widget.adolescentId));
    final callState = ref.watch(callControllerProvider);
    final counselorEmail = chatAsync.value?.counselorEmail;
    final counselorName = counselorEmail != null
        ? _emailToDisplayName(counselorEmail)
        : 'Counselor';

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
          children: [
            Text(counselorName),
            Text(
              'Regarding: ${widget.adolescentName}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
        centerTitle: true,
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
        ],
      ),
      body: Stack(
        children: [
          chatAsync.when(
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
                              final isVoice = message.messageType == MessageContentType.audio;

                              return NeuroChatBubble(
                                messageContent: message.content,
                                timestamp: message.createdAt,
                                isUser: isMe,
                                senderLabel: isMe ? 'You' : counselorName,
                                userColor: NeuroColors.guardianPrimary,
                                isVoiceMessage: isVoice,
                                voiceUrl: message.attachmentUrl,
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
                    onSendVoice: _sendVoiceMessage,
                    onSendMedia: _sendMediaMessage,
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
          // Incoming call overlay (rendered inline — no navigator conflicts)
          if (showIncomingCall)
            NeuroIncomingCallScreen(
              incomingCall: callState.value!.currentCall,
              accentColor: NeuroColors.guardianPrimary,
              onDismissed: () {},
            ),
          // Active call overlay (rendered inline — no navigator conflicts)
          if (showActiveCall && callState.value != null)
            NeuroActiveCallScreen(
              call: callState.value!.currentCall!,
              remotePeerEmail: callState.value!.remotePeerEmail,
              accentColor: NeuroColors.guardianPrimary,
            ),
        ],
      ),
    );
  }

  // ─── Call Methods ────────────────────────────────────────────────────────

  Future<void> _startVoiceCall() async {
    final chatState = ref.read(counselorChatControllerProvider(widget.adolescentId).notifier);
    final conversationId = chatState.conversationId;
    if (conversationId == null) return;

    final state = ref.read(counselorChatControllerProvider(widget.adolescentId)).value;
    final counselorEmail = state?.counselorEmail;

    debugPrint('[GuardianCounselorMsg] Starting voice call...');

    await ref.read(callControllerProvider.notifier).startCall(
          conversationId: conversationId,
          callType: CallType.voice,
          remotePeerEmail: counselorEmail,
        );
    // Active call screen renders inline via the call controller state.
  }

  Future<void> _startVideoCall() async {
    final chatState = ref.read(counselorChatControllerProvider(widget.adolescentId).notifier);
    final conversationId = chatState.conversationId;
    if (conversationId == null) return;

    final state = ref.read(counselorChatControllerProvider(widget.adolescentId)).value;
    final counselorEmail = state?.counselorEmail;

    debugPrint('[GuardianCounselorMsg] Starting video call...');

    await ref.read(callControllerProvider.notifier).startCall(
          conversationId: conversationId,
          callType: CallType.video,
          remotePeerEmail: counselorEmail,
        );
    // Active call screen renders inline via the call controller state.
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
  final Future<void> Function(File)? onSendVoice;
  final Future<void> Function(File, MediaAttachmentType)? onSendMedia;

  const _ChatInputSection({
    required this.controller, 
    required this.onSend,
    this.onSendVoice,
    this.onSendMedia,
  });

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
      onSendVoice: onSendVoice,
      onSendMedia: onSendMedia,
    );
  }
}
