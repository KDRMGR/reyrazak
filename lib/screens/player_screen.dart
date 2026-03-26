import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:reyrazak/config/app_config.dart';
import '../models/movie.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class PlayerScreen extends StatefulWidget {
  final Movie movie;
  final String streamUrl;

  const PlayerScreen({
    super.key,
    required this.movie,
    required this.streamUrl,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  int _retryAttempt = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.apiService.accessToken;

    try {
      // Use the stream URL with embedded token
      final streamUrlWithToken = widget.streamUrl;

      print('Initializing player with URL: $streamUrlWithToken');
      print('Attempt: ${_retryAttempt + 1}');

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(streamUrlWithToken),
        httpHeaders: {
          'X-Emby-Authorization': 'MediaBrowser Token=$token',
          'Accept': '*/*',
          'Accept-Encoding': 'identity',
          'Range': 'bytes=0-',
        },
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
      );

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        _controller.play();
      }
    } catch (e) {
      print('Video player initialization error: $e');

      // Try alternative streaming methods
      if (_retryAttempt == 0 && mounted) {
        print('Retrying with direct stream URL...');
        _retryAttempt++;
        await _tryDirectStream();
      } else if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Unable to play video. The server may not support this format or the file may be corrupted.\n\nTechnical details: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _tryDirectStream() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.apiService.accessToken;
    final movieId = widget.movie.id;

    try {
      // Try with static streaming
      final directUrl = '${ApiService.baseUrl}/Videos/$movieId/stream?Static=true&MediaSourceId=$movieId&api_key=$token';

      print('Trying direct stream URL: $directUrl');

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(directUrl),
        httpHeaders: {
          'X-Emby-Authorization': 'MediaBrowser Token=$token',
          'Accept': '*/*',
        },
        videoPlayerOptions: VideoPlayerOptions(
          allowBackgroundPlayback: false,
          mixWithOthers: false,
        ),
      );

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
        _controller.play();
      }
    } catch (e) {
      print('Direct stream also failed: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Unable to play video. Please try again later or contact support.\n\nError: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.movie.title,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading video',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              )
            : !_isInitialized
                ? const CircularProgressIndicator(color: Colors.red)
                : AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(_controller),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            });
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Center(
                              child: Icon(
                                _controller.value.isPlaying
                                    ? Icons.pause_circle_outline
                                    : Icons.play_circle_outline,
                                color: Colors.white.withOpacity(0.8),
                                size: 80,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: VideoProgressIndicator(
                            _controller,
                            allowScrubbing: true,
                            colors: const VideoProgressColors(
                              playedColor: Colors.red,
                              bufferedColor: Colors.grey,
                              backgroundColor: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
