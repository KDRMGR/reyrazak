import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Theme and UI Configuration
///
/// Centralized configuration for all UI-related settings including
/// colors, typography, spacing, animations, and theme data.
class ThemeConfig {
  // ============================================================================
  // Color Palette
  // ============================================================================

  /// Primary brand color (Netflix-inspired red)
  static const Color primary = Color(0xFFE50914);

  /// Background color (near black)
  static const Color background = Color(0xFF0B0B0B);

  /// Surface color for cards and containers
  static const Color surface = Color(0xFF141414);

  /// Primary text color (white)
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary text color (light grey)
  static const Color textSecondary = Color(0xFFAAAAAA);

  /// Transparent color
  static const Color transparent = Colors.transparent;

  /// Accent color for highlights
  static const Color accent = Color(0xFFE50914);

  /// Error color
  static const Color error = Color(0xFFCF6679);

  /// Success color
  static const Color success = Color(0xFF4CAF50);

  /// Warning color
  static const Color warning = Color(0xFFFFA726);

  /// Info color
  static const Color info = Color(0xFF29B6F6);

  /// Divider color
  static const Color divider = Color(0xFF2A2A2A);

  /// Shimmer base color (for loading skeletons)
  static const Color shimmerBase = Color(0xFF1A1A1A);

  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFF2A2A2A);

  // ============================================================================
  // Typography
  // ============================================================================

  /// App font family
  static const String fontFamily = 'Roboto';

  /// Heading 1 text style
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  /// Heading 2 text style
  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: -0.5,
  );

  /// Heading 3 text style
  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  /// Body large text style
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  /// Body medium text style
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimary,
  );

  /// Body small text style
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  /// Caption text style
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
  );

  /// Button text style
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // Spacing
  // ============================================================================

  /// Extra small spacing (4px)
  static const double spacingXS = 4.0;

  /// Small spacing (8px)
  static const double spacingS = 8.0;

  /// Medium spacing (16px)
  static const double spacingM = 16.0;

  /// Large spacing (24px)
  static const double spacingL = 24.0;

  /// Extra large spacing (32px)
  static const double spacingXL = 32.0;

  /// Extra extra large spacing (48px)
  static const double spacingXXL = 48.0;

  // ============================================================================
  // Border Radius
  // ============================================================================

  /// Small border radius (4px)
  static const double radiusS = 4.0;

  /// Medium border radius (8px)
  static const double radiusM = 8.0;

  /// Large border radius (12px)
  static const double radiusL = 12.0;

  /// Extra large border radius (16px)
  static const double radiusXL = 16.0;

  /// Circular border radius
  static const double radiusCircular = 999.0;

  // ============================================================================
  // Elevation and Shadows
  // ============================================================================

  /// Card elevation
  static const double cardElevation = 4.0;

  /// Modal elevation
  static const double modalElevation = 8.0;

  /// Drawer elevation
  static const double drawerElevation = 16.0;

  // ============================================================================
  // Animation Durations
  // ============================================================================

  /// Fast animation duration (200ms)
  static const Duration animationFast = Duration(milliseconds: 200);

  /// Normal animation duration (300ms)
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Slow animation duration (500ms)
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Extra slow animation duration (800ms)
  static const Duration animationExtraSlow = Duration(milliseconds: 800);

  /// Page transition duration
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  /// Carousel auto-play interval (5 seconds)
  static const Duration carouselAutoPlayInterval = Duration(seconds: 5);

  // ============================================================================
  // Layout
  // ============================================================================

  /// Breakpoint for web/tablet layout (800px)
  static const double webLayoutBreakpoint = 800.0;

  /// Maximum content width for web
  static const double maxContentWidth = 1200.0;

  /// Grid column count for mobile
  static const int gridColumnsMobile = 2;

  /// Grid column count for tablet
  static const int gridColumnsTablet = 3;

  /// Grid column count for web
  static const int gridColumnsWeb = 4;

  /// Aspect ratio for movie posters (2:3)
  static const double posterAspectRatio = 2 / 3;

  /// Aspect ratio for backdrop images (16:9)
  static const double backdropAspectRatio = 16 / 9;

  // ============================================================================
  // Icon Sizes
  // ============================================================================

  /// Small icon size
  static const double iconSizeS = 16.0;

  /// Medium icon size
  static const double iconSizeM = 24.0;

  /// Large icon size
  static const double iconSizeL = 32.0;

  /// Extra large icon size
  static const double iconSizeXL = 48.0;

  // ============================================================================
  // Button Sizes
  // ============================================================================

  /// Button height
  static const double buttonHeight = 48.0;

  /// Small button height
  static const double buttonHeightSmall = 36.0;

  /// Large button height
  static const double buttonHeightLarge = 56.0;

  /// Button horizontal padding
  static const double buttonPaddingHorizontal = 24.0;

  // ============================================================================
  // System UI Overlay Styles
  // ============================================================================

  /// System overlay style for light status bar
  static const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// System overlay style for dark status bar
  static const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );

  /// Immersive mode for video playback
  static const SystemUiOverlayStyle immersiveMode = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  // ============================================================================
  // Theme Data
  // ============================================================================

  /// Get the main app theme
  static ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        primaryColor: primary,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          secondary: accent,
          surface: surface,
          error: error,
          onPrimary: textPrimary,
          onSecondary: textPrimary,
          onSurface: textPrimary,
          onError: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          systemOverlayStyle: lightStatusBar,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: heading3,
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusM),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: textPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: buttonPaddingHorizontal,
              vertical: spacingM,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radiusM),
            ),
            textStyle: button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            textStyle: button,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(radiusM),
            borderSide: const BorderSide(color: error, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: spacingM,
            vertical: spacingM,
          ),
          hintStyle: TextStyle(color: textSecondary),
        ),
        dividerTheme: const DividerThemeData(
          color: divider,
          thickness: 1,
          space: spacingM,
        ),
        iconTheme: const IconThemeData(
          color: textPrimary,
          size: iconSizeM,
        ),
        textTheme: const TextTheme(
          displayLarge: heading1,
          displayMedium: heading2,
          displaySmall: heading3,
          bodyLarge: bodyLarge,
          bodyMedium: bodyMedium,
          bodySmall: bodySmall,
          labelLarge: button,
          labelMedium: caption,
        ),
      );
}
