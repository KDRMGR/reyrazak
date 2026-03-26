import 'package:flutter/services.dart';

/// Application-wide Constants
///
/// Centralized constants for app metadata, external URLs,
/// feature flags, and system-level configurations.
class AppConstants {
  // ============================================================================
  // Application Metadata
  // ============================================================================

  /// Application name
  static const String appName = 'REY-Play';

  /// Application version
  static const String appVersion = '0.0.1';

  /// Build number
  static const String buildNumber = '1';

  /// Application ID (Android/iOS)
  static const String applicationId = 'com.reyplay.ott';

  /// Developer name
  static const String developerName = 'REY-Play Team';

  /// Support email
  static const String supportEmail = 'support@reyplay.com';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://reyplay.com/privacy';

  /// Terms of service URL
  static const String termsOfServiceUrl = 'https://reyplay.com/terms';

  // ============================================================================
  // External URLs (Login Screen Posters)
  // ============================================================================

  /// Login screen background poster URLs
  static const List<String> loginPosterUrls = [
    'https://image.tmdb.org/t/p/original/3bhkrj58Vtu7enYsRolD1fZdja1.jpg',
    'https://image.tmdb.org/t/p/original/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg',
    'https://image.tmdb.org/t/p/original/oe7mWkvYhK4PLRNAVSvonzyUXNy.jpg',
    'https://image.tmdb.org/t/p/original/nDxJJsIuNKjlzJhUKPCIqGiIr8t.jpg',
    'https://image.tmdb.org/t/p/original/9n2tJBplPbgR2ca05hS5CKXwP2c.jpg',
    'https://image.tmdb.org/t/p/original/dqK9Hag1054tghRQSqLSfrkvQnA.jpg',
  ];

  // ============================================================================
  // System UI Configuration
  // ============================================================================

  /// Preferred device orientations (portrait only by default)
  static const List<DeviceOrientation> preferredOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

