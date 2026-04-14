import 'dart:async';
import 'dart:math';
import 'dart:ui';
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

          // Subtle vignette so the card stands out from the posters
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.4,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.65),
                ],
              ),
            ),
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

  // ── Shared field decoration ──────────────────────────────────────────────
  InputDecoration _fieldDecor({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.45),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: TextStyle(
        color: ThemeConfig.primary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.35), size: 20),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: ThemeConfig.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 600
        ? screenWidth * 0.88
        : screenWidth < 900
            ? 420.0
            : 460.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        // Real frosted-glass blur over the scrolling poster background
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: cardWidth,
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
          decoration: BoxDecoration(
            // Deep translucent surface — darker than before so the
            // blur effect is clearly visible
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 60,
                offset: const Offset(0, 24),
              ),
              BoxShadow(
                color: ThemeConfig.primary.withValues(alpha: 0.08),
                blurRadius: 80,
                spreadRadius: -10,
              ),
            ],
          ),
          child: Consumer<AuthService>(
            builder: (context, authService, _) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo + wordmark ───────────────────────────────
                    Center(
                      child: Column(
                        children: [
                          // Layered glow rings + play icon
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow ring
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: ThemeConfig.primary
                                          .withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                // Inner gradient disc
                                Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        ThemeConfig.primary,
                                        ThemeConfig.primary
                                            .withValues(alpha: 0.7),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: ThemeConfig.primary
                                            .withValues(alpha: 0.5),
                                        blurRadius: 24,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // App name
                          Text(
                            AppConstants.appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Tagline
                          Text(
                            'Stream everything. Anywhere.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Thin accent divider ───────────────────────────
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            ThemeConfig.primary.withValues(alpha: 0.5),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Section label ─────────────────────────────────
                    Text(
                      'SIGN IN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Username field ────────────────────────────────
                    TextFormField(
                      controller: _usernameController,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15),
                      decoration: _fieldDecor(
                        label: 'Username',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),

                    const SizedBox(height: 14),

                    // ── Password field ────────────────────────────────
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15),
                      decoration: _fieldDecor(
                        label: 'Password',
                        icon: Icons.lock_outline_rounded,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white.withValues(alpha: 0.35),
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                      onFieldSubmitted: (_) => _handleLogin(),
                    ),

                    const SizedBox(height: 10),

                    // ── Remember me + Forgot password ─────────────────
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.9,
                          child: Switch(
                            value: _rememberMe,
                            onChanged: (v) =>
                                setState(() => _rememberMe = v),
                            activeColor: ThemeConfig.primary,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.12),
                            inactiveThumbColor:
                                Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        Text(
                          'Remember me',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: ThemeConfig.primary
                                  .withValues(alpha: 0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Error banner ──────────────────────────────────
                    if (authService.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Colors.redAccent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Colors.redAccent, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authService.errorMessage!,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Sign-in button ────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: authService.isLoading
                              ? null
                              : LinearGradient(
                                  colors: [
                                    ThemeConfig.primary,
                                    ThemeConfig.primary
                                        .withValues(alpha: 0.75),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          color: authService.isLoading
                              ? ThemeConfig.primary.withValues(alpha: 0.4)
                              : null,
                          boxShadow: authService.isLoading
                              ? []
                              : [
                                  BoxShadow(
                                    color: ThemeConfig.primary
                                        .withValues(alpha: 0.45),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                        ),
                        child: ElevatedButton(
                          onPressed:
                              authService.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: authService.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor:
                                        AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Version ───────────────────────────────────────
                    Center(
                      child: Text(
                        'v${AppConstants.appVersion}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.2),
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
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
            // 2:3 is the standard movie-poster ratio (width : height)
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: Image.network(
                items[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: ThemeConfig.surface,
                  child: Icon(
                    Icons.movie,
                    size: 50,
                    color: ThemeConfig.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
