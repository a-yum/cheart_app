import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB();
    } catch (e) { // toDo: Update after imp
      // Log error while initializing database
      print("Error initializing database: $e");
      rethrow;
    }
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'cheart.db');
      print("Database file path: $path");
      
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) { // toDo: Update after imp
      print("Error opening database: $e");
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE pet_profiles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          pet_name TEXT,
          pet_breed TEXT,
          birth_month INTEGER,
          birth_year INTEGER,
          vet_email TEXT,
          pet_image_url TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE respiratory_sessions (
          session_id INTEGER PRIMARY KEY AUTOINCREMENT,
          pet_id INTEGER,
          time_stamp TEXT,
          respiratory_rate REAL,
          pet_state TEXT,
          notes TEXT,
          is_breathing_rate_normal INTEGER,
          FOREIGN KEY (pet_id) REFERENCES pet_profiles(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('''
        CREATE INDEX idx_pet_id ON respiratory_sessions(pet_id);
      ''');
      
    } catch (e) { // toDo: Update after imp
      print("Error creating tables: $e");
      rethrow;
    }
  }
}