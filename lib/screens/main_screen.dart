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

  // IndexedStack keeps every screen alive so tab switches are instant and
  // state (scroll positions, TabControllers, loaded data) is preserved.
  static const List<Widget> _screens = [
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
            // IndexedStack renders all screens but only shows _currentIndex.
            // This preserves every screen's State across tab switches.
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
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