  /// Landscape orientations for video playback
  static const List<DeviceOrientation> landscapeOrientations = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  /// All device orientations
  static const List<DeviceOrientation> allOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];

  // ============================================================================
  // Feature Flags
  // ============================================================================

  /// Enable TV shows/series functionality
  static const bool enableTVShows = true;

  /// Enable movies functionality
  static const bool enableMovies = true;

  /// Enable downloads for offline viewing
  static const bool enableDownloads = false;

  /// Enable watchlist/favorites
  static const bool enableWatchlist = false;

  /// Enable search functionality
  static const bool enableSearch = true;

  /// Enable user profiles (multiple profiles per account)
  static const bool enableUserProfiles = false;

  /// Enable parental controls
  static const bool enableParentalControls = false;

  /// Enable chromecast/airplay
  static const bool enableCasting = false;

  /// Enable picture-in-picture mode
  static const bool enablePiP = false;

  /// Enable notifications
  static const bool enableNotifications = false;

  /// Enable dark mode toggle (currently always dark)
  static const bool enableThemeToggle = false;

  /// Enable continue watching row
  static const bool enableContinueWatching = false;

  /// Enable recommendations
  static const bool enableRecommendations = false;

  // ============================================================================
  // Pagination and Lists
  // ============================================================================

  /// Default page size for paginated lists
  static const int defaultPageSize = 20;

  /// Maximum items to load in a single request
  static const int maxPageSize = 100;

  /// Initial items to display
  static const int initialLoadCount = 10;

  /// Load more threshold (items from bottom to trigger load)
  static const int loadMoreThreshold = 3;

  // ============================================================================
  // Image Settings
  // ============================================================================

  /// Placeholder image for missing posters
  static const String placeholderPosterPath = 'assets/images/placeholder_poster.png';

  /// Placeholder image for missing backdrops
  static const String placeholderBackdropPath = 'assets/images/placeholder_backdrop.png';

  /// Default image quality
  static const String imageQuality = 'original';

  /// Enable image caching
  static const bool enableImageCache = true;

  /// Image cache duration in days
  static const int imageCacheDays = 7;

  // ============================================================================
  // Content Rating Labels
  // ============================================================================

  /// Supported content ratings
  static const List<String> contentRatings = [
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17',
    'TV-Y',
    'TV-Y7',
    'TV-G',
    'TV-PG',
    'TV-14',
    'TV-MA',
  ];

  // ============================================================================
  // Genres
  // ============================================================================

  /// Movie genres
  static const List<String> movieGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Thriller',
    'War',
    'Western',
  ];

  /// TV show genres
  static const List<String> tvGenres = [
    'Action & Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Kids',
    'Mystery',
    'News',
    'Reality',
    'Sci-Fi & Fantasy',
    'Soap',
    'Talk',
    'War & Politics',
    'Western',
  ];

  // ============================================================================
  // Sort Options
  // ============================================================================

  /// Available sort options
  static const List<String> sortOptions = [
    'Title A-Z',
    'Title Z-A',
    'Release Date (Newest)',
    'Release Date (Oldest)',
    'Recently Added',
    'Rating (Highest)',
    'Rating (Lowest)',
  ];

  /// Default sort option
  static const String defaultSortOption = 'Recently Added';

  // ============================================================================
  // Error Messages
  // ============================================================================

  /// Generic error message
  static const String genericError = 'Something went wrong. Please try again.';

  /// No internet connection
  static const String noInternetError = 'No internet connection. Please check your network.';

  /// Server error
  static const String serverError = 'Server error. Please try again later.';

  /// Content not found
  static const String contentNotFoundError = 'Content not found.';

  /// No content available
  static const String noContentAvailable = 'No content available at the moment.';

  // ============================================================================
  // Success Messages
  // ============================================================================

  /// Login success
  static const String loginSuccess = 'Login successful!';

  /// Logout success
  static const String logoutSuccess = 'Logged out successfully.';

  // ============================================================================
  // Platform Detection
  // ============================================================================

  /// Is mobile platform (Android/iOS)
  static bool get isMobile => true; // Flutter determines this automatically

  /// Is web platform
  static bool get isWeb => false; // Set based on kIsWeb from foundation

  /// Is desktop platform
  static bool get isDesktop => false;

  // ============================================================================
  // Developer/Debug Settings
  // ============================================================================

  /// Enable debug mode
  static const bool debugMode = true;

  /// Show debug banner
  static const bool showDebugBanner = false;

  /// Enable performance overlay
  static const bool showPerformanceOverlay = false;

  /// Enable widget inspector
  static const bool enableWidgetInspector = false;

  /// Log app lifecycle events
  static const bool logLifecycleEvents = false;

  // ============================================================================
  // Limits and Validation
  // ============================================================================

  /// Maximum username length
  static const int maxUsernameLength = 30;

  /// Maximum password length
  static const int maxPasswordLength = 128;

  /// Maximum bio/description length
  static const int maxBioLength = 500;

  /// Maximum search query length
  static const int maxSearchQueryLength = 100;

  // ============================================================================
  // Timeouts and Delays
  // ============================================================================

  /// Splash screen minimum duration (milliseconds)
  static const int splashScreenDuration = 2000;

  /// Toast/snackbar display duration (milliseconds)
  static const int snackbarDuration = 3000;

  /// Debounce delay for search input (milliseconds)
  static const int searchDebounceDelay = 500;

  /// Auto-logout idle timeout (minutes, null = disabled)
  static const int? autoLogoutIdleMinutes = null;

  // ============================================================================
  // Local Storage Keys (non-auth)
  // ============================================================================

  /// App settings key
  static const String settingsKey = 'app_settings';

  /// User preferences key
  static const String preferencesKey = 'user_preferences';

  /// Theme preference key
  static const String themeKey = 'theme_preference';

  /// Language preference key
  static const String languageKey = 'language_preference';

  // ============================================================================
  // Supported Languages
  // ============================================================================

  /// Default language code
  static const String defaultLanguage = 'en';

  /// Supported language codes
  static const List<String> supportedLanguages = [
    'en', // English
    'es', // Spanish
    'fr', // French
    'de', // German
    'it', // Italian
    'pt', // Portuguese
    'ja', // Japanese
    'ko', // Korean
    'zh', // Chinese
  ];

  // ============================================================================
  // Asset Paths
  // ============================================================================

  /// App logo path
  static const String logoPath = 'assets/images/logo.png';

  /// App icon path
  static const String iconPath = 'assets/images/icon.png';

  /// Splash screen image path
  static const String splashImagePath = 'assets/images/splash.png';

  // ============================================================================
  // URLs and Links
  // ============================================================================

  /// App store URL (iOS)
  static const String appStoreUrl = 'https://apps.apple.com/app/reyplay';

  /// Play store URL (Android)
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.reyplay.ott';

  /// Official website
  static const String websiteUrl = 'https://reyplay.com';

  /// Help/FAQ URL
  static const String helpUrl = 'https://reyplay.com/help';

  /// Contact URL
  static const String contactUrl = 'https://reyplay.com/contact';

  // ============================================================================
  // Social Media
  // ============================================================================

  /// Twitter/X handle
  static const String twitterHandle = '@reyplay';

  /// Facebook page
  static const String facebookUrl = 'https://facebook.com/reyplay';

  /// Instagram handle
  static const String instagramHandle = '@reyplay';
}
