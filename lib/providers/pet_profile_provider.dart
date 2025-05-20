import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:cheart/models/pet_profile_model.dart';

class PetProfileProvider extends ChangeNotifier {
  static const _kLastSelectedKey = 'lastSelectedPetId';

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
  List<String> get petNames =>
      _petProfiles.map((profile) => profile.petName).toList();

  void setDao(PetProfileDAO dao) {
    _dao = dao;
  }

  // Load pet profiles from the database, then restore last‐selected from prefs
  Future<void> loadPetProfiles() async {
    final profiles = await _dao.getAllPetProfiles();
    _petProfiles
      ..clear()
      ..addAll(profiles);

    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getInt(_kLastSelectedKey);

    if (_petProfiles.isEmpty) {
      // 1) No pets → leave selected null
      _selectedPetProfile = null;
    } else if (_petProfiles.length == 1) {
      // 2) Exactly one pet → auto-select it
      _selectedPetProfile = _petProfiles.first;
    } else {
      // 3) Multiple pets → try to restore last selected if still valid
      if (lastId != null &&
          _petProfiles.any((p) => p.id == lastId)) {
        _selectedPetProfile = _petProfiles.firstWhere((p) => p.id == lastId);
      } else if (_selectedPetProfile == null ||
          !_petProfiles.any((p) => p.id == _selectedPetProfile!.id)) {
        _selectedPetProfile = _petProfiles.first;
      }
    }

    notifyListeners();
  }

  // Persists via DAO, updates in-memory list, selects and notifies
  Future<PetProfileModel> savePetProfile(PetProfileModel pet) async {
    final newId = await _dao.insertPetProfile(pet);
    final saved = pet.copyWith(id: newId);
    _petProfiles.add(saved);
    _selectedPetProfile = saved;
    notifyListeners();

    // Remember this pet for next app launch
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastSelectedKey, newId);

    return saved;
  }

  // Adds a pet to memory only (used in dev)
  void addPetProfile(PetProfileModel petProfile) {
    _petProfiles.add(petProfile);
    //selectedPetProfile = petProfile; // Automatically select the new profile
    notifyListeners();
  }

  // Update a pet's vet email and notify
  void updateVetEmail(String? newVetEmail) {
    if (_selectedPetProfile != null) {
      _selectedPetProfile!.vetEmail = newVetEmail;
      notifyListeners();
    }
  }

  // Replace an existing pet profile by ID
  void updatePetProfile(int id, PetProfileModel updatedProfile) {
    int index = _petProfiles.indexWhere((profile) => profile.id == id);
    if (index != -1) {
      _petProfiles[index] = updatedProfile;
      notifyListeners();
    }
  }

  // Selects a pet and remembers that choice in prefs
  Future<void> selectPetProfile(PetProfileModel petProfile) async {
    _selectedPetProfile = petProfile;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastSelectedKey, petProfile.id!);
  }

  // Removes pet from list and clears selection if necessary
  void removePetProfile(PetProfileModel petProfile) {
    _petProfiles.remove(petProfile);
    if (_selectedPetProfile == petProfile) {
      _selectedPetProfile = null;
    }
    notifyListeners();
  }
}
