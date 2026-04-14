import 'dart:async';
import 'dart:math';
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
///
/// Each visit the master poster pool is shuffled and split evenly across the
/// three columns, and each column jumps to a random starting offset — so no
/// two logins look the same.
class _ScrollingPostersBackground extends StatefulWidget {
  const _ScrollingPostersBackground();

  @override
  State<_ScrollingPostersBackground> createState() =>
      _ScrollingPostersBackgroundState();
}

class _ScrollingPostersBackgroundState
    extends State<_ScrollingPostersBackground> {
  late ScrollController _leftController;
  late ScrollController _middleController;
  late ScrollController _rightController;
  late Timer _scrollTimer;

  // The full poster pool — 36 unique entries shuffled fresh on every login.
  // Using TMDB w500 thumbnails (smaller, faster, more reliable than /original).
  static const String _base = 'https://image.tmdb.org/t/p/w500';
  static const List<String> _masterPool = [
    // — Action / Sci-Fi ——————————————————————————————
    '$_base/3bhkrj58Vtu7enYsRolD1fZdja1.jpg', // Avengers: Infinity War
    '$_base/or06FN3Dka5tukK1e9sl16pB3iy.jpg',  // Avengers: Endgame
    '$_base/qJ2tW6WMUDux911r6m7haRef0WH.jpg',  // The Matrix
    '$_base/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg',  // Inception
    '$_base/vzmL6fP7aPKNKPRTFnZmiUfciyV.jpg',  // Interstellar
    '$_base/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg',  // Oppenheimer
    '$_base/tnAuB8sAhnAsbV6JCDT6xD4u7jz.jpg',  // Tenet
    '$_base/AkJQpZp9WoNdj7pLYSj1L0RcMMN.jpg',  // The Batman
    '$_base/6DrHO1jr3qVrViUO6s6kFiAGM7.jpg',   // Dune: Part One
    '$_base/d5NXSklpcvkCgnTG7TL8T9XSMWX.jpg',  // John Wick
    // — Drama / Thriller ——————————————————————————————
    '$_base/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg',  // The Shawshank Redemption
    '$_base/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg',  // The Godfather
    '$_base/8Gxv8gSFCU0XGDykEGv7zR1n2ua.jpg',  // Pulp Fiction
    '$_base/39wmItIWsg5sZMyRUHLkWBcuVCM.jpg',  // Fight Club
    '$_base/faXT8V80JRhnArTAeYXz0Eutpv9.jpg',  // Forrest Gump
    '$_base/suaEOtk1N1sgg2MTM7oZd2cfVp3.jpg',  // Titanic
    '$_base/lxD5ak7BOoinRNehOCA85CQ8ubr.jpg',  // The Prestige
    '$_base/kqjL17yufvn9OVLyXYpvtyrFfak.jpg',  // 1917
    // — Superhero ————————————————————————————————————
    '$_base/xBHvZcjRiWyobQ9kxBhO6B2dtRI.jpg',  // The Dark Knight
    '$_base/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg',  // Joker
    '$_base/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',  // Spider-Man: No Way Home
    '$_base/uxzzxijgPIY7slzFvMotPv8wjKA.jpg',  // Black Panther
    '$_base/e1mjopzAS2KNsvpbpahQ1a6SkSn.jpg',  // Captain America: Civil War
    '$_base/imekS7f1OuHyUP2LAiTEM0zBzUz.jpg',  // Wonder Woman
    '$_base/r7vmZjiyZw9rpJMQJdXpjgiCOk9.jpg',  // Guardians of the Galaxy
    '$_base/uGBVj3bEbCoZbDjjl9wTxcygko1.jpg',  // Doctor Strange
    // — TV Series ————————————————————————————————————
    '$_base/rCzpDGLbOoPwLjy3OAm5NUPOTrC.jpg',  // The Lord of the Rings (series)
    '$_base/u3bZgnGQ9T01sWNhyveQz0wH0Hl.jpg',  // Game of Thrones
    '$_base/49WJfeN0moxb9IPfGn8AIqMGskD.jpg',  // Stranger Things
    '$_base/cZ0d3rtvXPVc6TKbPnkO6rKVHCb.jpg',  // The Witcher
    '$_base/reEMJA1uzscCbkpeRJeTT2bjqUp.jpg',  // Money Heist
    '$_base/sWgBv7LV2PRoQgkxwlibLycgKAK.jpg',  // The Mandalorian
    '$_base/kEl2t3OhXc3Zb9FBh1AuYzRTgZp.jpg',  // Loki
    '$_base/stTEycfG9928HYGEISBFaG1ngjM.jpg',  // The Boys
    '$_base/vUUqzWa2LnHIVqkaKVn3nyfYBNQ.jpg',  // Peaky Blinders
    '$_base/ggFHVNu6YYI5L9pCfOacjizRGt.jpg',   // Breaking Bad
  ];

  // Per-column poster lists — filled in initState after shuffling
  late List<String> _leftPosters;
  late List<String> _middlePosters;
  late List<String> _rightPosters;

  @override
  void initState() {
    super.initState();
    _buildShuffledColumns();
    _initControllers();
    _startAutoScroll();
  }

  /// Shuffle the master pool and divide evenly across the three columns.
  void _buildShuffledColumns() {
    final rng = Random();
    final shuffled = List<String>.from(_masterPool)..shuffle(rng);

    // Ensure each column has exactly 12 items (36 total)
    const perCol = 12;
    _leftPosters   = shuffled.sublist(0, perCol);
    _middlePosters = shuffled.sublist(perCol, perCol * 2);
    _rightPosters  = shuffled.sublist(perCol * 2, perCol * 3);
  }

  void _initControllers() {
    _leftController   = ScrollController();
    _middleController = ScrollController();
    _rightController  = ScrollController();

    // Jump each column to a random starting offset so they begin at
    // completely different positions on every login.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rng = Random();
      for (final ctrl in [_leftController, _middleController, _rightController]) {
        if (ctrl.hasClients && ctrl.position.maxScrollExtent > 0) {
          ctrl.jumpTo(rng.nextDouble() * ctrl.position.maxScrollExtent);
        }
      }
    });
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted) return;
      _step(_leftController,   direction: 1);   // down
      _step(_middleController, direction: -1);  // up
      _step(_rightController,  direction: 1);   // down
    });
  }

  void _step(ScrollController ctrl, {required int direction}) {
    if (!ctrl.hasClients) return;
    final max  = ctrl.position.maxScrollExtent;
    final next = ctrl.offset + direction * 1.0;

    if (direction > 0) {
      ctrl.jumpTo(next >= max ? 0 : next);
    } else {
      ctrl.jumpTo(next <= 0 ? max : next);
    }
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
        Expanded(child: _buildColumn(_leftController,   _leftPosters)),
        Expanded(child: _buildColumn(_middleController, _middlePosters)),
        Expanded(child: _buildColumn(_rightController,  _rightPosters)),
      ],
    );
  }

  Widget _buildColumn(ScrollController controller, List<String> posters) {
    // Duplicate once — 24 items is enough to fill any screen height without
    // a visible seam, and far less repetition than the old 5×3 approach.
    final items = [...posters, ...posters];

    return ListView.builder(
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(ThemeConfig.spacingXS),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ThemeConfig.radiusM),
            child: Image.network(
              items[index],
              fit: BoxFit.cover,
              height: 280,
              errorBuilder: (_, __, ___) => Container(
                height: 280,
                color: ThemeConfig.surface,
                child: Icon(
                  Icons.movie,
                  size: 50,
                  color: ThemeConfig.textSecondary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
