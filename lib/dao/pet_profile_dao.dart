import 'package:flutter/foundation.dart';

import 'package:sqflite/sqflite.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/exceptions/data_access_exception.dart';

class PetProfileDAO {
  final Database _db;
  PetProfileDAO(this._db);

  static const String _table = 'pet_profiles';

  Future<int> savePetProfile(PetProfileModel pet) async {
    try {
      return await _db.insert(
        _table,
        pet.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      debugPrint('🛑 DatabaseException in insertPetProfile: $e');
      throw DataAccessException('Failed to insert pet profile', e);
    } catch (e) {
      debugPrint('🛑 Unexpected in insertPetProfile: $e');
      throw DataAccessException('Unexpected error inserting pet profile', e);
    }
  }

  Future<List<PetProfileModel>> getPetProfiles() async {
    try {
      final maps = await _db.query(_table);
      return maps.map((m) => PetProfileModel.fromMap(m)).toList();
    } on DatabaseException catch (e) {
      debugPrint('🛑 DatabaseException in getPetProfiles: $e');
      throw DataAccessException('Failed to load pet profiles', e);
    } catch (e) {
      debugPrint('🛑 Unexpected in getPetProfiles: $e');
      throw DataAccessException('Unexpected error loading pet profiles', e);
    }
  }

  Future<int> updatePetProfile(PetProfileModel pet) async {
    try {
      return await _db.update(
        _table,
        pet.toMap(),
        where: 'id = ?',
        whereArgs: [pet.id],
      );
    } on DatabaseException catch (e) {
      debugPrint('🛑 DatabaseException in updatePetProfile: $e');
      throw DataAccessException('Failed to update pet profile', e);
    } catch (e) {
      debugPrint('🛑 Unexpected in updatePetProfile: $e');
      throw DataAccessException('Unexpected error updating pet profile', e);
    }
  }

  Future<int> deletePetProfile(String id) async {
    try {
      return await _db.delete(
        _table,
        where: 'id = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      debugPrint('🛑 DatabaseException in deletePetProfile: $e');
      throw DataAccessException('Failed to delete pet profile', e);
    } catch (e) {
      debugPrint('🛑 Unexpected in deletePetProfile: $e');
      throw DataAccessException('Unexpected error deleting pet profile', e);
    }
  }
}
