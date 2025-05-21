import 'package:flutter_test/flutter_test.dart';
import 'package:cheart/models/pet_profile_model.dart';

void main() {
  group('PetProfileModel', () {
    
    // ==================== Test: Age Calculation ====================
    test('correctly calculates age', () {
      final now = DateTime.now();

      final pet = PetProfileModel(
        petName: 'Test',
        petBreed: 'Breed',
        birthMonth: now.month - 1,
        birthYear: now.year - 5,
      );

      // Should return 5 years if birth month is before current month
      expect(pet.petAgeInYears, 5);
    });

    // ==================== Test: toMap and fromMap Consistency ====================
    test('toMap and fromMap round-trip', () {
      final pet = PetProfileModel(
        id: 1,
        petName: 'Benji',
        birthMonth: 3,
        birthYear: 2020,
        petBreed: 'Beagle',
        vetEmail: 'vet@email.com',
        petProfileImagePath: 'assets/dog.png',
      );

      final map = pet.toMap();
      final petFromMap = PetProfileModel.fromMap(map);

      // Ensure all fields are preserved correctly through serialization
      expect(petFromMap.petName, equals(pet.petName));
      expect(petFromMap.petBreed, equals(pet.petBreed));
      expect(petFromMap.birthMonth, equals(pet.birthMonth));
      expect(petFromMap.birthYear, equals(pet.birthYear));
      expect(petFromMap.vetEmail, equals(pet.vetEmail));
      expect(petFromMap.petProfileImagePath, equals(pet.petProfileImagePath));
    });
  });
}
