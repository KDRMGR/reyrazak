import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'providers/movie_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, MovieProvider>(
          create: (context) => MovieProvider(
            Provider.of<AuthService>(context, listen: false).apiService,
          ),
          update: (context, authService, previous) =>
              previous ?? MovieProvider(authService.apiService),
        ),
      ],
      child: MaterialApp(
        title: 'REYRAZAK',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: ColorScheme.dark(
            primary: Colors.red,
            secondary: Colors.red,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
