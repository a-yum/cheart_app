import 'package:sqflite/sqflite.dart';

import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/models/graph_models.dart';
import 'package:cheart/exceptions/data_access_exception.dart';

class RespiratoryStatsSummary {
  final double avgBpm;
  final int minBpm;
  final int maxBpm;

  RespiratoryStatsSummary({
    required this.avgBpm,
    required this.minBpm,
    required this.maxBpm,
  });
}

class RespiratorySessionDAO {
  final Database db;
  static const String _table = 'respiratory_sessions';

  RespiratorySessionDAO(this.db);

  // Insert or replace a session record in the database.
  // If a session with the same ID already exists, it will be replaced.
  Future<int> insertSession(RespiratorySessionModel session) {
    return _wrap<int>(
      'Failed to insert session for pet ${session.petId}',
      () => db.insert(
        _table,
        session.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      ),
    );
  }

  // Fetch a single session by its unique session ID.
  Future<RespiratorySessionModel?> getSessionById(int id) {
    return _wrap(
      'Failed to load session id $id',
      () async {
        final maps = await db.query(
          _table,
          where: 'session_id = ?',
          whereArgs: [id],
          limit: 1,
        );
        if (maps.isEmpty) return null; // Return null if no session found
        return RespiratorySessionModel.fromMap(maps.first);
      },
    );
  }

  // Update an existing session in the database.
  // The session will be identified by its sessionId for the update.
  Future<int> updateSession(RespiratorySessionModel session) {
    return _wrap(
      'Failed to update session id ${session.sessionId}',
      () => db.update(
        _table,
        session.toMap(),
        where: 'session_id = ?',
        whereArgs: [session.sessionId],
      ),
    );
  }

  // Delete a session based on its session ID.
  Future<int> deleteSession(int id) {
    return _wrap(
      'Failed to delete session id $id',
      () => db.delete(
        _table,
        where: 'session_id = ?',
        whereArgs: [id],
      ),
    );
  }

  // Retrieve all respiratory sessions, ordered by timestamp (newest first).
  Future<List<RespiratorySessionModel>> getAllSessions() {
    return _wrap(
      'Failed to load all sessions',
      () async {
        final maps = await db.query(_table, orderBy: 'time_stamp DESC');
        return maps.map(RespiratorySessionModel.fromMap).toList();
      },
    );
  }

  // Retrieve the most recent respiratory session for a given pet.
  Future<RespiratorySessionModel?> getLatestSession(int petId) {
    return _wrap(
      'Failed to load most recent session for pet $petId',
      () async {
        final maps = await db.query(
          _table,
          where: 'pet_id = ?',
          whereArgs: [petId],
          orderBy: 'time_stamp DESC', // Timestamp stored in ISO 8601 format
          limit: 1,
        );
        if (maps.isEmpty) return null;
        return RespiratorySessionModel.fromMap(maps.first);
      },
    );
  }

