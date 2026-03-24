import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../services/auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.apiService.accessToken;

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.streamUrl),
        httpHeaders: {
          'X-Emby-Authorization': 'MediaBrowser Token=$token',
        },
      );

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
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
