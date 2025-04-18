import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:flutter/material.dart';
import 'package:cheart/models/pet_profile_model.dart';

class PetProfileProvider extends ChangeNotifier{
  // toDo: for testing purposes only. remove later
  final List<PetProfileModel> _petProfiles = [
    PetProfileModel(
      id: 0,
      petName: 'test',
      petBreed: 'Unknown',
      birthMonth: null,
      birthYear: null,
      vetEmail: null,
    ),
  ];

  late PetProfileDAO _dao;

  PetProfileModel? _selectedPetProfile;

  List<PetProfileModel> get petProfiles => _petProfiles;
  PetProfileModel? get selectedPetProfile => _selectedPetProfile;
  List<String> get petNames => _petProfiles.map((profile) => profile.petName).toList();

  void setDao(PetProfileDAO dao) {
    _dao = dao;
  }

  // Persists via DAO, updates in-memory list, selects and notifies
  Future<PetProfileModel> savePetProfile(PetProfileModel pet) async {
    final newId = await _dao.savePetProfile(pet);
    final saved = pet.copyWith(id: newId);
    _petProfiles.add(saved);
    _selectedPetProfile = saved;
    notifyListeners();
    return saved;
  }

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

  
