import 'package:flutter/material.dart';
import '/themes/cheart_theme.dart';
import '/components/bottom_navbar.dart';

class PetLandingScreen extends StatelessWidget {
  const PetLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: const Center(
        child: Text(
          'Pet Landing Screen\nPlaceholder',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        currentIndex: 1,
      ),
    );
  }
}