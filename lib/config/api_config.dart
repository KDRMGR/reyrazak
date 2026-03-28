/// API and Network Configuration
///
/// Centralized configuration for all API-related settings including
/// base URLs, endpoints, timeouts, headers, and retry policies.
class ApiConfig {
  // ============================================================================
  // Base Configuration
  // ============================================================================

  /// Base URL for the API server
  /// Change this to point to different environments (dev/staging/prod)
  static const String baseUrl = 'https://media.aplayworld.in';

  /// API version (if applicable)
  static const String apiVersion = 'v1';

  // ============================================================================
  // Client Metadata
  // ============================================================================

  /// Client application name
  static const String clientName = 'REY-Play';

  /// Client device type
  static const String deviceType = 'Mobile';

  /// Unique device identifier
  /// TODO: Generate dynamically or use device-specific ID
  static const String deviceId = 'device123';

  /// Application version
  static const String appVersion = '1.0';

  // ============================================================================
  // MediaBrowser/Emby/Jellyfin Authorization Header
  // ============================================================================

  /// Constructs the X-Emby-Authorization header value
  static String get embyAuthHeader =>
      'MediaBrowser Client="$clientName", Device="$deviceType", DeviceId="$deviceId", Version="$appVersion"';

  // ============================================================================
  // API Endpoints
  // ============================================================================

  /// Authentication endpoint
  static const String authEndpoint = '/Users/AuthenticateByName';

  /// Fetch all movies
  static const String moviesEndpoint = '/Items?IncludeItemTypes=Movie&Recursive=true';

  /// Fetch all TV series
  static const String seriesEndpoint = '/Items?IncludeItemTypes=Series&Recursive=true';

  /// Fetch all content (movies and series)
  static const String allContentEndpoint = '/Items?IncludeItemTypes=Movie,Series&Recursive=true';

  /// Get item by ID (requires {itemId} parameter)
  static String itemEndpoint(String itemId) => '/Items/$itemId';

  /// Get primary image for an item
  static String primaryImageEndpoint(String itemId) => '/Items/$itemId/Images/Primary';

  /// Get backdrop image for an item
  static String backdropImageEndpoint(String itemId) => '/Items/$itemId/Images/Backdrop';

  /// Direct download endpoint
  static String downloadEndpoint(String itemId, String token) =>
      '/Items/$itemId/Download?api_key=$token';

  /// Static stream endpoint
  static String staticStreamEndpoint(String itemId, String sourceId, String token) =>
      '/Videos/$itemId/stream?Static=true&MediaSourceId=$sourceId&api_key=$token';

  /// HLS transcoded stream endpoint
  static String hlsStreamEndpoint(String itemId, String token) =>
      '/Videos/$itemId/master.m3u8?VideoCodec=h264&AudioCodec=aac&MaxStreamingBitrate=140000000&TranscodingMaxAudioChannels=2&api_key=$token';

  /// Get seasons for a TV series
  static String seasonsEndpoint(String seriesId) => '/Shows/$seriesId/Seasons';

  /// Get episodes for a season
  static String episodesEndpoint(String seasonId) => '/Items?ParentId=$seasonId';

  // ============================================================================
  // Network Settings
  // ============================================================================

  /// Connection timeout in seconds
  static const int connectionTimeout = 30;

  /// Read timeout in seconds
  static const int readTimeout = 30;

  /// Write timeout in seconds
  static const int writeTimeout = 30;

  /// Maximum number of retry attempts for failed requests
  static const int maxRetryAttempts = 3;

  /// Delay between retry attempts in milliseconds
  static const int retryDelayMs = 1000;

  // ============================================================================
  // HTTP Headers
  // ============================================================================

  /// Default headers for all requests
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Headers with authentication
  static Map<String, String> authHeaders(String? token) => {
        ...defaultHeaders,
        'X-Emby-Authorization': embyAuthHeader,
        if (token != null) 'X-Emby-Token': token,
      };

  // ============================================================================
  // Cache Settings
  // ============================================================================

  /// Enable response caching
  static const bool enableCache = true;

  /// Cache duration in hours
  static const int cacheDurationHours = 24;

  /// Maximum cache size in MB
  static const int maxCacheSizeMB = 100;

  // ============================================================================
  // Streaming Configuration
  // ============================================================================

  /// Preferred streaming method priority
  /// 1 = Download, 2 = Static Stream, 3 = HLS Transcode
  static const List<String> streamingPriority = [
    'download',
    'static',
    'hls',
  ];

  /// Enable automatic quality switching
  static const bool enableAdaptiveStreaming = true;

  /// Preferred video codec
  static const String preferredVideoCodec = 'h264';

  /// Preferred audio codec
  static const String preferredAudioCodec = 'aac';

  // ============================================================================
  // Debug Settings
  // ============================================================================

  /// Enable debug logging
  static const bool enableDebugLogging = true;

  /// Log request/response details
  static const bool logNetworkTraffic = true;

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// Constructs full URL from endpoint
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';

  /// Checks if URL is from the configured base URL
  static bool isValidBaseUrl(String url) => url.startsWith(baseUrl);
}
