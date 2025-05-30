import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/services/csv_export_service.dart';
import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/utils/respiratory_constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late RespiratorySessionDAO dao;
  late CsvExportService service;

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    dao = RespiratorySessionDAO(db);
    service = CsvExportService(dao);

    await db.execute('''
      CREATE TABLE respiratory_sessions(
        session_id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet_id INTEGER NOT NULL,
        time_stamp TEXT   NOT NULL,
        respiratory_rate REAL   NOT NULL,
        pet_state TEXT    NOT NULL,
        is_breathing_rate_normal INTEGER NOT NULL
      )
    ''');
  });

  tearDown(() async {
    await db.close();
  });

  test('exportToCsv produces correct summary and weekly rows', () async {
    // Prepare a pet and two sessions on consecutive days
    final pet = PetProfileModel(
      id: 1,
      petName: 'Fluffy',
      petBreed: 'Maine Coon',
      birthMonth: 5,
      birthYear: 2020,
      vetEmail: 'vet@clinic.com',
      petProfileImagePath: '',
    );

    final day1 = DateTime(2025, 5, 20, 10, 0, 0);
    final day2 = DateTime(2025, 5, 21, 11, 30, 0);

    // Insert one normal/resting and one abnormal/sleeping
    await dao.insertSession(RespiratorySessionModel(
      sessionId: null,
      petId: pet.id!,
      timeStamp: day1,
      respiratoryRate: 12.0,
      petState: PetState.resting,
      notes: null,
      isBreathingRateNormal: true,
    ));
    await dao.insertSession(RespiratorySessionModel(
      sessionId: null,
      petId: pet.id!,
      timeStamp: day2,
      respiratoryRate: 24.0,
      petState: PetState.sleeping,
      notes: null,
      isBreathingRateNormal: false,
    ));

    // Export
    final file = await service.exportToCsv(pet);
    final content = await file.readAsString();

    // Parse CSV
    final rows = const CsvToListConverter().convert(content);

    // Row indices:
    // 0: ['CHeart Export for', 'Fluffy']
    // 1: ['Exported at', '<timestamp>']
    // 2: [] blank
    // 3: ['Summary']
    // 4: summary headers
    // 5: summary values
    // 6: [] blank
    // 7: ['WeeklyAverages']
    // 8: weekly headers
    // 9: first week (day2)
    // 10: second week (day1)

    // Basic metadata
    expect(rows[0], ['CHeart Export for', 'Fluffy']);
    expect(rows[1].first, 'Exported at');
    expect(rows[1].length, 2);

    // Summary header row
    expect(rows[3], ['Summary']);

    // Summary columns
    expect(rows[4], [
      'AverageBpm',
      'MinBpm',
      'MaxBpm',
      'AverageAtRestBpm',
      'AverageSleepingBpm',
      'AbnormalSessionCount',
    ]);

    // Summary values
    final summaryRow = rows[5];
    expect(summaryRow[0], '18.0');              // (12 + 24) / 2
    expect(summaryRow[1], 12);                  // min
    expect(summaryRow[2], 24);                  // max
    expect(summaryRow[3], '12.0');              // at-rest avg
    expect(summaryRow[4], '24.0');              // sleeping avg
    expect(summaryRow[5], 1);                   // one abnormal

    // Weekly header marker
    expect(rows[7], ['WeeklyAverages']);

    // Weekly headers
    expect(rows[8], [
      'WeekStart',
      'WeekEnd',
      'AverageBpm',
      'MinBpm',
      'MaxBpm',
      'SessionCount',
      'Status',
      'Trend'
    ]);

    // First week = day2 (sleeping)
    final week1 = rows[9];
    expect(week1[0], day2.toIso8601String().split('T').first);
    expect(week1[2], '24.0');                   // avg
    expect(week1[6], 'sleeping');

    // Second week = day1 (resting)
    final week2 = rows[10];
    expect(week2[0], day1.toIso8601String().split('T').first);
    expect(week2[2], '12.0');
    expect(week2[6], 'at_rest');
  });
}
