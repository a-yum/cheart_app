import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0; // Tracks selected index (default to 0)

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index on tap
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color navbarBackgroundColor = Color(0xFFFFCDD2); // 0xFFFFCDD2

    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      backgroundColor: navbarBackgroundColor,
      destinations: [
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
