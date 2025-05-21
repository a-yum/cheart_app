import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;
  
  DatabaseHelper._internal();

  static Database? _database;

  // Lazy load the database. If the database doesn't exist, it will be initialized.
  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB();
    } catch (e) { 
      // toDo: Update after implementation
      // Log error while initializing the database.
      print("Error initializing database: $e");
      rethrow;
    }
    return _database!;
  }

  Future<Database> _initDB() async {
    try {
      // Get the application documents directory.
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      
      // Create the path for the database file.
      String path = join(documentsDirectory.path, 'cheart.db');
      print("Database file path: $path");
      
      // Open the database, and create it if it doesn't exist.
      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB, // Callback to create tables when database is created.
      );
    } catch (e) { 
      // toDo: Update after implementation
      // Log error while opening the database.
      print("Error opening database: $e");
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE pet_profiles (
          id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
          pet_name TEXT,
          pet_breed TEXT,
          birth_month INTEGER,
          birth_year INTEGER,
          vet_email TEXT,
          pet_profile_image_path TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE respiratory_sessions (
          session_id INTEGER PRIMARY KEY AUTOINCREMENT,
          pet_id INTEGER NOT NULL,
          time_stamp TEXT DEFAULT CURRENT_TIMESTAMP,
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
      
    } catch (e) { 
      // toDo: Update after implementation
      // Log error while creating tables.
      print("Error creating tables: $e");
      rethrow;
    }
  }
}
