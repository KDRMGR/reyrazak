/// Authentication and User Session Configuration
///
/// Centralized configuration for authentication, user session management,
/// and secure storage settings.
class AuthConfig {
  // ============================================================================
  // SharedPreferences Storage Keys
  // ============================================================================

  /// Key for storing access token
  static const String tokenKey = 'access_token';

  /// Key for storing user ID
  static const String userIdKey = 'user_id';

  /// Key for storing username
  static const String usernameKey = 'username';

  /// Key for storing user email (if applicable)
  static const String emailKey = 'user_email';

  /// Key for storing refresh token
  static const String refreshTokenKey = 'refresh_token';

  /// Key for storing session expiry timestamp
  static const String sessionExpiryKey = 'session_expiry';

  /// Key for storing remember me preference
  static const String rememberMeKey = 'remember_me';

  /// Key for storing last login timestamp
  static const String lastLoginKey = 'last_login';

  // ============================================================================
  // Session Settings
  // ============================================================================

  /// Enable auto-login on app start
  static const bool enableAutoLogin = true;

  /// Session timeout duration in hours (null = no timeout)
  static const int? sessionTimeoutHours = null;

  /// Enable session refresh
  static const bool enableSessionRefresh = false;

  /// Refresh session when this many minutes are left before expiry
  static const int refreshBeforeExpiryMinutes = 30;

  /// Maximum number of concurrent sessions per user
  static const int maxConcurrentSessions = 5;

  // ============================================================================
  // Security Settings
  // ============================================================================

  /// Enable secure storage (use flutter_secure_storage instead of SharedPreferences)
  /// Note: Requires flutter_secure_storage package
  static const bool useSecureStorage = false;

  /// Enable token encryption in storage
  static const bool encryptTokens = false;

  /// Enable biometric authentication (fingerprint/face)
  static const bool enableBiometricAuth = false;

  /// Require biometric auth for sensitive operations
  static const bool requireBiometricForPlayback = false;

  /// Clear session data on logout
  static const bool clearDataOnLogout = true;

  /// Clear cache on logout
  static const bool clearCacheOnLogout = false;

  // ============================================================================
  // Login Settings
  // ============================================================================

  /// Minimum password length
  static const int minPasswordLength = 4;

  /// Maximum login attempts before lockout
  static const int maxLoginAttempts = 5;

  /// Lockout duration in minutes after max attempts
  static const int lockoutDurationMinutes = 15;

  /// Show password visibility toggle
  static const bool showPasswordToggle = true;

  /// Remember username by default
  static const bool rememberUsernameByDefault = false;

  // ============================================================================
  // Token Settings
  // ============================================================================

  /// Token prefix for authorization headers
  static const String tokenPrefix = 'Bearer';

  /// Token type (Bearer, X-Emby-Token, etc.)
  static const String tokenType = 'X-Emby-Token';

  /// Token refresh buffer in seconds
  static const int tokenRefreshBufferSeconds = 300;

  // ============================================================================
  // User Data
  // ============================================================================

  /// Cache user profile data
  static const bool cacheUserProfile = true;

  /// User profile cache duration in hours
  static const int userProfileCacheHours = 24;

  /// Sync user preferences across devices
  static const bool syncUserPreferences = false;

  // ============================================================================
  // Privacy Settings
  // ============================================================================

  /// Enable analytics tracking for user behavior
  static const bool enableAnalytics = false;

  /// Track user watch history
  static const bool trackWatchHistory = true;

  /// Maximum watch history items to store
  static const int maxWatchHistoryItems = 100;

  /// Enable user activity logging
  static const bool logUserActivity = false;

  // ============================================================================
  // Error Handling
  // ============================================================================

  /// Auto-logout on authentication error
  static const bool autoLogoutOnAuthError = true;

  /// Show error messages on login failure
  static const bool showLoginErrorMessages = true;

  /// Retry failed authentication requests
  static const bool retryFailedAuth = false;

  /// Number of retry attempts for authentication
  static const int authRetryAttempts = 2;

  // ============================================================================
  // Guest Mode
  // ============================================================================

  /// Enable guest/anonymous browsing
  static const bool enableGuestMode = false;

  /// Guest session duration in hours
  static const int guestSessionHours = 24;

  /// Limited functionality in guest mode
  static const bool limitGuestFeatures = true;

  // ============================================================================
  // Validation Settings
  // ============================================================================

  /// Validate username format
  static const bool validateUsername = true;

  /// Username regex pattern (alphanumeric and underscore)
  static const String usernamePattern = r'^[a-zA-Z0-9_]+$';

  /// Minimum username length
  static const int minUsernameLength = 3;

  /// Maximum username length
  static const int maxUsernameLength = 30;

  /// Validate email format (if email is used)
  static const bool validateEmail = false;

  // ============================================================================
  // Session Storage Prefix
  // ============================================================================

  /// Prefix for all auth-related storage keys
  static const String storagePrefix = 'rey_play_';

  /// Get prefixed key
  static String getPrefixedKey(String key) => '$storagePrefix$key';

  // ============================================================================
  // Error Messages
  // ============================================================================

  /// Invalid credentials error message
  static const String invalidCredentialsMessage = 'Invalid username or password';

  /// Session expired error message
  static const String sessionExpiredMessage = 'Your session has expired. Please login again.';

  /// Network error message
  static const String networkErrorMessage = 'Unable to connect. Please check your network.';

  /// Account locked error message
  static const String accountLockedMessage = 'Account temporarily locked. Please try again later.';

  /// Generic error message
  static const String genericErrorMessage = 'An error occurred. Please try again.';

  // ============================================================================
  // Debug Settings
  // ============================================================================

  /// Log authentication events
  static const bool logAuthEvents = true;

  /// Show detailed error messages in debug mode
  static const bool verboseErrorLogging = true;

  /// Mock authentication for testing
  static const bool enableMockAuth = false;
}
