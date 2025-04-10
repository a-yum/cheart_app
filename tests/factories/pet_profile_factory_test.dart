import 'package:flutter_test/flutter_test.dart';

import 'package:cheart/factories/pet_profile_factory.dart';

void main() {
  group('PetProfileFactory.create', () {
    test('should create a PetProfileModel with required fields', () {
      final pet = PetProfileFactory.create(
        petName: 'Buddy',
        petBreed: 'Golden Retriever',
      );

      expect(pet.petName, 'Buddy');
      expect(pet.petBreed, 'Golden Retriever');
      expect(pet.birthMonth, isNull);
      expect(pet.birthYear, isNull);
      expect(pet.vetEmail, isNull);
      // Default pet image url is an empty string
      expect(pet.petImageUrl, '');
    });

    test('should set birthMonth and birthYear when provided', () {
      final pet = PetProfileFactory.create(
        petName: 'Luna',
        petBreed: 'Husky',
        birthMonth: 7,
        birthYear: 2020,
      );

      expect(pet.birthMonth, 7);
      expect(pet.birthYear, 2020);
    });

    test('should return null for vetEmail if empty passed', () {
      final pet = PetProfileFactory.create(
        petName: 'Max',
        petBreed: 'Labrador',
        vetEmail: '',
      );
      expect(pet.vetEmail, isNull);
    });

    test('should keep vetEmail if non-empty string is passed', () {
      final pet = PetProfileFactory.create(
        petName: 'Bella',
        petBreed: 'Poodle',
        vetEmail: 'vet@example.com',
      );
      expect(pet.vetEmail, 'vet@example.com');
    });
  });
}

// void main() {
//   group('PetProfileFactory.create', () {
//     test('should create a PetProfileModel with required fields', () {
//       final pet = PetProfileFactory.create(
//         petName: 'Buddy',
//         petBreed: 'Golden Retriever',
//       );

//       expect(pet.petName, 'Buddy');
//       expect(pet.petBreed, 'Golden Retriever');
//       expect(pet.birthMonth, isNull);
//       expect(pet.birthYear, isNull);
//       expect(pet.vetEmail, isNull);
//       // Default pet image url is an empty string
//       expect(pet.petImageUrl, '');
//     });

//     test('should set birthMonth and birthYear when provided', () {
//       final pet = PetProfileFactory.create(
//         petName: 'Luna',
//         petBreed: 'Husky',
//         birthMonth: 7,
//         birthYear: 2020,
//       );

//       expect(pet.birthMonth, 7);
//       expect(pet.birthYear, 2020);
//     });

//     test('should return null for vetEmail if empty passed', () {
//       final pet = PetProfileFactory.create(
//         petName: 'Max',
//         petBreed: 'Labrador',
//         vetEmail: '',
//       );
//       expect(pet.vetEmail, isNull);
//     });

//     test('should keep vetEmail if non-empty string is passed', () {
//       final pet = PetProfileFactory.create(
//         petName: 'Bella',
//         petBreed: 'Poodle',
//         vetEmail: 'vet@example.com',
//       );
//       expect(pet.vetEmail, 'vet@example.com');
//     });
//   });
// }
