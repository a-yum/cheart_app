import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/exceptions/data_access_exception.dart';


void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late PetProfileDAO dao;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE pet_profiles(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              pet_name TEXT NOT NULL,
              birth_month INTEGER,
              birth_year INTEGER,
              pet_breed TEXT NOT NULL,
              vet_email TEXT,
              pet_profile_image_path TEXT
            );
          ''');
        },
      ),
    );
    dao = PetProfileDAO(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ==================== Test: Insert and Fetch ====================
  test('insertPetProfile adds a profile, getAllPetProfiles retrieves it', () async {
    final pet = PetProfileModel(
      petName: 'Buddy',
      petBreed: 'Golden Retriever',
      birthMonth: 5,
      birthYear: 2018,
      vetEmail: 'vet@example.com',
      petProfileImagePath: 'https://example.com/image.png',
    );

    final id = await dao.insertPetProfile(pet);
    expect(id, isNonZero);

    final pets = await dao.getAllPetProfiles();
    expect(pets.length, 1);
    final fetched = pets.first;
    expect(fetched.petName, 'Buddy');
    expect(fetched.petBreed, 'Golden Retriever');
    expect(fetched.vetEmail, 'vet@example.com');
    expect(fetched.petProfileImagePath, 'https://example.com/image.png');
  });

  // ==================== Test: Exception on Missing Table ====================
  test('getAllPetProfiles throws DataAccessException if table is missing', () async {
    await db.execute('DROP TABLE pet_profiles;');
    expect(
      () => dao.getAllPetProfiles(),
      throwsA(isA<DataAccessException>()),
    );
  });

  // ==================== Test: Update ====================
  test('updatePetProfile updates an existing record', () async {
    final pet = PetProfileModel(
      petName: 'Max',
      petBreed: 'Labrador',
      birthMonth: 6,
      birthYear: 2019,
    );

    final id = await dao.insertPetProfile(pet);

    final updated = PetProfileModel(
      id: id,
      petName: 'Maximus',
      petBreed: 'Labrador',
      birthMonth: 6,
      birthYear: 2019,
      vetEmail: 'max@email.com',
      petProfileImagePath: 'https://example.com/max.png',
    );

    final rowsAffected = await dao.updatePetProfile(updated);
    expect(rowsAffected, 1);

    final pets = await dao.getAllPetProfiles();
    final updatedPet = pets.first;
    expect(updatedPet.petName, 'Maximus');
    expect(updatedPet.vetEmail, 'max@email.com');
    expect(updatedPet.petProfileImagePath, 'https://example.com/max.png');
  });

  // ==================== Test: Delete ====================
  test('deletePetProfile removes the record', () async {
    final pet = PetProfileModel(
      petName: 'DeleteMe',
      petBreed: 'TestBreed',
    );

    final id = await dao.insertPetProfile(pet);

    final rowsDeleted = await dao.deletePetProfile(id);
    expect(rowsDeleted, 1);

    final pets = await dao.getAllPetProfiles();
    expect(pets, isEmpty);
  });
}
