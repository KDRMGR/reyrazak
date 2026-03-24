import 'package:flutter/material.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/bottom_nav_bar.dart';
import '../utils/responsive.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'downloads_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    DownloadsScreen(),
    ProfileScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final showTopNav = isWeb(context);
    final showBottomNav = !isWeb(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          if (showTopNav)
            TopNavBar(
              currentIndex: _currentIndex,
              onTabSelected: _onTabSelected,
            ),
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
      bottomNavigationBar: showBottomNav
          ? BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onTabSelected,
            )
          : null,
    );
  }
}
