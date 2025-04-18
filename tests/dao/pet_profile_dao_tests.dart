import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/exceptions/data_access_exception.dart';

void main() {
  // Initialize FFI & point to the ffi factory
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late PetProfileDAO dao;

  setUp(() async {
    // Open a fresh in-memory database for each test
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
              pet_image_url TEXT
            );
          ''');
        },
      ),
    );

    // Inject it into your DAO
    dao = PetProfileDAO(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ==================== Test: Save and Retrieve ====================
  test('savePetProfile inserts and getPetProfiles returns it', () async {
    final pet = PetProfileModel(
      petName: 'Buddy',
      petBreed: 'Golden Retriever',
      birthMonth: 5,
      birthYear: 2018,
      vetEmail: 'vet@example.com',
    );

    final id = await dao.savePetProfile(pet);
    expect(id, isNonZero);

    final pets = await dao.getPetProfiles();
    expect(pets, hasLength(1));
    expect(pets.first.petName, 'Buddy');
    expect(pets.first.petBreed, 'Golden Retriever');
  });

  // ==================== Test: Exception on Missing Table ====================
  test('getPetProfiles throws DataAccessException when table missing', () async {
    // Drop the table to simulate a broken schema
    await db.execute('DROP TABLE pet_profiles;');
    expect(
      () => dao.getPetProfiles(),
      throwsA(isA<DataAccessException>()),
    );
  });

  // ==================== Test: Update Profile ====================
  test('updatePetProfile updates an existing record', () async {
    final pet = PetProfileModel(
      petName: 'Max',
      petBreed: 'Labrador',
      birthMonth: 6,
      birthYear: 2019,
    );
    final id = await dao.savePetProfile(pet);

    final updated = PetProfileModel(
      id: id,
      petName: 'Maximus',
      petBreed: 'Labrador',
      birthMonth: 6,
      birthYear: 2019,
      vetEmail: null,
      petImageUrl: null,
    );

    final rowsAffected = await dao.updatePetProfile(updated);
    expect(rowsAffected, 1);

    final pets = await dao.getPetProfiles();
    expect(pets.first.petName, 'Maximus');
  });

  // ==================== Test: Delete Profile ====================
  test('deletePetProfile removes the record', () async {
    final pet = PetProfileModel(
      petName: 'DeleteMe',
      petBreed: 'TestBreed',
    );
    final id = await dao.savePetProfile(pet);

    final rowsDeleted = await dao.deletePetProfile(id.toString());
    expect(rowsDeleted, 1);

    final pets = await dao.getPetProfiles();
    expect(pets, isEmpty);
  });
}