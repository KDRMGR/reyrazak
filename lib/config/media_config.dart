import 'package:flutter/material.dart';

/// Media Player and Video Playback Configuration
///
/// Centralized configuration for all media player settings including
/// video player options, streaming settings, UI customization, and playback behavior.
class MediaConfig {
  // ============================================================================
  // Video Player Settings (Chewie/VideoPlayer)
  // ============================================================================

  /// Auto-play video when player loads
  static const bool autoPlay = true;

  /// Enable video looping
  static const bool looping = false;

  /// Allow fullscreen mode
  static const bool allowFullScreen = true;

  /// Allow muting audio
  static const bool allowMuting = true;

  /// Show player controls
  static const bool showControls = true;

  /// Allow background playback (audio continues when app is backgrounded)
  static const bool allowBackgroundPlayback = false;

  /// Mix audio with other apps
  static const bool mixWithOthers = false;

  // ============================================================================
  // Player UI Colors
  // ============================================================================

  /// Color for the played portion of the progress bar
  static const Color playedColor = Colors.red;

  /// Color for the buffered portion of the progress bar
  static const Color bufferedColor = Colors.grey;

  /// Color for the handle/thumb on the progress bar
  static const Color handleColor = Colors.red;

  /// Background color for the player controls overlay
  static const Color controlsBackgroundColor = Color(0x80000000);

  // ============================================================================
  // Buffering and Cache Settings
  // ============================================================================

  /// Buffer size in bytes (null = default)
  static const int? bufferSize = null;

  /// Maximum buffer duration in seconds (null = default)
  static const int? maxBufferDuration = null;

  /// Minimum buffer duration in seconds (null = default)
  static const int? minBufferDuration = null;

  /// Enable video caching
  static const bool enableCache = true;

  /// Maximum cache size in MB
  static const int maxCacheSizeMB = 500;

  // ============================================================================
  // Streaming Retry Settings
  // ============================================================================

  /// Maximum number of retry attempts for video loading
  static const int maxStreamRetryAttempts = 3;

  /// Delay between retry attempts in milliseconds
  static const int retryDelayMs = 2000;

  /// Show error dialog after all retries fail
  static const bool showRetryErrorDialog = true;

  // ============================================================================
  // Orientation Settings
  // ============================================================================

  /// Force landscape mode during video playback
  static const bool forceLandscapeOnPlay = true;

  /// Restore portrait mode when exiting player
  static const bool restorePortraitOnExit = true;

  /// Allow both landscape orientations (left and right)
  static const bool allowBothLandscapeOrientations = true;

  // ============================================================================
  // Quality and Resolution Settings
  // ============================================================================

  /// Enable quality selection
  static const bool enableQualitySelection = false;

  /// Available quality options
  static const List<String> availableQualities = [
    '1080p',
    '720p',
    '480p',
    '360p',
    'Auto',
  ];

  /// Default quality setting
  static const String defaultQuality = 'Auto';

  /// Enable adaptive bitrate streaming
  static const bool enableAdaptiveBitrate = true;

  // ============================================================================
  // Playback Speed Settings
  // ============================================================================

  /// Enable playback speed control
  static const bool enablePlaybackSpeed = false;

  /// Available playback speeds
  static const List<double> availablePlaybackSpeeds = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    2.0,
  ];

  /// Default playback speed
  static const double defaultPlaybackSpeed = 1.0;

  // ============================================================================
  // Subtitle Settings
  // ============================================================================

  /// Enable subtitles/captions
  static const bool enableSubtitles = true;

  /// Default subtitle font size
  static const double defaultSubtitleFontSize = 16.0;

  /// Default subtitle background color
  static const Color defaultSubtitleBackgroundColor = Color(0xCC000000);

  /// Default subtitle text color
  static const Color defaultSubtitleTextColor = Colors.white;

  // ============================================================================
  // Controls Behavior
  // ============================================================================

  /// Auto-hide controls after inactivity (in seconds)
  static const int autoHideControlsDelay = 5;

  /// Show controls on tap
  static const bool showControlsOnTap = true;

  /// Double tap to seek (in seconds, null = disabled)
  static const int? doubleTapSeekDuration = 10;

  /// Enable volume gestures (swipe up/down on left side)
  static const bool enableVolumeGestures = false;

  /// Enable brightness gestures (swipe up/down on right side)
  static const bool enableBrightnessGestures = false;

  /// Enable seek gestures (swipe left/right)
  static const bool enableSeekGestures = false;

  // ============================================================================
  // System UI Settings (During Playback)
  // ============================================================================

  /// Hide status bar during playback
  static const bool hideStatusBar = true;

  /// Hide navigation bar during playback
  static const bool hideNavigationBar = true;

  /// Use immersive mode (fullscreen)
  static const bool useImmersiveMode = true;

  // ============================================================================
  // Streaming Strategy
  // ============================================================================

  /// Priority order for streaming methods
  /// 1. Download endpoint (direct file)
  /// 2. Static stream (no transcoding)
  /// 3. HLS stream (transcoded adaptive)
  static const List<StreamingMethod> streamingPriority = [
    StreamingMethod.download,
    StreamingMethod.staticStream,
    StreamingMethod.hls,
  ];

  // ============================================================================
  // Analytics and Tracking
  // ============================================================================

  /// Track playback progress
  static const bool trackPlaybackProgress = false;

  /// Save watch position (resume functionality)
  static const bool saveWatchPosition = true;

  /// Minimum watch percentage to mark as "watched" (0.0 to 1.0)
  static const double watchedThreshold = 0.9;

  /// Auto-mark as watched when threshold is reached
  static const bool autoMarkWatched = false;

  // ============================================================================
  // Error Messages
  // ============================================================================

  /// Error message when video fails to load
  static const String videoLoadErrorMessage = 'Failed to load video. Please try again.';

  /// Error message when no stream is available
  static const String noStreamAvailableMessage = 'No playable stream available for this content.';

  /// Error message for network issues
  static const String networkErrorMessage = 'Network error. Please check your connection.';

  // ============================================================================
  // Debug Settings
  // ============================================================================

  /// Show debug overlay with playback info
  static const bool showDebugOverlay = false;

  /// Log playback events
  static const bool logPlaybackEvents = true;
}

/// Streaming method enumeration
enum StreamingMethod {
  /// Direct download endpoint
  download,

  /// Static stream without transcoding
  staticStream,

  /// HLS transcoded stream
  hls,
}
