import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// Universal Video Player Service
///
/// Determines which video player to use based on the platform:
/// - Android/iOS: video_player + chewie (optimized for mobile)
/// - Web: media_kit (best web support)
/// - Desktop: media_kit (best desktop support)
class UniversalVideoPlayerService {
  static VideoPlayerType get playerType {
    if (kIsWeb) {
      return VideoPlayerType.mediaKit; // Best for web
    }

    // For non-web platforms
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return VideoPlayerType.chewie; // Mobile-optimized
      } else {
        return VideoPlayerType.mediaKit; // Desktop platforms
      }
    } catch (e) {
      // Fallback for unsupported platforms
      return VideoPlayerType.chewie;
    }
  }

  static bool get isMobile => playerType == VideoPlayerType.chewie;
  static bool get isMediaKit => playerType == VideoPlayerType.mediaKit;
}

enum VideoPlayerType {
  chewie,   // video_player + chewie (Android/iOS)
  mediaKit, // media_kit (Web/Desktop)
}
