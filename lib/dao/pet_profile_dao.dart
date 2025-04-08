import 'package:sqflite/sqflite.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/database/database_helper.dart';

class PetProfileDAO {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertPetProfile(PetProfileModel pet) async {
    try {
      final Database db = await _dbHelper.database;
      return await db.insert(
        'pet_profiles',
        pet.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print("Error inserting pet profile: $e");
      rethrow;
    }
  }

  Future<List<PetProfileModel>> getPetProfiles() async {
    try {
      final Database db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('pet_profiles');
      return maps.map((map) => PetProfileModel.fromMap(map)).toList();
    } catch (e) { // toDo: Update after imp
      print("Error getting pet profiles: $e");
      rethrow;
    }
  }

  Future<int> updatePetProfile(PetProfileModel pet) async {
    try {
      final Database db = await _dbHelper.database;
      return await db.update(
        'pet_profiles',
        pet.toMap(),
        where: 'id = ?',
        whereArgs: [pet.id],
      );
    } catch (e) { // toDo: Update after imp
      print("Error updating pet profile: $e");
      rethrow;
    }
  }

  Future<int> deletePetProfile(int id) async {
    try {
      final Database db = await _dbHelper.database;
      return await db.delete(
        'pet_profiles',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) { // toDo: Update after imp
      print("Error deleting pet profile: $e");
      rethrow;
    }
  }

}