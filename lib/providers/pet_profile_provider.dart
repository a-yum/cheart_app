import 'package:flutter/material.dart';
import '/models/pet_profile_model.dart';

class PetProfileProvider extends ChangeNotifier{
  final List<PetProfileModel> _petProfiles = [
    // Temporary default profile until one is selected or added
    PetProfileModel(
      id: 0,  // temporary id for placeholder profile
      petName: 'Select a Pet',
      petBreed: 'Unknown',
      birthMonth: null,
      birthYear: null,
      vetEmail: null,
    ),
  ];

  // Track the currently selected pet profile
  PetProfileModel? _selectedPetProfile;

  List<PetProfileModel> get petProfiles => _petProfiles;

  PetProfileModel? get selectedPetProfile => _selectedPetProfile;

  void addPetProfile(PetProfileModel petProfile) {
    _petProfiles.add(petProfile);
    notifyListeners();
  }

  void selectPetProfile(PetProfileModel petProfile) {
    _selectedPetProfile = petProfile;
    notifyListeners();
  }

  void updateVetEmail(String? newVetEmail) {
    if (_selectedPetProfile != null) {
      _selectedPetProfile!.vetEmail = newVetEmail;
      notifyListeners();
    }
  }

}

  
