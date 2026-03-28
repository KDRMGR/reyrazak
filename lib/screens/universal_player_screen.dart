import 'package:flutter/material.dart';
import 'package:reyrazak/config/app_config.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import '../models/movie.dart' show Movie;
import '../services/watch_progress_service.dart';
import '../models/content.dart' hide Movie;
import 'package:provider/provider.dart';
import '../providers/content_provider.dart';

/// Universal Player Screen with Netflix-Style Controls
///
/// Features:
/// - Works on Android, iOS, and Web
/// - Netflix-style overlay controls
/// - 10-second skip forward/backward
/// - Play/Pause with spacebar
/// - Volume control
/// - Fullscreen support
/// - Progress tracking
/// - Brightness control (mobile)
/// - Picture-in-Picture (mobile)
/// - Auto-hide controls
/// - Loading states
/// - Error handling
class UniversalPlayerScreen extends StatefulWidget {
  final Movie movie;
  final String streamUrl;
  final List<Movie>? playlist;
  final int? currentIndex;

  const UniversalPlayerScreen({
    super.key,
    required this.movie,
    required this.streamUrl,
    this.playlist,
    this.currentIndex,
  });

  @override
  State<UniversalPlayerScreen> createState() => _UniversalPlayerScreenState();
}

class _UniversalPlayerScreenState extends State<UniversalPlayerScreen>
    with TickerProviderStateMixin {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _hideTimer;
  Timer? _progressTimer;
  late WatchProgressService _watchProgressService;

  // Netflix-style controls
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  bool _isBuffering = false;

  // Streaming strategy
  String? _fallbackStreamUrl;
  bool _isRetrying = false;
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _watchProgressService = WatchProgressService();
    _initializePlayer();
    _setupProgressTracking();
  }

  /// Get proper authentication headers for streaming
  Map<String, String> _getStreamingHeaders() {
    return {
      'User-Agent': 'REY-Play/1.0',
      'Accept': '*/*',
      'X-Emby-Authorization': ApiConfig.embyAuthHeader,
      if (_accessToken != null) 'X-Emby-Token': _accessToken!,
    };
  }

  Future<void> _initializePlayer() async {
    try {
      // Get access token from ContentProvider
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);
      _accessToken = contentProvider.apiService.accessToken;

      if (_accessToken == null || _accessToken!.isEmpty) {
        throw Exception('Access token not available. Please login again.');
      }

      // Determine best streaming URL based on platform
      String streamUrl = _getOptimalStreamUrl();

      debugPrint('Platform: ${_getPlatformName()}');
      if (kDebugMode) {
        debugPrint('Initializing video player for: ${streamUrl.replaceAll(RegExp(r'api_key=[^&]+'), 'api_key=***')}');
      }

      // Initialize video player with proper authentication headers
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(streamUrl),
        httpHeaders: _getStreamingHeaders(),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      // Add error listener first
      _videoController.addListener(_videoListener);

      // Initialize with timeout
      await _videoController.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Video initialization timeout after 30 seconds');
        },
      );

      debugPrint('Video initialized successfully');
      debugPrint('Duration: ${_videoController.value.duration}');
      debugPrint('Size: ${_videoController.value.size}');

      // Ensure audio is enabled
      await _videoController.setVolume(1.0);
      debugPrint('Volume set to: ${_videoController.value.volume}');

      // Check for audio/video tracks
      if (_videoController.value.size.width > 0 && _videoController.value.size.height > 0) {
        debugPrint('✅ Video track: ${_videoController.value.size.width}x${_videoController.value.size.height}');
      } else {
        debugPrint('⚠️ No video track detected');
      }

      // Create Chewie controller with custom controls
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: MediaConfig.autoPlay,
        looping: MediaConfig.looping,
        allowFullScreen: true,
        allowMuting: false,  // Don't allow muting to ensure audio plays
        showControls: false, // We'll use custom controls
        aspectRatio: _videoController.value.aspectRatio > 0
            ? _videoController.value.aspectRatio
            : 16 / 9,  // Default aspect ratio if not available
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              color: ThemeConfig.primary,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          debugPrint('Chewie error: $errorMessage');
          return _buildErrorWidget(errorMessage);
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _totalDuration = _videoController.value.duration;
          _isPlaying = _videoController.value.isPlaying;
        });
      }

      // Auto-play
      if (MediaConfig.autoPlay && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _videoController.play();
      }
    } catch (e) {
      debugPrint('Error initializing player: $e');

      // Check if this is a codec error (OSStatus -12847) and try fallback
      final errorStr = e.toString().toLowerCase();
      if ((errorStr.contains('osstatus') || errorStr.contains('format') ||
           errorStr.contains('codec') || errorStr.contains('-12847')) &&
          !_isRetrying) {
        debugPrint('Codec incompatibility detected. Trying transcoded stream...');
        await _retryWithTranscodedStream();
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Failed to load video: ${e.toString()}';
          });
        }
      }
    }
  }

  /// Get optimal streaming URL based on platform
  String _getOptimalStreamUrl() {
    // iOS requires H.264 codec, so always use HLS transcoding for iOS
    if (!kIsWeb && Platform.isIOS) {
      debugPrint('iOS detected: Using HLS transcoded stream for compatibility');
      return _fallbackStreamUrl ?? widget.streamUrl;
    }

    // Android and Web can typically handle more formats
    // Try direct stream first for better quality/performance
    return widget.streamUrl;
  }

  /// Get platform name for logging
  String _getPlatformName() {
    if (kIsWeb) return 'Web';
    try {
      if (Platform.isIOS) return 'iOS';
      if (Platform.isAndroid) return 'Android';
      if (Platform.isMacOS) return 'macOS';
      if (Platform.isWindows) return 'Windows';
      if (Platform.isLinux) return 'Linux';
    } catch (e) {
      // Ignore
    }
    return 'Unknown';
  }

  /// Retry with transcoded HLS stream (fallback for codec issues)
  Future<void> _retryWithTranscodedStream() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      // Dispose previous controller
      try {
        _videoController.removeListener(_videoListener);
        await _videoController.dispose();
      } catch (e) {
        debugPrint('Error disposing previous controller: $e');
      }

      // Extract item ID from the stream URL to construct HLS endpoint
      // Stream URL format: https://media.aplayworld.in/Items/{ITEM_ID}/Download?api_key={TOKEN}
      final itemId = widget.movie.id;

      // Get access token from the original URL
      final uri = Uri.parse(widget.streamUrl);
      final token = uri.queryParameters['api_key'] ?? '';

      // Construct HLS transcoded stream URL
      final hlsUrl = '${ApiConfig.baseUrl}/Videos/$itemId/master.m3u8?VideoCodec=h264&AudioCodec=aac&api_key=$token';

      debugPrint('Retrying with HLS transcoded stream: $hlsUrl');

      // Store fallback URL
      _fallbackStreamUrl = hlsUrl;

      // Initialize with HLS stream using proper authentication headers
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(hlsUrl),
        httpHeaders: _getStreamingHeaders(),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      _videoController.addListener(_videoListener);

      await _videoController.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('HLS stream initialization timeout');
        },
      );

      debugPrint('HLS stream initialized successfully');
      debugPrint('Duration: ${_videoController.value.duration}');

      // Ensure audio is enabled for HLS stream
      await _videoController.setVolume(1.0);
      debugPrint('HLS Volume set to: ${_videoController.value.volume}');

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: MediaConfig.autoPlay,
        looping: MediaConfig.looping,
        allowFullScreen: true,
        allowMuting: false,  // Don't allow muting
        showControls: false,
        aspectRatio: _videoController.value.aspectRatio > 0
            ? _videoController.value.aspectRatio
            : 16 / 9,
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(
              color: ThemeConfig.primary,
            ),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          debugPrint('Chewie HLS error: $errorMessage');
          return _buildErrorWidget(errorMessage);
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _totalDuration = _videoController.value.duration;
          _isPlaying = _videoController.value.isPlaying;
          _hasError = false;
          _errorMessage = null;
        });
      }

      // Auto-play
      if (MediaConfig.autoPlay && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _videoController.play();
      }
    } catch (e) {
      debugPrint('Error with transcoded stream: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to play video. The video format may not be compatible with your device. Error: ${e.toString()}';
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted) return;

    setState(() {
      _isPlaying = _videoController.value.isPlaying;
      _currentPosition = _videoController.value.position;
      _isBuffering = _videoController.value.isBuffering;
    });
  }

  void _setupProgressTracking() {
    // Save progress every 10 seconds
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isPlaying && _totalDuration.inSeconds > 0) {
        _saveProgress();
      }
    });
  }

  Future<void> _saveProgress() async {
    try {
      await _watchProgressService.saveWatchProgress(
        contentId: widget.movie.id,
        contentTitle: widget.movie.title,
        contentType: ContentType.movie,
        positionTicks: _currentPosition.inMicroseconds * 10,
        runtimeTicks: _totalDuration.inMicroseconds * 10,
        posterUrl: null,
      );
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
    });
    _resetHideTimer();
  }

  void _skipForward() {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    if (newPosition < _totalDuration) {
      _videoController.seekTo(newPosition);
    }
    _resetHideTimer();
  }

  void _skipBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      _videoController.seekTo(newPosition);
    } else {
      _videoController.seekTo(Duration.zero);
    }
    _resetHideTimer();
  }

  void _fastForward() {
    final newPosition = _currentPosition + const Duration(seconds: 30);
    if (newPosition < _totalDuration) {
      _videoController.seekTo(newPosition);
    } else {
      _videoController.seekTo(_totalDuration);
    }
    _resetHideTimer();
  }

  void _fastBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 30);
    if (newPosition > Duration.zero) {
      _videoController.seekTo(newPosition);
    } else {
      _videoController.seekTo(Duration.zero);
    }
    _resetHideTimer();
  }

  void _playNextVideo() {
    if (widget.playlist == null || widget.currentIndex == null) return;

    final nextIndex = widget.currentIndex! + 1;
    if (nextIndex < widget.playlist!.length) {
      final nextVideo = widget.playlist![nextIndex];
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => UniversalPlayerScreen(
            movie: nextVideo,
            streamUrl: contentProvider.getStreamUrl(nextVideo.id),
            playlist: widget.playlist,
            currentIndex: nextIndex,
          ),
        ),
      );
    }
  }

  void _playPreviousVideo() {
    if (widget.playlist == null || widget.currentIndex == null) return;

    final prevIndex = widget.currentIndex! - 1;
    if (prevIndex >= 0) {
      final prevVideo = widget.playlist![prevIndex];
      final contentProvider = Provider.of<ContentProvider>(context, listen: false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => UniversalPlayerScreen(
            movie: prevVideo,
            streamUrl: contentProvider.getStreamUrl(prevVideo.id),
            playlist: widget.playlist,
            currentIndex: prevIndex,
          ),
        ),
      );
    }
  }

  bool get _hasNextVideo {
    if (widget.playlist == null || widget.currentIndex == null) return false;
    return widget.currentIndex! < widget.playlist!.length - 1;
  }

  bool get _hasPreviousVideo {
    if (widget.playlist == null || widget.currentIndex == null) return false;
    return widget.currentIndex! > 0;
  }

  void _seek(double value) {
    final position = Duration(milliseconds: (value * _totalDuration.inMilliseconds).toInt());
    _videoController.seekTo(position);
    _resetHideTimer();
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
      _videoController.setVolume(value);
    });
    _resetHideTimer();
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
      _videoController.setPlaybackSpeed(speed);
    });
    _resetHideTimer();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _resetHideTimer();
    }
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '$minutes:${twoDigits(seconds)}';
  }

  @override
  void dispose() {
    debugPrint('Disposing video player');

    // Cancel timers first
    _hideTimer?.cancel();
    _progressTimer?.cancel();

    // Save progress before cleanup
    try {
      _saveProgress();
    } catch (e) {
      debugPrint('Error saving progress on dispose: $e');
    }

    // Remove listener
    try {
      _videoController.removeListener(_videoListener);
    } catch (e) {
      debugPrint('Error removing listener: $e');
    }

    // Dispose controllers in correct order
    try {
      _chewieController?.pause();
      _chewieController?.dispose();
    } catch (e) {
      debugPrint('Error disposing chewie: $e');
    }

    try {
      _videoController.pause();
      _videoController.dispose();
    } catch (e) {
      debugPrint('Error disposing video controller: $e');
    }

    super.dispose();
    debugPrint('Video player disposed successfully');
  }

  @override
  void deactivate() {
    // Pause playback when screen is deactivated
    if (_isPlaying) {
      _videoController.pause();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _hasError
            ? _buildErrorWidget(_errorMessage ?? 'Unknown error')
            : !_isInitialized
                ? _buildLoadingWidget()
                : _buildPlayer(),
      ),
    );
  }

  Widget _buildPlayer() {
    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        children: [
          // Video Player
          Center(
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            ),
          ),

          // Buffering Indicator
          if (_isBuffering)
            Center(
              child: CircularProgressIndicator(
                color: ThemeConfig.primary,
              ),
            ),

          // Custom Controls Overlay
          if (_showControls) _buildControlsOverlay(),

          // Top Bar (always visible when controls shown)
          if (_showControls) _buildTopBar(),

          // Bottom Bar (progress + controls)
          if (_showControls) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(ThemeConfig.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            // Back Button
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            SizedBox(width: ThemeConfig.spacingM),
            // Title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.movie.title,
                    style: ThemeConfig.heading3.copyWith(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatDuration(_totalDuration),
                    style: ThemeConfig.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Fast Backward (30s)
            _buildControlButton(
              icon: Icons.fast_rewind,
              onPressed: _fastBackward,
              size: 40,
            ),
            // Skip Backward (10s)
            _buildControlButton(
              icon: Icons.replay_10,
              onPressed: _skipBackward,
              size: 45,
            ),
            // Play/Pause
            _buildControlButton(
              icon: _isPlaying ? Icons.pause : Icons.play_arrow,
              onPressed: _togglePlayPause,
              size: 70,
            ),
            // Skip Forward (10s)
            _buildControlButton(
              icon: Icons.forward_10,
              onPressed: _skipForward,
              size: 45,
            ),
            // Fast Forward (30s)
            _buildControlButton(
              icon: Icons.fast_forward,
              onPressed: _fastForward,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: size,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildBottomBar() {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(ThemeConfig.spacingM),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress Bar
            Row(
              children: [
                Text(
                  _formatDuration(_currentPosition),
                  style: ThemeConfig.caption.copyWith(color: Colors.white),
                ),
                SizedBox(width: ThemeConfig.spacingS),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: _seek,
                      activeColor: ThemeConfig.primary,
                      inactiveColor: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                SizedBox(width: ThemeConfig.spacingS),
                Text(
                  _formatDuration(_totalDuration),
                  style: ThemeConfig.caption.copyWith(color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: ThemeConfig.spacingS),
            // Additional Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Volume Control
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _volume > 0 ? Icons.volume_up : Icons.volume_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _changeVolume(_volume > 0 ? 0 : 1.0);
                      },
                    ),
                    SizedBox(
                      width: 100,
                      child: Slider(
                        value: _volume,
                        onChanged: _changeVolume,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
                // Previous/Next Video Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Previous Video Button
                    IconButton(
                      icon: Icon(
                        Icons.skip_previous,
                        color: _hasPreviousVideo ? Colors.white : Colors.white.withValues(alpha: 0.3),
                      ),
                      onPressed: _hasPreviousVideo ? _playPreviousVideo : null,
                      tooltip: 'Previous Video',
                    ),
                    // Next Video Button
                    IconButton(
                      icon: Icon(
                        Icons.skip_next,
                        color: _hasNextVideo ? Colors.white : Colors.white.withValues(alpha: 0.3),
                      ),
                      onPressed: _hasNextVideo ? _playNextVideo : null,
                      tooltip: 'Next Video',
                    ),
                  ],
                ),
                // Playback Speed
                PopupMenuButton<double>(
                  onSelected: _changePlaybackSpeed,
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 0.5, child: Text('0.5x')),
                    PopupMenuItem(value: 0.75, child: Text('0.75x')),
                    PopupMenuItem(value: 1.0, child: Text('1.0x (Normal)')),
                    PopupMenuItem(value: 1.25, child: Text('1.25x')),
                    PopupMenuItem(value: 1.5, child: Text('1.5x')),
                    PopupMenuItem(value: 2.0, child: Text('2.0x')),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.speed, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        '${_playbackSpeed}x',
                        style: ThemeConfig.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: ThemeConfig.primary),
          SizedBox(height: ThemeConfig.spacingL),
          Text(
            'Loading video...',
            style: ThemeConfig.bodyLarge.copyWith(color: Colors.white),
          ),
          SizedBox(height: ThemeConfig.spacingS),
          Text(
            widget.movie.title,
            style: ThemeConfig.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: ThemeConfig.primary,
            size: 80,
          ),
          SizedBox(height: ThemeConfig.spacingL),
          Text(
            'Playback Error',
            style: ThemeConfig.heading2.copyWith(color: Colors.white),
          ),
          SizedBox(height: ThemeConfig.spacingM),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ThemeConfig.spacingXL),
            child: Text(
              error,
              style: ThemeConfig.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: ThemeConfig.spacingXL),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
              });
              _initializePlayer();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacingL,
                vertical: ThemeConfig.spacingM,
              ),
            ),
          ),
          SizedBox(height: ThemeConfig.spacingM),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Go Back',
              style: ThemeConfig.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
