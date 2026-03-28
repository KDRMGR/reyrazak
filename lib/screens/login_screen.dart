import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reyrazak/config/app_config.dart';
import '../services/auth_service.dart';
import 'main_screen.dart';

/// Enhanced Login Screen with 3-Column Scrolling Posters
///
/// Features:
/// - 3 columns of movie/TV posters scrolling in alternating directions
/// - Left column: scrolls down
/// - Middle column: scrolls up
/// - Right column: scrolls down
/// - Glassmorphism login card overlay
/// - Smooth animations
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Animation controllers for login card
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Fade in animation
    _fadeController = AnimationController(
      duration: ThemeConfig.animationSlow,
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Slide up animation
    _slideController = AnimationController(
      duration: ThemeConfig.animationSlow,
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: ThemeConfig.animationNormal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 3-Column Scrolling Posters Background
          const _ScrollingPostersBackground(),

          // Dark overlay for better text readability
          Container(
            color: Colors.black.withValues(alpha: 0.4),
          ),

          // Login Form Card
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildLoginCard(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width < 600
        ? width * 0.9
        : width < 900
            ? 450.0
            : 500.0;

    return Container(
      width: cardWidth,
      constraints: const BoxConstraints(maxWidth: 500),
      margin: EdgeInsets.all(ThemeConfig.spacingL),
      padding: EdgeInsets.all(ThemeConfig.spacingXL),
      decoration: BoxDecoration(
        color: ThemeConfig.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(ThemeConfig.radiusXL),
        border: Border.all(
          color: ThemeConfig.textSecondary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          return Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo/Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ThemeConfig.primary,
                        ThemeConfig.primary.withValues(alpha: 0.7),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ThemeConfig.primary.withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_circle_filled,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                SizedBox(height: ThemeConfig.spacingL),

                // App Name
                Text(
                  AppConstants.appName,
                  style: ThemeConfig.heading1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: ThemeConfig.spacingS),

                Text(
                  'Sign in to continue',
                  style: ThemeConfig.bodyMedium.copyWith(
                    color: ThemeConfig.textSecondary,
                  ),
                ),

                SizedBox(height: ThemeConfig.spacingXL),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                ),

                SizedBox(height: ThemeConfig.spacingM),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _handleLogin(),
                ),

                SizedBox(height: ThemeConfig.spacingM),

                // Remember Me & Forgot Password
                Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      activeColor: ThemeConfig.primary,
                    ),
                    Text(
                      'Remember me',
                      style: ThemeConfig.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        'Forgot password?',
                        style: ThemeConfig.bodyMedium.copyWith(
                          color: ThemeConfig.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ThemeConfig.spacingL),

                // Error Message
                if (authService.errorMessage != null)
                  Container(
                    padding: EdgeInsets.all(ThemeConfig.spacingM),
                    margin: EdgeInsets.only(bottom: ThemeConfig.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: ThemeConfig.spacingS),
                        Expanded(
                          child: Text(
                            authService.errorMessage!,
                            style: ThemeConfig.bodySmall.copyWith(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authService.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
                      ),
                      elevation: 0,
                    ),
                    child: authService.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: ThemeConfig.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: ThemeConfig.spacingL),

                // Version Info
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: ThemeConfig.caption.copyWith(
                    color: ThemeConfig.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 3-Column Scrolling Posters Background
class _ScrollingPostersBackground extends StatefulWidget {
  const _ScrollingPostersBackground();

  @override
  State<_ScrollingPostersBackground> createState() =>
      _ScrollingPostersBackgroundState();
}

class _ScrollingPostersBackgroundState
    extends State<_ScrollingPostersBackground>
    with TickerProviderStateMixin {
  late ScrollController _leftController;
  late ScrollController _middleController;
  late ScrollController _rightController;
  late Timer _scrollTimer;

  // Movie/TV poster URLs (using high-quality TMDB posters)
  final List<String> _leftPosters = [
    'https://image.tmdb.org/t/p/original/3bhkrj58Vtu7enYsRolD1fZdja1.jpg', // Avengers
    'https://image.tmdb.org/t/p/original/qJ2tW6WMUDux911r6m7haRef0WH.jpg', // The Matrix
    'https://image.tmdb.org/t/p/original/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg', // Inception
    'https://image.tmdb.org/t/p/original/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg', // The Shawshank Redemption
    'https://image.tmdb.org/t/p/original/rCzpDGLbOoPwLjy3OAm5NUPOTrC.jpg', // The Lord of the Rings
  ];

  final List<String> _middlePosters = [
    'https://image.tmdb.org/t/p/original/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg', // Joker
    'https://image.tmdb.org/t/p/original/xBHvZcjRiWyobQ9kxBhO6B2dtRI.jpg', // The Dark Knight
    'https://image.tmdb.org/t/p/original/vzmL6fP7aPKNKPRTFnZmiUfciyV.jpg', // Interstellar
    'https://image.tmdb.org/t/p/original/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg', // Oppenheimer
    'https://image.tmdb.org/t/p/original/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg', // Pulp Fiction
  ];

  final List<String> _rightPosters = [
    'https://image.tmdb.org/t/p/original/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg', // The Godfather
    'https://image.tmdb.org/t/p/original/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg', // Fight Club
    'https://image.tmdb.org/t/p/original/faXT8V80JRhnArTAeYXz0Eutpv9.jpg', // Forrest Gump
    'https://image.tmdb.org/t/p/original/suaEOtk1N1sgg2MTM7oZd2cfVp3.jpg', // Titanic
    'https://image.tmdb.org/t/p/original/lxD5ak7BOoinRNehOCA85CQ8ubr.jpg', // The Prestige
  ];

  @override
  void initState() {
    super.initState();
    _initializeScrollControllers();
    _startAutoScroll();
  }

  void _initializeScrollControllers() {
    _leftController = ScrollController();
    _middleController = ScrollController();
    _rightController = ScrollController();
  }

  void _startAutoScroll() {
    // Scroll every 50ms for smooth animation
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      // Left column: scroll down
      if (_leftController.hasClients) {
        final maxScroll = _leftController.position.maxScrollExtent;
        final currentScroll = _leftController.offset;
        final nextScroll = currentScroll + 1.0;

        if (nextScroll >= maxScroll) {
          _leftController.jumpTo(0);
        } else {
          _leftController.jumpTo(nextScroll);
        }
      }

      // Middle column: scroll up
      if (_middleController.hasClients) {
        final currentScroll = _middleController.offset;
        final nextScroll = currentScroll - 1.0;

        if (nextScroll <= 0) {
          _middleController.jumpTo(_middleController.position.maxScrollExtent);
        } else {
          _middleController.jumpTo(nextScroll);
        }
      }

      // Right column: scroll down
      if (_rightController.hasClients) {
        final maxScroll = _rightController.position.maxScrollExtent;
        final currentScroll = _rightController.offset;
        final nextScroll = currentScroll + 1.0;

        if (nextScroll >= maxScroll) {
          _rightController.jumpTo(0);
        } else {
          _rightController.jumpTo(nextScroll);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer.cancel();
    _leftController.dispose();
    _middleController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Column (scrolling down)
        Expanded(
          child: _buildPosterColumn(_leftController, _leftPosters),
        ),
        // Middle Column (scrolling up)
        Expanded(
          child: _buildPosterColumn(_middleController, _middlePosters),
        ),
        // Right Column (scrolling down)
        Expanded(
          child: _buildPosterColumn(_rightController, _rightPosters),
        ),
      ],
    );
  }

  Widget _buildPosterColumn(ScrollController controller, List<String> posters) {
    // Duplicate posters for infinite scroll effect
    final infinitePosters = [...posters, ...posters, ...posters];

    return ListView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: infinitePosters.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(ThemeConfig.spacingXS),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
            child: Image.network(
              infinitePosters[index],
              fit: BoxFit.cover,
              height: 300,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: ThemeConfig.surface,
                  child: Icon(
                    Icons.movie,
                    size: 50,
                    color: ThemeConfig.textSecondary.withValues(alpha: 0.3),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