  // A generic helper method that wraps database operations and handles exceptions.
  // It throws a `DataAccessException` with a description in case of errors.
  Future<T> _wrap<T>(String description, Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw DataAccessException(description, e); // Handle any errors in a standard way
    }
  }

  // Check if a pet has any respiratory sessions recorded in the database.
  Future<bool> hasSessions(int petId) {
    return _wrap<bool>(
      'Failed to check session existence for pet $petId',
      () async {
        final rows = await db.rawQuery(
          'SELECT EXISTS(SELECT 1 FROM $_table WHERE pet_id = ? LIMIT 1) AS exists_flag',
          [petId],
        );
        if (rows.isEmpty) return false;
        final existsValue = rows.first['exists_flag'];
        if (existsValue is int) return existsValue == 1;
        if (existsValue is bool) return existsValue;
        return false; // Return false if the value is neither int nor bool
      },
    );
  }

  // Fetch respiratory sessions for a given pet between the start and end dates.
  Future<List<RespiratorySessionModel>> getSessionsBetween({
    required int petId,
    required DateTime start,
    required DateTime end,
  }) {
    return _wrap<List<RespiratorySessionModel>>(
      'Failed to load sessions between ${start.toIso8601String()} and ${end.toIso8601String()} for pet $petId',
      () async {
        final startIso = start.toIso8601String();
        final endIso = end.toIso8601String();
        final maps = await db.query(
          _table,
          where: 'pet_id = ? AND time_stamp >= ? AND time_stamp < ?',
          whereArgs: [petId, startIso, endIso],
          orderBy: 'time_stamp ASC',
        );
        return maps.map(RespiratorySessionModel.fromMap).toList();
      },
    );
  }

  // Fetch all respiratory sessions recorded for a pet on the current day.
  Future<List<RespiratorySessionModel>> getSessionsForToday(int petId) {
    return _wrap<List<RespiratorySessionModel>>(
      'Failed to load today\'s sessions for pet $petId',
      () {
        final now = DateTime.now();
        final dayStart = DateTime(now.year, now.month, now.day);
        final tomorrow = dayStart.add(const Duration(days: 1));
        return getSessionsBetween(
          petId: petId,
          start: dayStart,
          end: tomorrow,
        );
      },
    );
  }

  // Fetch daily average respiratory stats for the past 7 days.
  Future<List<DailyStat>> getDailyAveragesForCurrentWeek(int petId, int highThreshold) {
    return _wrap<List<DailyStat>>(
      'Failed to load weekly stats for pet $petId',
      () async {
        final now = DateTime.now();
        final weekStart = now.subtract(const Duration(days: 6)); // Last 7 days, including today
        final weekEnd = DateTime(now.year, now.month, now.day).add(const Duration(days: 1)); // End of current day

        final rows = await db.rawQuery('''
          SELECT
            substr(time_stamp, 1, 10) AS dayStr,
            COUNT(*) AS count,
            AVG(respiratory_rate) AS avgBpm,
            MIN(respiratory_rate) AS minBpm,
            MAX(respiratory_rate) AS maxBpm
          FROM $_table
          WHERE pet_id = ?
            AND time_stamp >= ?
            AND time_stamp < ?
          GROUP BY dayStr
          ORDER BY dayStr
        ''', [
          petId,
          weekStart.toIso8601String(),
          weekEnd.toIso8601String(),
        ]);

        final mapByDay = {for (var r in rows) r['dayStr'] as String: r};

        final stats = <DailyStat>[];
        for (var i = 0; i < 7; i++) {
          final date = DateTime(weekStart.year, weekStart.month, weekStart.day + i);
          final key = date.toIso8601String().substring(0, 10);
          stats.add(mapByDay.containsKey(key)
              ? DailyStat(
                  date: date,
                  avgBpm: (mapByDay[key]!['avgBpm'] as num).toDouble(),
                  count: (mapByDay[key]!['count'] as num).toInt(),
                  minBpm: (mapByDay[key]!['minBpm'] as num).toInt(),
                  maxBpm: (mapByDay[key]!['maxBpm'] as num).toInt(),
                  highPct: 0.0,
                )
              : DailyStat(
                  date: date,
                  avgBpm: 0.0,
                  count: 0,
                  minBpm: 0,
                  maxBpm: 0,
                  highPct: 0.0,
                ));
        }
        return stats;
      },
    );
  }

  // Fetch daily average respiratory stats for the current month.
  Future<List<DailyStat>> getDailyAveragesForCurrentMonth(int petId, int highThreshold) {
    return _wrap<List<DailyStat>>(
      'Failed to load monthly stats for pet $petId',
      () async {
        final now = DateTime.now();
        final monthStart = DateTime(now.year, now.month, 1);
        final today = DateTime(now.year, now.month, now.day);
        final monthEnd = today.add(const Duration(days: 1)); // End of current day

        final rows = await db.rawQuery('''
          SELECT
            substr(time_stamp, 1, 10) AS dayStr,
            COUNT(*) AS count,
            AVG(respiratory_rate) AS avgBpm,
            MIN(respiratory_rate) AS minBpm,
            MAX(respiratory_rate) AS maxBpm
          FROM $_table
          WHERE pet_id = ?
            AND time_stamp >= ?
            AND time_stamp < ?
          GROUP BY dayStr
          ORDER BY dayStr
        ''', [
          petId,
          monthStart.toIso8601String(),
          monthEnd.toIso8601String(),
        ]);

        final mapByDay = {for (var r in rows) r['dayStr'] as String: r};

        final stats = <DailyStat>[];
        for (var i = 0; i < today.day; i++) {
          final date = DateTime(now.year, now.month, 1 + i);
          final key = date.toIso8601String().substring(0, 10);
          stats.add(mapByDay.containsKey(key)
              ? DailyStat(
                  date: date,
                  avgBpm: (mapByDay[key]!['avgBpm'] as num).toDouble(),
                  count: (mapByDay[key]!['count'] as num).toInt(),
                  minBpm: (mapByDay[key]!['minBpm'] as num).toInt(),
                  maxBpm: (mapByDay[key]!['maxBpm'] as num).toInt(),
                  highPct: 0.0,
                )
              : DailyStat(
                  date: date,
                  avgBpm: 0.0,
                  count: 0,
                  minBpm: 0,
                  maxBpm: 0,
                  highPct: 0.0,
                ));
        }
        return stats;
      },
    );
  }

  // Fetch summary statistics (avg/min/max) for respiratory sessions between a start and end time.
  Future<RespiratoryStatsSummary> getSessionStatsBetween({
    required int petId,
    required DateTime start,
    required DateTime end,
  }) {
    return _wrap<RespiratoryStatsSummary>(
      'Failed to load respiratory stats summary for pet $petId',
      () async {
        final startIso = start.toIso8601String();
        final endIso = end.toIso8601String();

        final rows = await db.rawQuery('''
          SELECT
            AVG(respiratory_rate) AS avgBpm,
            MIN(respiratory_rate) AS minBpm,
            MAX(respiratory_rate) AS maxBpm
          FROM $_table
          WHERE pet_id = ?
            AND time_stamp >= ?
            AND time_stamp < ?
        ''', [
          petId,
          startIso,
          endIso,
        ]);

        final row = rows.first;
        return RespiratoryStatsSummary(
          avgBpm: (row['avgBpm'] as num?)?.toDouble() ?? 0.0,
          minBpm: (row['minBpm'] as num?)?.toInt() ?? 0,
          maxBpm: (row['maxBpm'] as num?)?.toInt() ?? 0,
        );
      },
    );
  }
}
