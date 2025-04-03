import 'package:flutter_test/flutter_test.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/providers/pet_profile_provider.dart';

void main() {
  group('PetProfileProvider', () {
    late PetProfileProvider provider;

    // Set up a fresh provider before each test:
    setUp(() {
      provider = PetProfileProvider();
    });

    test('should start with one default profile', () {
      expect(provider.petProfiles.length, 1);
      expect(provider.petProfiles.first.petName, 'test');
    });

    test('addPetProfile should add a new profile', () {
      final newPet = PetProfileModel(
        id: 1,
        petName: 'Buddy',
        petBreed: 'Golden Retriever',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petImageUrl: '',
      );
      provider.addPetProfile(newPet);
      expect(provider.petProfiles.length, 2);
      expect(provider.petNames, contains('Buddy'));
    });

    test('selectPetProfile should update selectedPetProfile', () {
      final newPet = PetProfileModel(
        id: 2,
        petName: 'Luna',
        petBreed: 'Husky',
        birthMonth: 7,
        birthYear: 2020,
        vetEmail: null,
        petImageUrl: '',
      );
      provider.addPetProfile(newPet);
      provider.selectPetProfile(newPet);
      expect(provider.selectedPetProfile, equals(newPet));
    });

    test('updateVetEmail should update email on selected pet', () {
      // First, select an existing profile:
      final newPet = PetProfileModel(
        id: 3,
        petName: 'Max',
        petBreed: 'Labrador',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petImageUrl: '',
      );
      provider.addPetProfile(newPet);
      provider.selectPetProfile(newPet);

      provider.updateVetEmail('vet@example.com');
      expect(provider.selectedPetProfile!.vetEmail, 'vet@example.com');
    });

    test('removePetProfile should remove profile and clear selection if removed', () {
      final newPet = PetProfileModel(
        id: 4,
        petName: 'Bella',
        petBreed: 'Poodle',
        birthMonth: null,
        birthYear: null,
        vetEmail: 'vet@example.com',
        petImageUrl: '',
      );
      provider.addPetProfile(newPet);
      provider.selectPetProfile(newPet);
      expect(provider.petProfiles.contains(newPet), isTrue);
      provider.removePetProfile(newPet);
      expect(provider.petProfiles.contains(newPet), isFalse);
      expect(provider.selectedPetProfile, isNull);
    });

    test('updatePetProfile should update the given profile by id', () {
      // Add a new pet
      final newPet = PetProfileModel(
        id: 5,
        petName: 'Charlie',
        petBreed: 'Beagle',
        birthMonth: null,
        birthYear: null,
        vetEmail: null,
        petImageUrl: '',
      );
      provider.addPetProfile(newPet);

      // Create an updated profile (could be a copy with changes)
      final updatedPet = PetProfileModel(
        id: 5,
        petName: 'Charlie',
        petBreed: 'Beagle Mix',
        birthMonth: null,
        birthYear: null,
        vetEmail: 'updated@example.com',
        petImageUrl: '',
      );

      provider.updatePetProfile(5, updatedPet);

      final petFromProvider = provider.petProfiles.firstWhere((p) => p.id == 5);
      expect(petFromProvider.petBreed, 'Beagle Mix');
      expect(petFromProvider.vetEmail, 'updated@example.com');
    });
  });
}