import 'package:flutter_test/flutter_test.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/dao/pet_profile_dao.dart';

class FakePetProfileDao implements PetProfileDAO {
  FakePetProfileDao(this.profiles);
  final List<PetProfileModel> profiles;

  @override
  Future<List<PetProfileModel>> getAllPetProfiles() async => profiles;

  @override
  Future<int> insertPetProfile(PetProfileModel pet) async {
    // Simulate database auto‐assigning an ID
    return pet.id ?? 0;
  }

  @override
  Future<int> updatePetProfile(PetProfileModel pet) async {
    // Simulate a successful update returning number of rows affected
    return 1;
  }

  @override
  Future<int> deletePetProfile(int id) async {
    // Simulate a successful deletion returning number of rows affected
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PetProfileProvider basic operations', () {
    late PetProfileProvider provider;

    // ==================== Setup ====================
    setUp(() {
      provider = PetProfileProvider();
      // Auto‐select constructor should have picked the default test pet
      provider.setDao(FakePetProfileDao(provider.petProfiles));
    });

    // ==================== Initialization ====================
    test('should start with one default profile', () {
      expect(provider.petProfiles.length, 1);
      expect(provider.petProfiles.first.petName, 'test');
    });

    test('auto-selects the first profile on creation', () {
      expect(provider.selectedPetProfile, provider.petProfiles.first);
    });

    // ==================== Add Pet ====================
    test('addPetProfile should add a new profile', () {
      final newPet = PetProfileModel(
        id: 1,
        petName: 'Buddy',
        petBreed: 'Golden Retriever',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      provider.addPetProfile(newPet);
      expect(provider.petProfiles.length, 2);
      expect(provider.petNames, contains('Buddy'));
    });

    // ==================== Select Pet ====================
    test('selectPetProfile should update selectedPetProfile', () async {
      final newPet = PetProfileModel(
        id: 2,
        petName: 'Luna',
        petBreed: 'Husky',
        birthMonth: 7,
        birthYear: 2020,
        vetEmail: null,
        petProfileImagePath: '',
      );
      provider.addPetProfile(newPet);
      await provider.selectPetProfile(newPet);
      expect(provider.selectedPetProfile, equals(newPet));
    });

    // ==================== Update Vet Email ====================
    test('updateVetEmail should update email on selected pet', () async {
      final newPet = PetProfileModel(
        id: 3,
        petName: 'Max',
        petBreed: 'Labrador',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      provider.addPetProfile(newPet);
      await provider.selectPetProfile(newPet);

      await provider.updateVetEmail('vet@example.com');
      expect(provider.selectedPetProfile!.vetEmail, 'vet@example.com');
    });

    // ==================== Remove Pet ====================
    test('removePetProfile should remove profile and clear selection if removed', () {
      final newPet = PetProfileModel(
        id: 4,
        petName: 'Bella',
        petBreed: 'Poodle',
        birthMonth: null,
        birthYear: null,
        vetEmail: 'vet@example.com',
        petProfileImagePath: '',
      );
      provider.addPetProfile(newPet);
      provider.selectPetProfile(newPet);
      expect(provider.petProfiles.contains(newPet), isTrue);

      provider.removePetProfile(newPet);
      expect(provider.petProfiles.contains(newPet), isFalse);
      expect(provider.selectedPetProfile, isNull);
    });

    // ==================== Update Pet ====================
    test('updatePetProfile should update the given profile by id', () async {
      final newPet = PetProfileModel(
        id: 5,
        petName: 'Charlie',
        petBreed: 'Beagle',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      provider.addPetProfile(newPet);

      final updatedPet = newPet.copyWith(
        petBreed: 'Beagle Mix',
        vetEmail: 'updated@example.com',
      );
      await provider.updatePetProfile(updatedPet);

      final petFromProvider =
          provider.petProfiles.firstWhere((p) => p.id == 5);
      expect(petFromProvider.petBreed, 'Beagle Mix');
      expect(petFromProvider.vetEmail, 'updated@example.com');
    });

    // ==================== Delete Pet ====================
    test('deletePetProfile should remove and clear selection when last removed', () async {
      // Initial in-memory has one test pet
      final id = provider.petProfiles.first.id!;
      await provider.deletePetProfile(id);
      expect(provider.petProfiles, isEmpty);
      expect(provider.selectedPetProfile, isNull);
    });
  });

  group('PetProfileProvider.loadPetProfiles', () {
    test('empty list from DAO → petProfiles empty & selected null', () async {
      final provider = PetProfileProvider();
      provider.setDao(FakePetProfileDao([]));
      await provider.loadPetProfiles();
      expect(provider.petProfiles, isEmpty);
      expect(provider.selectedPetProfile, isNull);
    });

    test('single profile from DAO → auto-select it', () async {
      final only = PetProfileModel(
        id: 10,
        petName: 'Solo',
        petBreed: 'Cat',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      final provider = PetProfileProvider();
      provider.setDao(FakePetProfileDao([only]));
      await provider.loadPetProfiles();
      expect(provider.petProfiles, [only]);
      expect(provider.selectedPetProfile, only);
    });

    test('multiple profiles & no prior selection → selects first', () async {
      final p1 = PetProfileModel(
        id: 20,
        petName: 'A',
        petBreed: 'X',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      final p2 = PetProfileModel(
        id: 21,
        petName: 'B',
        petBreed: 'Y',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      final provider = PetProfileProvider();
      provider.setDao(FakePetProfileDao([p1, p2]));
      await provider.loadPetProfiles();
      expect(provider.selectedPetProfile, p1);
    });

    test('multiple profiles & prior selection still present → preserves it', () async {
      final p1 = PetProfileModel(
        id: 30,
        petName: 'X',
        petBreed: 'X',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      final p2 = PetProfileModel(
        id: 31,
        petName: 'Y',
        petBreed: 'Y',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      final provider = PetProfileProvider();
      await provider.selectPetProfile(p2); // pre-select p2
      provider.setDao(FakePetProfileDao([p1, p2]));
      await provider.loadPetProfiles();
      expect(provider.selectedPetProfile, p2);
    });

    test('multiple profiles & prior selection gone → falls back to first', () async {
      final p1 = PetProfileModel(
        id: 40,
        petName: 'A',
        petBreed: 'A',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      final p2 = PetProfileModel(
        id: 41,
        petName: 'B',
        petBreed: 'B',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petProfileImagePath: '',
      );
      final provider = PetProfileProvider();
      await provider.selectPetProfile(p2); // pre-select p2 (not returned)
      provider.setDao(FakePetProfileDao([p1]));
      await provider.loadPetProfiles();
      expect(provider.selectedPetProfile, p1);
    });
  });
}
