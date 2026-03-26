import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reyrazak/config/app_config.dart';
import 'services/auth_service.dart';
import 'providers/movie_provider.dart';
import 'providers/content_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure status bar using ThemeConfig
  SystemChrome.setSystemUIOverlayStyle(ThemeConfig.lightStatusBar);

  // Set preferred orientations from AppConstants
  SystemChrome.setPreferredOrientations(AppConstants.preferredOrientations);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..initialize()),
        ChangeNotifierProxyProvider<AuthService, MovieProvider>(
          create: (context) => MovieProvider(
            Provider.of<AuthService>(context, listen: false).apiService,
          ),
          update: (context, authService, previous) =>
              previous ?? MovieProvider(authService.apiService),
        ),
        ChangeNotifierProxyProvider<AuthService, ContentProvider>(
          create: (context) => ContentProvider(
            Provider.of<AuthService>(context, listen: false).apiService,
          ),
          update: (context, authService, previous) =>
              previous ?? ContentProvider(authService.apiService),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: AppConstants.showDebugBanner,
        theme: ThemeConfig.themeData,
        home: const AppInitializer(),
      ),
    );
  }
}

// Widget to check auth state and navigate accordingly
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        // Show splash screen while checking auth
        if (authService.isLoading) {
          return Scaffold(
            backgroundColor: ThemeConfig.background,
            body: Center(
              child: CircularProgressIndicator(color: ThemeConfig.primary),
            ),
          );
        }

        // Navigate based on auth state
        return authService.isAuthenticated
            ? const MainScreen()
            : const LoginScreen();
      },
    );
  }
}
