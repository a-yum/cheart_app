import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/components/common/bottom_navbar.dart';
import 'package:cheart/components/pet_profile/pet_profile_avatar.dart';
import 'package:cheart/screens/graph_screen.dart';
import 'package:cheart/screens/respiratory_rate_screen.dart';

class PetLandingScreen extends StatelessWidget {
  const PetLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProfileProvider>(context);
    final selectedPet = petProvider.selectedPetProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: CHeartTheme.screenPadding,
          child: selectedPet == null
              ? const Center(
                  child: Text(
                    'Add a pet',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // PetProfileAvatar
                          PetProfileAvatar(
                            petName: selectedPet.petName,
                            imagePath: selectedPet.petProfileImagePath,
                            size: 80.0, // diameter of 80 equals radius 40
                          ),
                          const SizedBox(width: 16),
                          // Pet details on the right
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedPet.petName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${selectedPet.petAgeInYears} years old',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedPet.petBreed ?? '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Data section
                      const Text(
                        'Pet Statistics',
                        style: CHeartTheme.sectionTitle,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildDataCard('Heart Rate', '78 bpm'),
                          _buildDataCard('Temperature', '101°F'),
                          _buildDataCard('Activity', 'High'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Monitor and View Breathing Rate cards
                      Container(
                        decoration: BoxDecoration(
                          color: CHeartTheme.primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RespiratoryRateScreen(),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: const [
                                    Text(
                                      'Monitor',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 1, color: Colors.white),
                            InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GraphScreen(),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: const [
                                    Text(
                                      'View Breathing Rate',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Spacer(),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }

  Widget _buildDataCard(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
