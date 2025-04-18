import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:cheart/database/database_helper.dart';
import 'package:cheart/models/pet_profile_model.dart';

void main() {
  late PetProfileDAO dao;

  setUpAll(() {
    // Initialize sqflite for FFI (for desktop and unit test environments)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Create fresh DAO and clear database table before each test
    dao = PetProfileDAO();
    final db = await DatabaseHelper().database;
    await db.delete('pet_profiles');
  });

  // ==================== Test: Insert and Retrieve ====================
  test('should insert and retrieve a pet profile', () async {
    final pet = PetProfileModel(
      petName: 'Buddy',
      petBreed: 'Golden Retriever',
      birthMonth: 5,
      birthYear: 2018,
      vetEmail: 'vet@example.com',
    );

    final id = await dao.insertPetProfile(pet);
    expect(id, isNonZero); // Ensure a valid row ID was returned

    final pets = await dao.getPetProfiles();
    expect(pets.length, 1);
    expect(pets.first.petName, 'Buddy');
    expect(pets.first.petBreed, 'Golden Retriever');
  });

  // ==================== Test: Update Profile ====================
  test('should update a pet profile', () async {
    final pet = PetProfileModel(
      petName: 'Buddy',
      petBreed: 'Golden Retriever',
      birthMonth: 5,
      birthYear: 2018,
    );

    final id = await dao.insertPetProfile(pet);

    final updatedPet = PetProfileModel(
      id: id,
      petName: 'Buddy Updated',
      petBreed: 'Golden Retriever',
      birthMonth: 5,
      birthYear: 2018,
    );

    final rows = await dao.updatePetProfile(updatedPet);
    expect(rows, 1); // Should affect one row

    final pets = await dao.getPetProfiles();
    expect(pets.first.petName, 'Buddy Updated');
  });

  // ==================== Test: Delete Profile ====================
  test('should delete a pet profile', () async {
    final pet = PetProfileModel(
      petName: 'DeleteMe',
      petBreed: 'Test',
    );

    final id = await dao.insertPetProfile(pet);

    final rowsDeleted = await dao.deletePetProfile(id);
    expect(rowsDeleted, 1); // One row should be deleted

    final pets = await dao.getPetProfiles();
    expect(pets, isEmpty); // Confirm table is now empty
  });
}
