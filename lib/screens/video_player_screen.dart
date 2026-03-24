import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
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
    // Force landscape orientation for video playback
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.red,
            handleColor: Colors.red,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.white24,
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          ),
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading video',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.grey),
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
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.red,
            handleColor: Colors.red,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.white24,
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
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          showControls: true,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.red,
            handleColor: Colors.red,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.white24,
          ),
        );

        setState(() {
          _isInitialized = true;
          _hasError = false,
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                        ? const CircularProgressIndicator(color: Colors.red)
                        : _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : const CircularProgressIndicator(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading video',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
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
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
