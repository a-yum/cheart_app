import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'package:cheart/components/dialogs/add_pet_modal.dart';
import 'package:cheart/components/common/bottom_navbar.dart';
import 'package:cheart/components/pet_profile/pet_card_list.dart';
import 'package:cheart/components/pet_profile/pet_overview_card.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/respiratory_history_provider.dart';
import 'package:cheart/screens/pet_landing_screen.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/utils/navigation_helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _overviewInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_overviewInitialized) {
      _overviewInitialized = true;

      final petProvider = context.read<PetProfileProvider>();
      final petIds = petProvider.petProfiles
          .where((p) => p.id != null)
          .map((p) => p.id!)
          .toList();

      if (petIds.isNotEmpty) {
        final histProvider = context.read<RespiratoryHistoryProvider>();
        histProvider.loadOverviewForPets(petIds);
      }
    }
  }

  Future<void> _handleAddPet(BuildContext context) async {
    try {
      final newPet = await showDialog<PetProfileModel>(
        context: context,
        builder: (context) => AddPetModal(
          onSave: (newPet) => Navigator.pop(context, newPet),
        ),
      );

      if (!context.mounted || newPet == null) return;

      final petProvider = Provider.of<PetProfileProvider>(context, listen: false);
      petProvider.selectPetProfile(newPet);

      if (!context.mounted) return;

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
    } catch (e) {
      if (!context.mounted) return;

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: "Failed to add pet: ${e.toString()}",
        ),
      );
    }
  }

  void _handlePetSelected(BuildContext context, String petName) {
    final petProvider = Provider.of<PetProfileProvider>(context, listen: false);
    final selectedPet = petProvider.petProfiles.firstWhere(
      (profile) => profile.petName == petName,
    );

    petProvider.selectPetProfile(selectedPet);
    navigateWithFade(
      context: context,
      destination: const PetLandingScreen(),
    );
  }

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

              // Pet Card List
              Consumer<PetProfileProvider>(
                builder: (context, petProvider, child) {
                  return PetCardList(
                    petNames: petProvider.petNames,
                    onAddPet: () => _handleAddPet(context),
                    onPetSelected: (petName) => _handlePetSelected(context, petName),
                  );
                },
              ),

              const SizedBox(height: 24),
              const Text(
                'Respiratory Rate Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Overview Cards Section
              Expanded(
                child: Consumer2<PetProfileProvider, RespiratoryHistoryProvider>(
                  builder: (context, petProvider, histProvider, child) {
                    final pets = petProvider.petProfiles;

                    // If no pets exist, show a message
                    if (pets.isEmpty) {
                      return Center(
                        child: Text(
                          'No pets yet. Add one to get started!',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      );
                    }

                    // Otherwise, display a scrollable list of overview cards
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemCount: pets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        final overview = histProvider.overviewMap[pet.id];
                        final error = histProvider.overviewErrors[pet.id];

                        // Loading placeholder (data not yet present and no error)
                        if (overview == null && error == null) {
                          return Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade300,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }

                        // Error card for this pet
                        if (error != null) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              'Error loading data for ${pet.petName}',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          );
                        }

                        // Once overview data is available, wrap the card in an InkWell
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Provider.of<PetProfileProvider>(context, listen: false)
                                .selectPetProfile(pet);
                            navigateWithFade(
                              context: context,
                              destination: const PetLandingScreen(),
                            );
                          },
                          child: PetOverviewCard(
                            pet: pet,
                            sessionCountToday: overview!.sessionCountToday,
                            mostRecentBpm: overview.mostRecentBpm,
                            mostRecentTimestamp: overview.mostRecentTimestamp,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
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
