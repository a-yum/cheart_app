import 'package:flutter/material.dart';
import '/themes/cheart_theme.dart';
import '/config/cheart_routes.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.pet);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.respiratory);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.settings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: CHeartTheme.bottomNavSelected,
      unselectedItemColor: CHeartTheme.bottomNavUnselected,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Pet'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Graph'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
