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

  late final PetProfileDAO _dao;
  PetProfileModel? _selectedPetProfile;

  // Automatically select the first pet if any exist on provider creation.
  PetProfileProvider() {
    if (_petProfiles.isNotEmpty) {
      _selectedPetProfile = _petProfiles.first;
    }
  }

  // All loaded pet profiles.
  List<PetProfileModel> get petProfiles => List.unmodifiable(_petProfiles);

  // Currently selected pet profile (may be null).
  PetProfileModel? get selectedPetProfile => _selectedPetProfile;

  // List of pet names for UI dropdowns.
  List<String> get petNames => _petProfiles.map((p) => p.petName).toList();

  /// Injects the DAO for database operations.
  void setDao(PetProfileDAO dao) {
    _dao = dao;
  }

  // Loads profiles from the database and restores last selection.
  Future<void> loadPetProfiles() async {
    final profiles = await _dao.getAllPetProfiles();
    _petProfiles
      ..clear()
      ..addAll(profiles);

    final prefs = await SharedPreferences.getInstance();
    final lastId = prefs.getInt(_kLastSelectedKey);

    if (_petProfiles.isEmpty) {
      _selectedPetProfile = null; // 1) No pets → none selected
    } else if (_petProfiles.length == 1) {
      _selectedPetProfile = _petProfiles.first; // 2) Single pet → auto-select
    } else {
      // 3) Multiple pets → restore or default
      if (lastId != null && _petProfiles.any((p) => p.id == lastId)) {
        _selectedPetProfile = _petProfiles.firstWhere((p) => p.id == lastId);
      } else if (_selectedPetProfile == null ||
          !_petProfiles.any((p) => p.id == _selectedPetProfile!.id)) {
        _selectedPetProfile = _petProfiles.first;
      }
    }

    notifyListeners();
  }

  // Persists a new pet, selects it, and remembers choice.
  Future<PetProfileModel> savePetProfile(PetProfileModel pet) async {
    final newId = await _dao.insertPetProfile(pet);
    final saved = pet.copyWith(id: newId);
    _petProfiles.add(saved);
    _selectedPetProfile = saved;
    notifyListeners();

    await _persistLastSelected(saved.id!);
    return saved;
  }

  // Updates the vet email on the selected pet.
  Future<void> updateVetEmail(String newVetEmail) async {
    final pet = _selectedPetProfile!;
    pet.vetEmail = newVetEmail; // 1) In-memory
    await _dao.updatePetProfile(pet); // 2) Persist
    notifyListeners(); // 3) Refresh UI
  }

  // Replaces an existing profile by its ID.
  Future<void> updatePetProfile(PetProfileModel updated) async {
    await _dao.updatePetProfile(updated);

    final idx = _petProfiles.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _petProfiles[idx] = updated;
      _selectedPetProfile = updated;
      notifyListeners();
    }
  }

  // Selects a pet and remembers that choice.
  Future<void> selectPetProfile(PetProfileModel petProfile) async {
    _selectedPetProfile = petProfile;
    notifyListeners();
    await _persistLastSelected(petProfile.id!);
  }

  // Deletes from db + clears local memory
  Future<void> deletePetProfile(int id) async {
    await _dao.deletePetProfile(id);

    _petProfiles.removeWhere((p) => p.id == id);

    // If the deleted pet was selected, clear it
    if (_selectedPetProfile?.id == id) {
      _selectedPetProfile = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLastSelectedKey);
    }

    notifyListeners();
  }

  // Removes a profile and clears selection if it was selected. local only
  void removePetProfile(PetProfileModel petProfile) {
    _petProfiles.remove(petProfile);
    if (_selectedPetProfile == petProfile) {
      _selectedPetProfile = null;
    }
    notifyListeners();
  }

  // for dev/testing: adds a profile in memory only
  void addPetProfile(PetProfileModel petProfile) {
    _petProfiles.add(petProfile);
    //selectedPetProfile = petProfile;
    notifyListeners();
  }

  // Persists last selected pet ID to shared preferences.
  Future<void> _persistLastSelected(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastSelectedKey, id);
  }
}