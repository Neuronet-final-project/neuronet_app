import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: NeuroColors.surface,
          boxShadow: [NeuroShadows.sm],
        ),
        child: _isRecording
            ? _buildRecordingUI(color)
            : _isUploading
                ? _buildUploadingUI(color)
                : _buildNormalUI(color, showVoiceButton, showAttachButton),
      ),
    );
  }

  Widget _buildNormalUI(Color color, bool showVoiceButton, bool showAttachButton) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (showAttachButton) ...[
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: widget.isEnabled ? _showAttachmentOptions : null,
              icon: const Icon(Icons.attach_file_rounded, size: 20),
              color: color,
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        if (showVoiceButton) ...[
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: widget.isEnabled ? _toggleRecording : null,
              icon: const Icon(Icons.mic, size: 20),
              color: color,
              padding: const EdgeInsets.all(10),
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(NeuroRadius.xl),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: NeuroColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            enabled: widget.isEnabled,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: widget.isEnabled ? color : color.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: widget.isEnabled ? widget.onSend : null,
            icon: const Icon(Icons.send, size: 20),
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadingUI(Color color) {
    return Row(
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
        const SizedBox(width: 12),
        Text(
          'Uploading media...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingUI(Color color) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.delete, size: 20),
            color: Colors.red,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            tooltip: 'Cancel recording',
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            VoiceRecorderService.formatDuration(_recordingDuration),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _toggleRecording,
            icon: const Icon(Icons.send, size: 20),
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            tooltip: 'Send voice message',
          ),
        ),
      ],
    );
  }
}
