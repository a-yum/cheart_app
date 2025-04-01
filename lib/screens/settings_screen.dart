import 'package:flutter/material.dart';
import '/themes/cheart_theme.dart';
import '/components/bottom_navbar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: const Center(
        child: Text(
          'Settings Screen\nPlaceholder',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        currentIndex: 3,
    ),
    );
  }
}