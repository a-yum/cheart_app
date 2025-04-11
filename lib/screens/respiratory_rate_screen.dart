import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cheart/components/bottom_navbar.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/themes/cheart_theme.dart';

class RespiratoryRateScreen extends StatelessWidget {
  const RespiratoryRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petName = context.watch<PetProfileProvider>().selectedPetProfile?.petName ?? 'your pet';

    return Scaffold(
      backgroundColor: const Color(0xFFE5F0FB), // Light blue background
      appBar: AppBar(
        backgroundColor: CHeartTheme.primaryColor,
        title: Text('Tracking $petName'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // === Timer ===
            const SizedBox(height: 12),
            const Text(
              'Timer: 30',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // === Heart Tracker Icon ===
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // ToDo: Hook up controller logic later
                  },
                  child: const Icon(
                    Icons.favorite,
                    size: 350,
                    color: Color(0xFF8AB6F9), // Soothing heart color
                  ),
                ),
              ),
            ),

            // === Full Width Divider ===
            const Divider(
              thickness: 1,
              height: 0,
              color: Colors.grey,
            ),

            // === Section Between Divider and Buttons ===
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16, bottom: 0),
              child: Column(
                children: [
                  // === Action Buttons Section ===
                  Container(
                    //color: const Color(0xFFF2F1FC), // Distinct button area background
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _ActionButton(
                              icon: Icons.arrow_back,
                              label: 'Back',
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            _ActionButton(
                              icon: Icons.refresh,
                              label: 'Reset',
                              onPressed: () {
                                // ToDo: Hook up reset logic
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // === Learn More Button ===
                        Center(
                          child: TextButton(
                            onPressed: () {
                              // ToDo: Link to Learn More
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text('Learn More'),
                                SizedBox(width: 6),
                                Icon(Icons.info_outline, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 0),
    );
  }
}

// === Reusable Action Button Widget ===
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: CHeartTheme.buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
