import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service for recording, playing back, and managing voice messages.
/// Supports both mobile (Android/iOS) and web platforms.
class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  String? _currentRecordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;

  /// Stream that emits the current recording duration every second.
  final _recordingDurationController = StreamController<Duration>.broadcast();
  Stream<Duration> get recordingDurationStream =>
      _recordingDurationController.stream;

  /// Current recording duration (for non-stream access).
  Duration get recordingDuration => _recordingDuration;

  /// Whether the recorder is currently recording.
  Future<bool> get isRecording => _recorder.isRecording();

  /// Whether the audio player is currently playing.
  bool get isPlaying => _player.state == PlayerState.playing;

  /// Whether we're running on web platform.
  bool get _isWeb => kIsWeb;

  /// Requests microphone permission. Returns true if granted.
  Future<bool> requestMicrophonePermission() async {
    // On web, permissions are handled by browser prompts
    if (_isWeb) {
      debugPrint('[VoiceRecorder] Web platform - permission handled by browser');
      return true;
    }
    
    final status = await Permission.microphone.request();
    debugPrint('[VoiceRecorder] Microphone permission: $status');
    return status == PermissionStatus.granted;
  }

  /// Checks if microphone permission is already granted.
  Future<bool> hasMicrophonePermission() async {
    // On web, skip permission check (browser handles it)
    if (_isWeb) return true;
    
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// Returns the temporary directory path for mobile, or null for web.
  Future<String?> _getTempDir() async {
    if (_isWeb) return null;
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  /// Starts recording audio.
  /// On mobile: saves to a temporary file path
  /// On web: returns a blob URL
  /// Returns true if recording started successfully.
  Future<bool> startRecording() async {
    try {
      // Check permission (mobile only)
      if (!_isWeb && !await hasMicrophonePermission()) {
        final granted = await requestMicrophonePermission();
        if (!granted) {
          debugPrint('[VoiceRecorder] Microphone permission denied');
          return false;
        }
      }

      if (_isWeb) {
        // Web: the record package handles web recording via browser MediaRecorder
        // path_provider is not available on web, but record package still needs a path parameter
        // On web, this is treated as a blob URL identifier rather than a real file path
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _currentRecordingPath = 'blob:voice_$timestamp.webm'; // WebM format for web

        debugPrint('[VoiceRecorder] Starting web recording (browser MediaRecorder)');

        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.opus, // Opus works best for web
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath!,
        );
      } else {
        // Mobile: record to temporary file
        final tempDir = await _getTempDir();
        if (tempDir == null) {
          debugPrint('[VoiceRecorder] Failed to get temporary directory');
          return false;
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _currentRecordingPath = '$tempDir/voice_$timestamp.m4a';

        debugPrint('[VoiceRecorder] Starting mobile recording: $_currentRecordingPath');

        await _recorder.start(
          RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath!,
        );
      }

      // Start timer
      _recordingDuration = Duration.zero;
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _recordingDuration += const Duration(seconds: 1);
        _recordingDurationController.add(_recordingDuration);
      });

      return true;
    } catch (e) {
      debugPrint('[VoiceRecorder] Failed to start recording: $e');
      return false;
    }
  }

  /// Stops recording and returns the path to the recorded file (or blob URL on web).
  Future<String?> stopRecording() async {
    try {
      debugPrint('[VoiceRecorder] Stopping recording');

      _recordingTimer?.cancel();
      _recordingTimer = null;

      final path = await _recorder.stop();
      
      // On web, path is a blob URL. On mobile, it's the file path.
      if (path != null && path.isNotEmpty) {
        _currentRecordingPath = path;
      }

      debugPrint('[VoiceRecorder] Recording stopped: $_currentRecordingPath');
      return _currentRecordingPath;
    } catch (e) {
      debugPrint('[VoiceRecorder] Failed to stop recording: $e');
      return null;
    }
  }

  /// Cancels the current recording (deletes the file on mobile).
  Future<void> cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;

      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }

      // Delete the temp file (mobile only)
      if (!_isWeb && _currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('[VoiceRecorder] Deleted recording: $_currentRecordingPath');
        }
      }

      _currentRecordingPath = null;
      _recordingDuration = Duration.zero;
    } catch (e) {
      debugPrint('[VoiceRecorder] Failed to cancel recording: $e');
    }
  }

  /// Plays back an audio file from a local path, remote URL, or web blob URL.
  Future<void> playAudio(String audioSource) async {
    try {
      debugPrint('[VoiceRecorder] Playing audio: $audioSource');

      if (_player.state == PlayerState.playing) {
        await _player.stop();
      }

      // Check if it's a web blob URL
      if (_isWeb || audioSource.startsWith('http') || audioSource.startsWith('blob:')) {
        await _player.play(UrlSource(audioSource));
      } else {
        // Local file (mobile)
        await _player.play(DeviceFileSource(audioSource));
      }
    } catch (e) {
      debugPrint('[VoiceRecorder] Failed to play audio: $e');
    }
  }

  /// Stops audio playback.
  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('[VoiceRecorder] Failed to stop playback: $e');
    }
  }

  /// Pauses audio playback.
  Future<void> pausePlayback() async {
    try {
      await _player.pause();
    } catch (e) {
      debugPrint('[VoiceRecorder] Failed to pause playback: $e');
    }
  }

  /// Resumes audio playback.
  Future<void> resumePlayback() async {
    try {
      await _player.resume();
    } catch (e) {
      debugPrint('[VoiceRecorder] Failed to resume playback: $e');
    }
  }

  /// Formats a Duration as mm:ss.
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Disposes resources.
  void dispose() {
    _recordingTimer?.cancel();
    _recordingDurationController.close();
    _recorder.dispose();
    _player.dispose();
  }
}
