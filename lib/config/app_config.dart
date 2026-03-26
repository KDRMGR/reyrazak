/// Application Configuration Hub
///
/// This file serves as the single entry point for all application configurations.
/// Import this file to access all config settings throughout the app.
///
/// Usage:
/// ```dart
/// import 'package:reyrazak/config/app_config.dart';
///
/// // Access API configuration
/// String baseUrl = ApiConfig.baseUrl;
/// String authEndpoint = ApiConfig.authEndpoint;
///
/// // Access theme configuration
/// Color primary = ThemeConfig.primary;
/// ThemeData theme = ThemeConfig.themeData;
///
/// // Access media player configuration
/// bool autoPlay = MediaConfig.autoPlay;
/// int maxRetries = MediaConfig.maxStreamRetryAttempts;
///
/// // Access authentication configuration
/// String tokenKey = AuthConfig.tokenKey;
/// bool enableAutoLogin = AuthConfig.enableAutoLogin;
///
/// // Access app constants
/// String appName = AppConstants.appName;
/// List<String> loginPosters = AppConstants.loginPosterUrls;
/// ```
///
/// Configuration Categories:
/// - [ApiConfig] - Network, API, and streaming configuration
/// - [MediaConfig] - Video player and media playback settings
/// - [AuthConfig] - Authentication and user session settings
/// - [ThemeConfig] - UI theme, colors, typography, and styling
/// - [AppConstants] - App metadata, feature flags, and constants
library;

// Export all configuration files
export 'api_config.dart';
export 'auth_config.dart';
export 'constants.dart';
export 'media_config.dart';
export 'theme_config.dart';

/// Application environment
enum Environment {
  /// Development environment
  development,

  /// Staging environment
  staging,

  /// Production environment
  production,
}

/// Global App Configuration Class
///
/// Provides environment detection and utilities.
class AppConfig {
  // Prevent instantiation
  AppConfig._();

  /// Current environment (dev, staging, production)
  /// This can be extended in the future to support multiple environments
  static Environment environment = Environment.production;

  /// Check if running in development mode
  static bool get isDevelopment => environment == Environment.development;

  /// Check if running in staging mode
  static bool get isStaging => environment == Environment.staging;

  /// Check if running in production mode
  static bool get isProduction => environment == Environment.production;
}
