import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:reyrazak/config/app_config.dart';
import '../models/movie.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Movie movie;
  final String streamUrl;

  const VideoPlayerScreen({
    super.key,
    required this.movie,
    required this.streamUrl,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  int _retryAttempt = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    // Force landscape orientation for video playback (if configured)
    if (MediaConfig.forceLandscapeOnPlay) {
      SystemChrome.setPreferredOrientations(AppConstants.landscapeOrientations);
    }
    // Hide system UI for immersive experience (if configured)
    if (MediaConfig.useImmersiveMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void dispose() {
    // Restore portrait orientation (if configured)
    if (MediaConfig.restorePortraitOnExit) {
      SystemChrome.setPreferredOrientations(AppConstants.preferredOrientations);
    }
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.apiService.accessToken;

    try {
      print('Initializing video player...');
      print('Stream URL: ${widget.streamUrl}');
      print('Attempt: ${_retryAttempt + 1}');

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.streamUrl),
        httpHeaders: {
          'X-Emby-Authorization': 'MediaBrowser Token=$token',
        },
      );

      await _videoPlayerController.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: MediaConfig.autoPlay,
          looping: MediaConfig.looping,
          allowFullScreen: MediaConfig.allowFullScreen,
          allowMuting: MediaConfig.allowMuting,
          showControls: MediaConfig.showControls,
          materialProgressColors: ChewieProgressColors(
            playedColor: MediaConfig.playedColor,
            handleColor: MediaConfig.handleColor,
            backgroundColor: MediaConfig.bufferedColor,
            bufferedColor: MediaConfig.bufferedColor.withOpacity(0.3),
          ),
          placeholder: Container(
            color: ThemeConfig.background,
            child: Center(
              child: CircularProgressIndicator(
                color: ThemeConfig.primary,
              ),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: ThemeConfig.error,
                    size: ThemeConfig.iconSizeXL,
                  ),
                  SizedBox(height: ThemeConfig.spacingM),
                  Text(
                    MediaConfig.videoLoadErrorMessage,
                    style: ThemeConfig.bodyLarge,
                  ),
                  SizedBox(height: ThemeConfig.spacingS),
                  Padding(
                    padding: EdgeInsets.all(ThemeConfig.spacingM),
                    child: Text(
                      errorMessage,
                      style: ThemeConfig.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        );

        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      print('Video player initialization error: $e');

      // Try alternative streaming methods
      if (_retryAttempt == 0 && mounted) {
        print('Retrying with alternative stream URL...');
        _retryAttempt++;
        await _tryAlternativeStream();
      } else if (_retryAttempt == 1 && mounted) {
        print('Retrying with direct stream URL...');
        _retryAttempt++;
        await _tryDirectStream();
      } else if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Unable to play video after multiple attempts.\n\n${e.toString()}';
        });
      }
    }
  }

  Future<void> _tryAlternativeStream() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.apiService.accessToken;
    final movieId = widget.movie.id;

    try {
      // Try with stream endpoint without Download
      final altUrl = '${ApiService.baseUrl}/Videos/$movieId/stream?Static=true&api_key=$token';

      print('Trying alternative stream URL: $altUrl');

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(altUrl),
        httpHeaders: {
          'X-Emby-Authorization': 'MediaBrowser Token=$token',
        },
      );

      await _videoPlayerController.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: MediaConfig.autoPlay,
          looping: MediaConfig.looping,
          allowFullScreen: MediaConfig.allowFullScreen,
          showControls: MediaConfig.showControls,
          materialProgressColors: ChewieProgressColors(
            playedColor: MediaConfig.playedColor,
            handleColor: MediaConfig.handleColor,
            backgroundColor: MediaConfig.bufferedColor,
            bufferedColor: MediaConfig.bufferedColor.withValues(alpha: 0.3),
          ),
        );

        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      print('Alternative stream also failed: $e');
      await _initializePlayer(); // Retry with next method
    }
  }

  Future<void> _tryDirectStream() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.apiService.accessToken;
    final movieId = widget.movie.id;

    try {
      // Try with master playlist for HLS streaming
      final hlsUrl = '${ApiService.baseUrl}/Videos/$movieId/master.m3u8?VideoCodec=h264&AudioCodec=aac&api_key=$token';

      print('Trying HLS stream URL: $hlsUrl');

      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(hlsUrl),
        httpHeaders: {
          'X-Emby-Authorization': 'MediaBrowser Token=$token',
        },
      );

      await _videoPlayerController.initialize();

      if (mounted) {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          autoPlay: MediaConfig.autoPlay,
          looping: MediaConfig.looping,
          allowFullScreen: MediaConfig.allowFullScreen,
          showControls: MediaConfig.showControls,
          materialProgressColors: ChewieProgressColors(
            playedColor: MediaConfig.playedColor,
            handleColor: MediaConfig.handleColor,
            backgroundColor: MediaConfig.bufferedColor,
            bufferedColor: MediaConfig.bufferedColor.withValues(alpha: 0.3),
          ),
        );

        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      print('HLS stream also failed: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Unable to play video. All streaming methods failed.\n\nError: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            Container(
              color: ThemeConfig.background.withValues(alpha: 0.9),
              padding: EdgeInsets.symmetric(
                horizontal: ThemeConfig.spacingS,
                vertical: ThemeConfig.spacingXS,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: ThemeConfig.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.movie.title,
                      style: ThemeConfig.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Video player
            Expanded(
              child: Center(
                child: _hasError
                    ? _buildErrorWidget()
                    : !_isInitialized
                        ? CircularProgressIndicator(color: ThemeConfig.primary)
                        : _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : CircularProgressIndicator(color: ThemeConfig.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: EdgeInsets.all(ThemeConfig.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: ThemeConfig.error,
            size: ThemeConfig.iconSizeXL,
          ),
          SizedBox(height: ThemeConfig.spacingM),
          Text(
            MediaConfig.videoLoadErrorMessage,
            style: ThemeConfig.heading3,
          ),
          SizedBox(height: ThemeConfig.spacingM),
          Text(
            _errorMessage ?? MediaConfig.networkErrorMessage,
            style: ThemeConfig.bodySmall,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ThemeConfig.spacingL),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _hasError = false;
                _isInitialized = false;
                _retryAttempt = 0;
              });
              _initializePlayer();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConfig.primary,
              foregroundColor: ThemeConfig.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
