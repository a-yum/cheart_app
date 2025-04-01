import 'package:flutter/material.dart';
import '/themes/cheart_theme.dart';
import '/components/bottom_navbar.dart';
import '/components/dog_card_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CHeart'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: CHeartTheme.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Dog',
                style: CHeartTheme.sectionTitle,
              ),
              const SizedBox(height: 16),
              
              // TODO: Replace with DogCardList widget
              //==========================================
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text('Coming Soon'),
                ),
              ),
              //==========================================

              const SizedBox(height: 24),
              const Text(
                'Respiratory Rate Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // TODO: Replace with Graph widget
              //==========================================
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('Coming Soon'),
                  ),
                ),
              ),
              //==========================================
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(
        currentIndex: 0, // Home is active
      ),
    );
  }
}
