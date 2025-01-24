import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const Navbar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    const Color navbarBackgroundColor = Color(0xFFFFCDD2); // test color
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: navbarBackgroundColor,
      destinations: const <Widget>[
        NavigationDestination(
          icon: Icon(Icons.home),
          label: 'Home',
          selectedIcon: Icon(Icons.home_filled),
        ),
        NavigationDestination(
          icon: Icon(Icons.monitor_heart),
          label: 'Monitor',
          selectedIcon: Icon(Icons.monitor_heart_outlined),
        ),
        NavigationDestination(
          icon: Icon(Icons.history),
          label: 'History',
          selectedIcon: Icon(Icons.history_rounded),
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
          selectedIcon: Icon(Icons.settings_applications),
        ),
      ],
    );
  }
}
