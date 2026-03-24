import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/movie_provider.dart';
import 'providers/content_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure status bar to blend with device UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        title: 'REY-Play',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.dark(
            primary: Colors.red,
            secondary: Colors.red,
          ),
        ),
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
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Colors.red),
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
