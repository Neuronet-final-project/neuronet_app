import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'neuro_shimmer.dart';
import '../theme/app_theme.dart';
import '../services/voice_recorder_service.dart';

/// The type of media attachment being sent.
enum MediaAttachmentType {
  image,
  video,
  file,
}

/// Shared chat message input widget used across AI chat, counselor chat,
/// and guardian counselor messaging screens.
///
/// Provides a text field with a send button, microphone button for voice messages,
/// attachment button for media uploads, proper padding for system bars,
/// and consistent styling.
class NeuroChatInput extends StatefulWidget {
  const NeuroChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type your message...',
    this.accentColor,
    this.isEnabled = true,
    this.onSendVoice,
    this.onSendMedia,
  });

  /// Text editing controller for the input field.
  final TextEditingController controller;

  /// Callback fired when the send button is tapped.
  final VoidCallback onSend;

  /// Placeholder text shown when the field is empty.
  final String hintText;

  /// Accent color for the send button. Defaults to [NeuroColors.adolescentPrimary].
  final Color? accentColor;

  /// Whether the input field is enabled (disables send button when false).
  final bool isEnabled;

  /// Optional callback to send a voice message file.
  /// If null, the microphone button will be hidden.
  final Future<void> Function(File audioFile)? onSendVoice;

  /// Optional callback to send a media file (image, video, or file).
  /// If null, the attachment button will be hidden.
  final Future<void> Function(File mediaFile, MediaAttachmentType type)? onSendMedia;

  @override
  State<NeuroChatInput> createState() => _NeuroChatInputState();
}

class _NeuroChatInputState extends State<NeuroChatInput> {
  final VoiceRecorderService _recorder = VoiceRecorderService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isRecording = false;
  bool _isUploading = false;
  Duration _recordingDuration = Duration.zero;
  StreamSubscription<Duration>? _durationSubscription;

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      // Stop recording and send voice message
      final filePath = await _recorder.stopRecording();
      if (filePath != null && widget.onSendVoice != null) {
        await widget.onSendVoice!(File(filePath));
      }
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      _durationSubscription?.cancel();
      _durationSubscription = null;
    } else {
      // Start recording
      final granted = await _recorder.startRecording();
      if (!granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Microphone permission is required to record voice messages.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _durationSubscription?.cancel();
      _durationSubscription = _recorder.recordingDurationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _recordingDuration = duration;
          });
        }
      });
    }
  }

  Future<void> _cancelRecording() async {
    await _recorder.cancelRecording();
    setState(() {
      _isRecording = false;
      _recordingDuration = Duration.zero;
    });
    _durationSubscription?.cancel();
    _durationSubscription = null;
  }

  /// Shows a bottom sheet with media attachment options.
  void _showAttachmentOptions() {
    final color = widget.accentColor ?? NeuroColors.adolescentPrimary;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Share Media',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAttachmentOption(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: color,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    _buildAttachmentOption(
                      icon: Icons.videocam_rounded,
                      label: 'Video',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.pop(context);
                        _pickVideo();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (picked == null) return;

      setState(() => _isUploading = true);
      await widget.onSendMedia!(File(picked.path), MediaAttachmentType.image);
      if (mounted) setState(() => _isUploading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo() async {
    try {
      final picked = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked == null) return;

      setState(() => _isUploading = true);
      await widget.onSendMedia!(File(picked.path), MediaAttachmentType.video);
      if (mounted) setState(() => _isUploading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick video: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? NeuroColors.adolescentPrimary;
    final showVoiceButton = widget.onSendVoice != null;
    final showAttachButton = widget.onSendMedia != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.2),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: _isRecording
              ? _buildRecordingUI(color)
              : _isUploading
                  ? _buildUploadingUI(color)
                  : _buildNormalUI(color, showVoiceButton, showAttachButton),
        ),
      ),
    );
  }

  Widget _buildNormalUI(Color color, bool showVoiceButton, bool showAttachButton) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              key: const ValueKey('chat_input_textfield_container'),
              decoration: BoxDecoration(
                color: NeuroColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withOpacity(0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (showAttachButton)
                    IconButton(
                      onPressed: widget.isEnabled ? _showAttachmentOptions : null,
                      icon: Icon(Icons.add_circle_outline_rounded, size: 26, color: Colors.grey.shade400),
                      splashRadius: 20,
                      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                      constraints: const BoxConstraints(),
                    ),
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.fromLTRB(
                          showAttachButton ? 8 : 20,
                          14,
                          16,
                          14,
                        ),
                      ),
                      maxLines: 5,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: widget.isEnabled,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) {
              final hasText = value.text.trim().isNotEmpty;
              final icon = hasText ? Icons.send_rounded : (showVoiceButton ? Icons.mic_rounded : Icons.send_rounded);
              
              Widget sendButton = AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: widget.isEnabled ? color : color.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  boxShadow: widget.isEnabled && hasText ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.isEnabled
                        ? (hasText ? widget.onSend : (showVoiceButton ? _toggleRecording : null))
                        : null,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: FadeTransition(opacity: animation, child: child),
                        ),
                        child: Icon(
                          icon,
                          key: ValueKey<IconData>(icon),
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              );

              if (widget.isEnabled && hasText) {
                sendButton = NeuroShimmer.glint(
                  opacity: 0.25,
                  child: sendButton,
                );
              }

              return SizedBox(
                width: 48,
                height: 48,
                child: sendButton,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUploadingUI(Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: NeuroColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Preparing media...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingUI(Color color) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _cancelRecording,
              icon: const Icon(Icons.close_rounded, size: 22),
              color: const Color(0xFFE11D48),
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Opacity(
                opacity: (sin(value * 2 * pi)).abs(),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE11D48),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
            onEnd: () {
              if (mounted) setState(() {}); // Loop pulse
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              VoiceRecorderService.formatDuration(_recordingDuration),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),
          IconButton(
            onPressed: _toggleRecording,
            icon: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, size: 22, color: Colors.white),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
