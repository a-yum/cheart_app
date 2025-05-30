import 'package:flutter_test/flutter_test.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/dao/pet_profile_dao.dart';

// Fake DAO that returns a preset list of profiles and
// fakes out updatePetProfile so updateVetEmail can await it.
class FakePetProfileDao implements PetProfileDAO {
  FakePetProfileDao(this.profiles);
  final List<PetProfileModel> profiles;

  @override
  Future<List<PetProfileModel>> getAllPetProfiles() async => profiles;

  @override
  Future<int> updatePetProfile(PetProfileModel pet) async => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PetProfileProvider basic operations', () {
    late PetProfileProvider provider;

    // ==================== Setup ====================
    setUp(() {
      provider = PetProfileProvider();
      // Give the provider a DAO so updateVetEmail can call updatePetProfile
      provider.setDao(FakePetProfileDao(provider.petProfiles));
    });

    // ==================== Initialization ====================
    test('should start with one default profile', () {
      expect(provider.petProfiles.length, 1);
      expect(provider.petProfiles.first.petName, 'test');
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
    test('selectPetProfile should update selectedPetProfile', () {
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
      provider.selectPetProfile(newPet);
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
      provider.selectPetProfile(newPet);

      // await the async update
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
    test('updatePetProfile should update the given profile by id', () {
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

      final updatedPet = PetProfileModel(
        id: 5,
        petName: 'Charlie',
        petBreed: 'Beagle Mix',
        birthMonth: null,
        birthYear: null,
        vetEmail: 'updated@example.com',
        petProfileImagePath: '',
      );
      provider.updatePetProfile(5, updatedPet);

      final petFromProvider =
          provider.petProfiles.firstWhere((p) => p.id == 5);
      expect(petFromProvider.petBreed, 'Beagle Mix');
      expect(petFromProvider.vetEmail, 'updated@example.com');
    });
  });

  group('PetProfileProvider.loadPetProfiles', () {
    // ==================== Empty DAO ====================
    test('empty list from DAO → petProfiles empty & selected null', () async {
      final provider = PetProfileProvider();
      provider.setDao(FakePetProfileDao([]));
      await provider.loadPetProfiles();
      expect(provider.petProfiles, isEmpty);
      expect(provider.selectedPetProfile, isNull);
    });

    // ==================== Single Profile ====================
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

    // ==================== Multiple, No Prior Selection ====================
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

    // ==================== Multiple, Prior Selection Present ====================
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
      provider.selectPetProfile(p2);              // pre‐select p2
      provider.setDao(FakePetProfileDao([p1, p2]));
      await provider.loadPetProfiles();
      expect(provider.selectedPetProfile, p2);
    });

    // ==================== Multiple, Prior Selection Gone ====================
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
      provider.selectPetProfile(p2);              // pre‐select p2 (not returned)
      provider.setDao(FakePetProfileDao([p1]));
      await provider.loadPetProfiles();
      expect(provider.selectedPetProfile, p1);
    });
  });
}
