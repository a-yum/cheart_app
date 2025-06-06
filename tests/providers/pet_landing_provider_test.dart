// File: test/providers/pet_landing_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:cheart/providers/pet_landing_provider.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Fake DAO implementing only the methods PetLandingProvider calls:
/// - getLatestSession
/// - getSessionsBetween
/// - getDistinctSessionDates
class FakeRespiratorySessionDAO extends RespiratorySessionDAO {
  final List<RespiratorySessionModel> _sessions;

  FakeRespiratorySessionDAO(Database db, this._sessions) : super(db);

  @override
  Future<RespiratorySessionModel?> getLatestSession(int petId) async {
    final filtered = _sessions.where((s) => s.petId == petId).toList();
    if (filtered.isEmpty) return null;
    filtered.sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
    return filtered.first;
  }

  @override
  Future<List<RespiratorySessionModel>> getSessionsBetween({
    required int petId,
    required DateTime start,
    required DateTime end,
  }) async {
    return _sessions.where((s) {
      return s.petId == petId &&
          !s.timeStamp.isBefore(start) &&
          s.timeStamp.isBefore(end);
    }).toList();
  }

  @override
  Future<List<DateTime>> getDistinctSessionDates(int petId) async {
    final dates = <DateTime>{};
    for (var s in _sessions) {
      if (s.petId != petId) continue;
      final dt = DateTime(s.timeStamp.year, s.timeStamp.month, s.timeStamp.day);
      dates.add(dt);
    }
    final sorted = dates.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }
}

