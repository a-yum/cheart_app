import 'package:flutter/material.dart';
import 'package:cheart/models/pet_profile_model.dart';

class PetProfileProvider extends ChangeNotifier{
  final List<PetProfileModel> _petProfiles = [
    // Temporary default profile until one is selected or added
    PetProfileModel(
      id: 0,  // temporary id for placeholder profile
      petName: 'test',
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

  List<String> get petNames => _petProfiles.map((profile) => profile.petName).toList();

  void addPetProfile(PetProfileModel petProfile) {
    _petProfiles.add(petProfile);
    //selectedPetProfile = petProfile; // Automatically select the new profile
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

  void removePetProfile(PetProfileModel petProfile) {
    _petProfiles.remove(petProfile);
    if (_selectedPetProfile == petProfile) {
      _selectedPetProfile = null;
    }
    notifyListeners();
  }

  void updatePetProfile(int id, PetProfileModel updatedProfile) {
    int index = _petProfiles.indexWhere((profile) => profile.id == id);
    if (index != -1) {
      _petProfiles[index] = updatedProfile;
      notifyListeners();
    }
  }
  
}

  
