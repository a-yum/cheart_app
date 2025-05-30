import 'package:cheart/models/respiratory_stats_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/exceptions/data_access_exception.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/models/graph_models.dart';
import 'package:cheart/providers/respiratory_history_provider.dart';

import 'package:cheart/screens/graph_screen_constants.dart';

class FakeRespiratorySessionDAO extends RespiratorySessionDAO {
  // If true, hasSessions() will throw instead of returning normally.
  bool throwOnHasSessions = false;

  // If non-null, getSessionStatsBetween will return this summary.
  RespiratoryStatsSummary? statsBetweenOverride;

  FakeRespiratorySessionDAO(Database db) : super(db);

  @override
  Future<bool> hasSessions(int petId) async {
    if (throwOnHasSessions) {
      throw DataAccessException('Forced failure', Exception());
    }
    return true;
  }

  @override
  Future<List<RespiratorySessionModel>> getSessionsForToday(int petId) async {
    final now = DateTime.now();
    return [
      RespiratorySessionModel(
        sessionId: null,
        petId: petId,
        timeStamp: now,
        respiratoryRate: 10.0,
        petState: PetState.resting,
        isBreathingRateNormal: true,
      ),
      RespiratorySessionModel(
        sessionId: null,
        petId: petId,
        timeStamp: now.add(const Duration(hours: 1)),
        respiratoryRate: 20.0,
        petState: PetState.resting,
        isBreathingRateNormal: true,
      ),
    ];
  }

  @override
  Future<List<RespiratorySessionModel>> getSessionsBetween({
    required int petId,
    required DateTime start,
    required DateTime end,
  }) =>
      getSessionsForToday(petId);

  @override
  Future<RespiratoryStatsSummary> getSessionStatsBetween({
    required int petId,
    required DateTime start,
    required DateTime end,
  }) async {
    if (statsBetweenOverride != null) return statsBetweenOverride!;
    return RespiratoryStatsSummary(avgBpm: 15.0, minBpm: 10, maxBpm: 20);
  }

  @override
  Future<List<DailyStat>> getDailyAveragesForCurrentWeek(
      int petId, int highThreshold) async {
    final now = DateTime.now();
    return [
      DailyStat(
        date: now.subtract(const Duration(days: 1)),
        avgBpm: 12.0,
        count: 2,
        minBpm: 8,
        maxBpm: 16,
        highPct: 50.0,
      ),
      DailyStat(
        date: now,
        avgBpm: 18.0,
        count: 3,
        minBpm: 15,
        maxBpm: 21,
        highPct: 33.3,
      ),
    ];
  }

  @override
  Future<List<DailyStat>> getDailyAveragesForCurrentMonth(
      int petId, int highThreshold) async {
    final now = DateTime.now();
    return List.generate(3, (i) {
      final date = DateTime(now.year, now.month, i + 1);
      return DailyStat(
        date: date,
        avgBpm: (i + 1) * 5.0,
        count: i + 1,
        minBpm: (i + 1) * 3,
        maxBpm: (i + 1) * 7,
        highPct: 0.0,
      );
    });
  }
}

void main() {
  group('RespiratoryHistoryProvider', () {
    late RespiratoryHistoryProvider provider;
    late FakeRespiratorySessionDAO fakeDao;

    // ==================== Setup ====================
    setUp(() async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      final db = await databaseFactory.openDatabase(inMemoryDatabasePath);
      fakeDao = FakeRespiratorySessionDAO(db);
      provider = RespiratoryHistoryProvider(
        petId: 1,
        dao: fakeDao,
        highThreshold: 100,
      );
    });

    // ==================== updatePet loads both chart and stats ====================
    test('updatePet loads chart data and stats', () async {
      await provider.updatePet(1);

      expect(provider.hasSessions, isTrue);
      expect(provider.hourlyPoints.map((p) => p.bpm), [10.0, 20.0]);
      expect(provider.overallAvgBpm, 15.0);
      expect(provider.minBpm, 10);
      expect(provider.maxBpm, 20);
      expect(provider.mostRecentBpm, 20.0);
    });

    // ==================== setFilter only reloads chart ====================
    test('setFilter(TimeFilter.weekly) only reloads weekly chart data', () async {
      await provider.updatePet(1);
      provider.hourlyPoints.clear();
      provider.dailyStats.clear();

      await provider.setFilter(TimeFilter.weekly);

      expect(provider.dailyStats.length, 2);
      expect(provider.hourlyPoints, isEmpty);
    });

    // ==================== onSessionAdded uses overridden stats ====================
    test('onSessionAdded picks up statsBetweenOverride', () async {
      await provider.updatePet(1);
      fakeDao.statsBetweenOverride =
          RespiratoryStatsSummary(avgBpm: 42.0, minBpm: 30, maxBpm: 54);

      await provider.onSessionAdded();

      expect(provider.overallAvgBpm, 42.0);
      expect(provider.minBpm, 30);
      expect(provider.maxBpm, 54);
    });

    // ==================== Error propagation ====================
    test('updatePet propagates DataAccessException from hasSessions', () {
      fakeDao.throwOnHasSessions = true;

      expect(
        () => provider.updatePet(1),
        throwsA(isA<DataAccessException>()),
      );
    });
  });
}
