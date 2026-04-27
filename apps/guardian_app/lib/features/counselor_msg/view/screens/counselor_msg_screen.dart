import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neuronet_core/neuronet_core.dart';
import '../../providers/counselor_chat_provider.dart';
import '../../../consent/providers/consent_provider.dart';
import '../../../ui/bento_card.dart';

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

  Widget _buildChatView(CounselorChatState state, String counselorName, bool showActiveCall, bool showIncomingCall) {
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.senderRole == 'guardian';

                    return NeuroChatBubble(
                      messageContent: message.content,
                      timestamp: message.createdAt,
                      isUser: isMe,
                      senderLabel: isMe ? 'You' : counselorName,
                      userColor: NeuroColors.guardianPrimary,
                      messageType: message.messageType,
                      attachmentUrl: message.attachmentUrl,
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
            ref.read(counselorChatControllerProvider(widget.adolescentId).notifier).sendMessage(content);
            _messageController.clear();
          },
          onSendVoice: _sendVoiceMessage,
          onSendMedia: _sendMediaMessage,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(counselorChatControllerProvider(widget.adolescentId));
    final callState = ref.watch(callControllerProvider);
    final counselorEmail = chatAsync.value?.counselorEmail;
    final counselorName = counselorEmail != null ? _emailToDisplayName(counselorEmail) : 'Counselor';

    final showIncomingCall = callState.value?.status == CallStatus.ringing && callState.value?.currentCall != null;
    final showActiveCall = callState.value != null &&
        callState.value!.currentCall != null &&
        (callState.value!.status == CallStatus.active ||
            callState.value!.status == CallStatus.answered ||
            callState.value!.status == CallStatus.initiated);

    final consentAsync = ref.watch(guardianConsentControllerProvider);
    final counselorChatConsent = consentAsync.whenOrNull(
      data: (consentState) => consentState.consents.firstWhere(
        (c) => c.consentType == ConsentType.counselorChat,
        orElse: () => Consent(
          consentId: '',
          adolescentId: widget.adolescentId,
          guardianId: '',
          consentType: ConsentType.counselorChat,
          grantedToRole: GrantedToRole.guardian,
          consentStatus: ConsentStatus.revoked,
          grantedAt: DateTime.now(),
        ),
      ),
    );

    final isConsentGranted =
        counselorChatConsent?.consentStatus == ConsentStatus.granted;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: (showActiveCall || showIncomingCall)
          ? null
          : AppBar(
              backgroundColor: const Color(0xFFF9FAFB),
              surfaceTintColor: const Color(0xFFF9FAFB),
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: true,
               title: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   CircleAvatar(
                     radius: 16,
                     backgroundColor: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                     child: const Icon(Icons.psychology_rounded, size: 18, color: NeuroColors.guardianPrimary),
                   ),
                   const SizedBox(width: 12),
                   Flexible(
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           counselorName,
                           style: const TextStyle(
                             fontSize: 16,
                             fontWeight: FontWeight.w800,
                             color: NeuroColors.guardianPrimaryDark,
                             letterSpacing: -0.4,
                           ),
                           overflow: TextOverflow.ellipsis,
                         ),
                         Text(
                           'Regarding: ${widget.adolescentName}',
                           style: TextStyle(
                             fontSize: 10,
                             fontWeight: FontWeight.w600,
                             color: NeuroColors.onSurface.withValues(alpha: 0.5),
                           ),
                           overflow: TextOverflow.ellipsis,
                         ),
                       ],
                     ),
                   ),
                 ],
               ),
              actions: [
                _ActionButton(icon: Icons.phone_rounded, onTap: _startVoiceCall),
                const SizedBox(width: 8),
                _ActionButton(icon: Icons.videocam_rounded, onTap: _startVideoCall),
                const SizedBox(width: 16),
              ],
            ),
      body: Column(
        children: [
          // Consent status banner at top of body (hidden during calls)
          if (!showActiveCall && !showIncomingCall)
            consentAsync.when(
              data: (consentState) {
                final isGranted = isConsentGranted;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 12.0),
                  child: NeuroCard(
                    color: isGranted
                        ? NeuroColors.alertLow.withValues(alpha: 0.15)
                        : NeuroColors.alertMedium.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGranted
                              ? Icons.check_circle
                              : Icons.warning_amber_rounded,
                          size: 20,
                          color: isGranted
                              ? NeuroColors.alertLow
                              : NeuroColors.alertMedium,
                        ),
                        const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isGranted
                              ? 'Chat enabled - Adolescent consent on file'
                              : 'Chat disabled - Adolescent consent required',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: NeuroColors.onSurface,
                          ),
                        ),
                      ),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
          // Chat + call overlays
          Expanded(
            child: Stack(
              children: [
                chatAsync.when(
                  data: (state) => _buildChatView(
                    state,
                    counselorName,
                    showActiveCall,
                    showIncomingCall,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Center(child: Text('Error: $e')),
                ),
                if (showIncomingCall)
                  NeuroIncomingCallScreen(
                    incomingCall: callState.value!.currentCall,
                    accentColor: NeuroColors.guardianPrimary,
                    onDismissed: () {},
                  ),
                if (showActiveCall && callState.value != null)
                  NeuroActiveCallScreen(
                    call: callState.value!.currentCall!,
                    remotePeerEmail: callState.value!.remotePeerEmail,
                    accentColor: NeuroColors.guardianPrimary,
                  ),
              ],
            ),
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: NeuroColors.guardianPrimary.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, size: 20, color: NeuroColors.guardianPrimary),
          ),
        ),
      ),
    );
  }
}

class _NoCounselorView extends StatelessWidget {
  final String adolescentName;
  const _NoCounselorView({required this.adolescentName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: GuardianBentoCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: NeuroColors.guardianPrimary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_rounded,
                  size: 48,
                  color: NeuroColors.guardianPrimary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Counselor Assigned',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: NeuroColors.guardianPrimaryDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'An assigned counselor is required to start a conversation. Please wait for the school administration to assign a professional to $adolescentName.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: NeuroColors.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
            ],
          ),
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
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NeuroColors.onSurface.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: NeuroColors.onSurface.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Start a conversation with the counselor',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: NeuroColors.onSurface.withValues(alpha: 0.4),
            ),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NeuroChatInput(
        controller: controller,
        onSend: () {
          if (controller.text.trim().isNotEmpty) {
            onSend(controller.text.trim());
          }
        },
        accentColor: NeuroColors.guardianPrimary,
        onSendVoice: onSendVoice,
        onSendMedia: onSendMedia,
      ),
    );
  }
}
