import 'package:flutter/material.dart';
import '/themes/cheart_theme.dart';
import '/components/bottom_navbar.dart';

class RespiratoryRateScreen extends StatelessWidget {
  const RespiratoryRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Respiratory Rate'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: const Center(
        child: Text(
          'Respiratory Rate Screen\nPlaceholder',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: 2,
        onTap: (index) {
          // TODO: Navigation logic will be implemented when global state is added
        },
      ),
    );
  }
}