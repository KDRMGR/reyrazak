import 'package:flutter/material.dart';
import 'package:reyrazak/config/app_config.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';

class TopNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  const TopNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            ThemeConfig.background,
            ThemeConfig.background.withOpacity(0.0),
          ],
        ),
      ),
      child: Row(
        children: [
          const Text(
            'REY-Play',
            style: TextStyle(
              color: ThemeConfig.primary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 60),
          _navItem(context, 'Home', 0),
          _navItem(context, 'Search', 1),
          _navItem(context, 'Library', 2),
          const Spacer(),
          _HoverIconButton(
            icon: Icons.search,
            onPressed: () => onTabSelected(1),
          ),
          const SizedBox(width: 20),
          _ProfileDropdown(onTabSelected: onTabSelected),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, String title, int index) {
    final isSelected = currentIndex == index;
    return _NavMenuItem(
      title: title,
      isSelected: isSelected,
      onTap: () => onTabSelected(index),
    );
  }
}

class _NavMenuItem extends StatefulWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavMenuItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavMenuItem> createState() => _NavMenuItemState();
}

class _NavMenuItemState extends State<_NavMenuItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: widget.isSelected
                    ? ThemeConfig.primary
                    : ThemeConfig.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            widget.title,
            style: TextStyle(
              color: widget.isSelected || _isHovered
                  ? ThemeConfig.textPrimary
                  : ThemeConfig.textSecondary,
              fontSize: 16,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HoverIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_HoverIconButton> createState() => _HoverIconButtonState();
}

class _HoverIconButtonState extends State<_HoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: IconButton(
        icon: Icon(
          widget.icon,
          color: _isHovered ? ThemeConfig.textPrimary : ThemeConfig.textSecondary,
        ),
        onPressed: widget.onPressed,
      ),
    );
  }
}

class _ProfileDropdown extends StatefulWidget {
  final Function(int) onTabSelected;

  const _ProfileDropdown({required this.onTabSelected});

  @override
  State<_ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<_ProfileDropdown> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        color: ThemeConfig.surface,
        child: CircleAvatar(
          backgroundColor: _isHovered ? ThemeConfig.primary : Colors.grey[800],
          radius: 20,
          child: const Icon(Icons.person, color: ThemeConfig.textPrimary, size: 22),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: const [
                Icon(Icons.person, color: ThemeConfig.textPrimary, size: 20),
                SizedBox(width: 12),
                Text('Profile', style: TextStyle(color: ThemeConfig.textPrimary)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: const [
                Icon(Icons.logout, color: ThemeConfig.primary, size: 20),
                SizedBox(width: 12),
                Text('Logout', style: TextStyle(color: ThemeConfig.primary)),
              ],
            ),
          ),
        ],
        onSelected: (value) {
          if (value == 'profile') {
            widget.onTabSelected(4);
          } else if (value == 'logout') {
            final auth = Provider.of<AuthService>(context, listen: false);
            auth.logout();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
      ),
    );
  }
}