void main() {
  // Initialize FFI for in-memory database
  sqfliteFfiInit();

  late Database inMemoryDb;

  setUpAll(() async {
    inMemoryDb = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  });

  tearDownAll(() async {
    await inMemoryDb.close();
  });

  // ─── loadLatestSession via loadAll() ───────────────────────────────────────────
  group('PetLandingProvider: loadLatestSession()', () {
    test('returns null when no sessions exist', () async {
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, []);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 42);

      await provider.loadAll();
      expect(provider.latestSession, isNull);
    });

    test('returns session with highest timestamp', () async {
      final now = DateTime.now();
      final sessions = [
        RespiratorySessionModel(
          sessionId: 1,
          petId: 5,
          timeStamp: now.subtract(const Duration(days: 1)),
          respiratoryRate: 10.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        RespiratorySessionModel(
          sessionId: 2,
          petId: 5,
          timeStamp: now,
          respiratoryRate: 20.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 5);

      await provider.loadAll();
      expect(provider.latestSession, isNotNull);
      expect(provider.latestSession!.sessionId, equals(2));
      expect(provider.latestSession!.respiratoryRate, equals(20.0));
    });
  });

  // ─── _loadTodayAverage via loadAll() ─────────────────────────────────────────────
  group('PetLandingProvider: _loadTodayAverage()', () {
    test('both todayAvg and yesterdayAvg are null if no sessions in relevant windows', () async {
      final now = DateTime.now();
      final sessions = [
        RespiratorySessionModel(
          sessionId: 1,
          petId: 7,
          timeStamp: now.subtract(const Duration(days: 2)),
          respiratoryRate: 12.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 7);

      await provider.loadAll();
      expect(provider.todayAvg, isNull);
      expect(provider.yesterdayAvg, isNull);
    });

    test('computes correct todayAvg when only today sessions exist', () async {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);

      final sessions = [
        RespiratorySessionModel(
          sessionId: 1,
          petId: 8,
          timeStamp: todayStart.add(const Duration(hours: 1)),
          respiratoryRate: 15.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        RespiratorySessionModel(
          sessionId: 2,
          petId: 8,
          timeStamp: todayStart.add(const Duration(hours: 2)),
          respiratoryRate: 21.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 8);

      await provider.loadAll();
      // Average respiratoryRate = (15 + 21)/2 = 18
      expect(provider.todayAvg, closeTo(18.0, 0.01));
      expect(provider.yesterdayAvg, isNull);
    });

    test('computes correct yesterdayAvg when only yesterday sessions exist', () async {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      final sessions = [
        RespiratorySessionModel(
          sessionId: 3,
          petId: 9,
          timeStamp: yesterdayStart.add(const Duration(hours: 1)),
          respiratoryRate: 8.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        RespiratorySessionModel(
          sessionId: 4,
          petId: 9,
          timeStamp: yesterdayStart.add(const Duration(hours: 2)),
          respiratoryRate: 12.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 9);

      await provider.loadAll();
      expect(provider.todayAvg, isNull);
      expect(provider.yesterdayAvg, closeTo(10.0, 0.01));
    });

    test('computes both todayAvg and yesterdayAvg correctly when both exist', () async {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      final sessions = [
        // Today: respiratoryRate 15, 21 → avg = 18
        RespiratorySessionModel(
          sessionId: 5,
          petId: 10,
          timeStamp: todayStart.add(const Duration(hours: 1)),
          respiratoryRate: 15.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        RespiratorySessionModel(
          sessionId: 6,
          petId: 10,
          timeStamp: todayStart.add(const Duration(hours: 2)),
          respiratoryRate: 21.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        // Yesterday: respiratoryRate 10, 20 → avg = 15
        RespiratorySessionModel(
          sessionId: 7,
          petId: 10,
          timeStamp: yesterdayStart.add(const Duration(hours: 1)),
          respiratoryRate: 10.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        RespiratorySessionModel(
          sessionId: 8,
          petId: 10,
          timeStamp: yesterdayStart.add(const Duration(hours: 2)),
          respiratoryRate: 20.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 10);

      await provider.loadAll();
      expect(provider.todayAvg, closeTo(18.0, 0.01));
      expect(provider.yesterdayAvg, closeTo(15.0, 0.01));
    });
  });

  // ─── loadCurrentStreak via loadAll() ─────────────────────────────────────────────
  group('PetLandingProvider: _loadCurrentStreak()', () {
    test('returns 0 when no distinct dates', () async {
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, []);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 11);

      await provider.loadAll();
      expect(provider.currentStreak, equals(0));
    });

    test('counts 1 when only today exists', () async {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);

      final sessions = [
        RespiratorySessionModel(
          sessionId: 9,
          petId: 12,
          timeStamp: todayDate.add(const Duration(hours: 1)),
          respiratoryRate: 7.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 12);

      await provider.loadAll();
      expect(provider.currentStreak, equals(1));
    });

    test('counts 2 when today and yesterday exist', () async {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      final sessions = [
        RespiratorySessionModel(
          sessionId: 10,
          petId: 13,
          timeStamp: todayDate.add(const Duration(hours: 1)),
          respiratoryRate: 5.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        RespiratorySessionModel(
          sessionId: 11,
          petId: 13,
          timeStamp: yesterdayDate.add(const Duration(hours: 2)),
          respiratoryRate: 6.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 13);

      await provider.loadAll();
      expect(provider.currentStreak, equals(2));
    });

    test('resets to 1 when yesterday is missing but today exists', () async {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final twoDaysAgo = todayDate.subtract(const Duration(days: 2));

      final sessions = [
        RespiratorySessionModel(
          sessionId: 12,
          petId: 14,
          timeStamp: todayDate.add(const Duration(hours: 1)),
          respiratoryRate: 9.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        RespiratorySessionModel(
          sessionId: 13,
          petId: 14,
          timeStamp: twoDaysAgo.add(const Duration(hours: 3)),
          respiratoryRate: 8.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 14);

      await provider.loadAll();
      expect(provider.currentStreak, equals(1));
    });
  });

  // ─── loadAll() integration test ─────────────────────────────────────────────────
  group('PetLandingProvider: loadAll()', () {
    test('chains all loads and sets state correctly', () async {
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);
      final yesterdayDate = todayDate.subtract(const Duration(days: 1));

      final sessions = [
        // Latest session
        RespiratorySessionModel(
          sessionId: 14,
          petId: 15,
          timeStamp: todayDate.add(const Duration(hours: 4)),
          respiratoryRate: 22.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        // Yesterday session for avg
        RespiratorySessionModel(
          sessionId: 15,
          petId: 15,
          timeStamp: yesterdayDate.add(const Duration(hours: 2)),
          respiratoryRate: 10.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
        // Today session for avg
        RespiratorySessionModel(
          sessionId: 16,
          petId: 15,
          timeStamp: todayDate.add(const Duration(hours: 2)),
          respiratoryRate: 20.0,
          petState: PetState.resting,
          notes: null,
          isBreathingRateNormal: true,
        ),
      ];
      final fakeDao = FakeRespiratorySessionDAO(inMemoryDb, sessions);
      final provider = PetLandingProvider(sessionDao: fakeDao, petId: 15);

      await provider.loadAll();

      // Verify latestSession
      expect(provider.latestSession!.respiratoryRate, equals(22.0));

      // todayAvg: (10 + 20)/2 = 15
      expect(provider.todayAvg, closeTo(15.0, 0.01));

      // yesterdayAvg: 10
      expect(provider.yesterdayAvg, closeTo(10.0, 0.01));

      // currentStreak: sessions on today + yesterday → 2
      expect(provider.currentStreak, equals(2));
    });
  });
}
