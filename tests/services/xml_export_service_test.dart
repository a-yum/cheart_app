// test/xml_export_service_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/services/xml_export_service.dart';
import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/models/weekly_stats.dart';

void main() {
  // Ensure Flutter bindings + FFI database + path_provider
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late RespiratorySessionDAO dao;
  late XmlExportService service;

  setUp(() async {
    // In-memory DB + DAO + service
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    dao = RespiratorySessionDAO(db);
    service = XmlExportService(dao);

    // Create the table schema matching your real app
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

  test('exportToXml: summary and weekly elements match DAO data', () async {
    // 1) Prepare a pet and 2 sessions across two days
    final pet = PetProfileModel(
      id: 1,
      petName: 'Fluffy',
      petBreed: 'Maine Coon',
      birthMonth: 5,
      birthYear: 2020,
      vetEmail: 'vet@clinic.com',
      petProfileImagePath: '',
    );

    // Insert one resting, one sleeping
    final day1 = DateTime(2025, 5, 20, 10, 0, 0);
    final day2 = DateTime(2025, 5, 21, 10, 0, 0);

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

    // 2) Export
    final file = await service.exportToXml(pet);
    final xmlString = await file.readAsString();

    // 3) Parse
    final doc = XmlDocument.parse(xmlString);

    // -- Summary element
    final summary = doc.findAllElements('Summary').single;
    expect(summary.getAttribute('averageBpm'), '18.0');         // (12+24)/2
    expect(summary.getAttribute('minBpm'), '12');
    expect(summary.getAttribute('maxBpm'), '24');
    expect(summary.getAttribute('averageAtRestBpm'), '12.0');    // only one resting
    expect(summary.getAttribute('averageSleepingBpm'), '24.0'); // only one sleeping

    // -- Weekly elements (one per day, descending order)
    final weeks = doc.findAllElements('Week').toList();
    expect(weeks.length, 2);

    // First Week = day2
    final first = weeks[0];
    expect(first.getAttribute('start'), '2025-05-21');
    expect(first.getAttribute('averageBpm'), '24.0');
    expect(first.getAttribute('status'), 'sleeping');

    // Second Week = day1
    final second = weeks[1];
    expect(second.getAttribute('start'), '2025-05-20');
    expect(second.getAttribute('averageBpm'), '12.0');
    expect(second.getAttribute('status'), 'at_rest');
  });
}
