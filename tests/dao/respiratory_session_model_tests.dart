import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/src/mixin/constant.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/utils/respiratory_constants.dart';

void main() {
  late Database db;
  late RespiratorySessionDAO dao;

  setUpAll(() {
    // Initialize ffi implementation
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Open an in-memory database for each test
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    dao = RespiratorySessionDAO(db);

    // Create the table according to our schema
    await db.execute('''
      CREATE TABLE respiratory_sessions(
        session_id INTEGER PRIMARY KEY AUTOINCREMENT,
        time_stamp TEXT NOT NULL,
        respiratory_rate REAL NOT NULL,
        pet_state TEXT NOT NULL,
        is_breathing_rate_normal INTEGER NOT NULL
      )
    ''');
  });

  tearDown(() async {
    await db.close();
  });

  // ==================== Create & Read Tests ====================
  test('insertSession and getAllSessions return inserted session', () async {
    final now = DateTime.now();
    final session = RespiratorySessionModel(
      sessionId: null,
      timeStamp: now,
      respiratoryRate: 22.5,
      petState: PetState.resting,
      notes: null,
      isBreathingRateNormal: true,
    );

    final id = await dao.insertSession(session);
    expect(id, isNonZero);

    final sessions = await dao.getAllSessions();
    expect(sessions.length, 1);
    final fetched = sessions.first;
    expect(fetched.sessionId, equals(id));
    expect(fetched.timeStamp.toIso8601String(), equals(now.toIso8601String()));
    expect(fetched.respiratoryRate, equals(22.5));
    expect(fetched.petState, equals(PetState.resting));
    expect(fetched.isBreathingRateNormal, isTrue);
  });

  test('getSessionById returns correct session or null', () async {
    // Insert two sessions
    final s1 = RespiratorySessionModel(
      sessionId: null,
      timeStamp: DateTime.now(),
      respiratoryRate: 18.0,
      petState: PetState.sleeping,
      notes: null,
      isBreathingRateNormal: true,
    );
    final s2 = RespiratorySessionModel(
      sessionId: null,
      timeStamp: DateTime.now().add(const Duration(minutes: 1)),
      respiratoryRate: 45.0,
      petState: PetState.resting,
      notes: null,
      isBreathingRateNormal: false,
    );
    final id1 = await dao.insertSession(s1);
    final id2 = await dao.insertSession(s2);

    final fetched1 = await dao.getSessionById(id1);
    expect(fetched1, isNotNull);
    expect(fetched1!.sessionId, id1);

    final fetched2 = await dao.getSessionById(id2);
    expect(fetched2, isNotNull);
    expect(fetched2!.sessionId, id2);

    final nonexistent = await dao.getSessionById(999);
    expect(nonexistent, isNull);
  });

  // ==================== Update Test ====================
  test('updateSession modifies existing record', () async {
    final initial = RespiratorySessionModel(
      sessionId: null,
      timeStamp: DateTime.now(),
      respiratoryRate: 20.0,
      petState: PetState.resting,
      notes: null,
      isBreathingRateNormal: true,
    );
    final id = await dao.insertSession(initial);

    final updated = RespiratorySessionModel(
      sessionId: id,
      timeStamp: initial.timeStamp,
      respiratoryRate: 30.0,
      petState: PetState.sleeping,
      notes: null,
      isBreathingRateNormal: true,
    );
    final rows = await dao.updateSession(updated);
    expect(rows, 1);

    final fetched = await dao.getSessionById(id);
    expect(fetched!.respiratoryRate, equals(30.0));
    expect(fetched.petState, equals(PetState.sleeping));
  });

  // ==================== Delete Test ====================
  test('deleteSession removes the record', () async {
    final toDelete = RespiratorySessionModel(
      sessionId: null,
      timeStamp: DateTime.now(),
      respiratoryRate: 25.0,
      petState: PetState.resting,
      notes: null,
      isBreathingRateNormal: true,
    );
    final id = await dao.insertSession(toDelete);

    final countBefore = (await dao.getAllSessions()).length;
    expect(countBefore, 1);

    final deleted = await dao.deleteSession(id);
    expect(deleted, 1);

    final sessionsAfter = await dao.getAllSessions();
    expect(sessionsAfter, isEmpty);
  });
}
