import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'package:reyrazak/config/app_config.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final List<String> _posterImages = [
    'https://image.tmdb.org/t/p/w500/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',
    'https://image.tmdb.org/t/p/w500/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',
    'https://image.tmdb.org/t/p/w500/xOMo8BRK7PfcJv9JCnx7s5hj0PX.jpg',
    'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
    'https://image.tmdb.org/t/p/w500/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg',
    'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Poster Background
          AnimatedPosterBackground(posters: _posterImages),
          // Dark Overlay - Decreased opacity for better poster visibility
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ThemeConfig.background.withOpacity(0.5),
                  ThemeConfig.background.withOpacity(0.75),
                  ThemeConfig.background.withOpacity(0.95),
                ],
              ),
            ),
          ),
          // Login Form
          Center(
            child: SingleChildScrollView(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: ThemeConfig.background.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: Consumer<AuthService>(
                  builder: (context, authService, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'REY-Play',
                          style: TextStyle(
                            color: ThemeConfig.primary,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your Premium Streaming Experience',
                          style: TextStyle(
                            color: ThemeConfig.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        TextField(
                          controller: _usernameController,
                          style: const TextStyle(color: ThemeConfig.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: const TextStyle(color: ThemeConfig.textSecondary),
                            filled: true,
                            fillColor: ThemeConfig.surface,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: ThemeConfig.surface),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: ThemeConfig.primary, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person, color: ThemeConfig.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: ThemeConfig.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: ThemeConfig.textSecondary),
                            filled: true,
                            fillColor: ThemeConfig.surface,
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: ThemeConfig.surface),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: ThemeConfig.primary, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.lock, color: ThemeConfig.textSecondary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: ThemeConfig.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          onSubmitted: (_) => _handleLogin(),
                        ),
                        const SizedBox(height: 32),
                        if (authService.errorMessage != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ThemeConfig.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ThemeConfig.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: ThemeConfig.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    authService.errorMessage!,
                                    style: const TextStyle(color: ThemeConfig.primary, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: authService.isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeConfig.primary,
                              foregroundColor: ThemeConfig.textPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: authService.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: ThemeConfig.textPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPosterBackground extends StatefulWidget {
  final List<String> posters;

  const AnimatedPosterBackground({super.key, required this.posters});

  @override
  State<AnimatedPosterBackground> createState() => _AnimatedPosterBackgroundState();
}

class _AnimatedPosterBackgroundState extends State<AnimatedPosterBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        if (_controller.isCompleted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.posters.length;
          });
          _controller.reset();
          _controller.forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.67,
      ),
      itemCount: widget.posters.length * 10,
      itemBuilder: (context, index) {
        final posterIndex = index % widget.posters.length;
        return AnimatedOpacity(
          opacity: posterIndex == _currentIndex ? 1.0 : 0.6,
          duration: const Duration(milliseconds: 800),
          child: Container(
            margin: const EdgeInsets.all(4),
            child: Image.network(
              widget.posters[posterIndex],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: ThemeConfig.surface);
              },
            ),
          ),
        );
      },
    );
  }
}
