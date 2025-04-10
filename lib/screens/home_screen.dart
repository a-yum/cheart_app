import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/screens/pet_landing_screen.dart';
import 'package:cheart/components/add_pet_modal.dart';
import 'package:cheart/components/bottom_navbar.dart';
import 'package:cheart/components/pet_card_list.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/utils/navigation_helpers.dart';

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
                'Pet Profiles',
                style: CHeartTheme.sectionTitle,
              ),
              const SizedBox(height: 16),

              // TODO: Replace with DogCardList widget
              //==========================================
              Consumer<PetProfileProvider>(
                builder: (context, petProvider, child) {
                  return PetCardList(
                    petNames: petProvider.petNames,
                    onAddPet: () async {
                      final newPet = await showDialog<PetProfileModel>(
                        context: context,
                        builder: (context) => AddPetModal(
                          onSave: (newPet) {
                            Navigator.pop(context, newPet); // Close modal and return pet
                          },
                        ),
                      );
                      if (!context.mounted) return;

                      if (newPet != null) {
                        petProvider.addPetProfile(newPet);
                        petProvider.selectPetProfile(newPet);

                        showTopSnackBar(
                          Overlay.of(context),
                          const CustomSnackBar.success(
                            message: "Pet profile saved successfully!",
                          ),
                        );
                        navigateWithFade(
                          context: context,
                          destination: const PetLandingScreen(),
                          replace: true,
                        );
                      }
                    },
                    onPetSelected: (petName) {
                      final selectedPet = petProvider.petProfiles.firstWhere(
                        (profile) => profile.petName == petName,
                      );
                      petProvider.selectPetProfile(selectedPet);

                      navigateWithFade(
                        context: context,
                        destination: const PetLandingScreen(),
                      );
                    },
                  );
                },
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
