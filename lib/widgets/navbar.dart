import 'package:flutter/material.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const Navbar({
    Key? key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color navbarBackgroundColor =
        Color(0xFFFFCDD2); // Custom background color

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: navbarBackgroundColor,
      destinations: const [
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
