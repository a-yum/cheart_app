import 'package:sqflite/sqflite.dart';

import 'package:cheart/exceptions/data_access_exception.dart';
import 'package:cheart/models/graph_models.dart';
import 'package:cheart/models/overall_respiratory_stats_summary.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/models/respiratory_stats_summary.dart';
import 'package:cheart/models/weekly_stats.dart';

class RespiratorySessionDAO {
  final Database db;
  static const String _table = 'respiratory_sessions';

  RespiratorySessionDAO(this.db);

  // Insert or replace a session
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

  // Get session by ID
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
        if (maps.isEmpty) return null;
        return RespiratorySessionModel.fromMap(maps.first);
      },
    );
  }

  // Get all sessions
  Future<List<RespiratorySessionModel>> getAllSessions() {
    return _wrap(
      'Failed to load all sessions',
      () async {
        final maps = await db.query(_table, orderBy: 'time_stamp DESC');
        return maps.map(RespiratorySessionModel.fromMap).toList();
      },
    );
  }

  // Get most recent session
  Future<RespiratorySessionModel?> getLatestSession(int petId) {
    return _wrap(
      'Failed to load most recent session for pet $petId',
      () async {
        final maps = await db.query(
          _table,
          where: 'pet_id = ?',
          whereArgs: [petId],
          orderBy: 'time_stamp DESC',
          limit: 1,
        );
        if (maps.isEmpty) return null;
        return RespiratorySessionModel.fromMap(maps.first);
      },
    );
  }

  // Get sessions between two dates
  Future<List<RespiratorySessionModel>> getSessionsBetween({
    required int petId,
    required DateTime start,
    required DateTime end,
  }) {
    return _wrap(
      'Failed to load sessions between ${start.toIso8601String()} and ${end.toIso8601String()} for pet $petId',
      () async {
        final maps = await db.query(
          _table,
          where: 'pet_id = ? AND time_stamp >= ? AND time_stamp < ?',
          whereArgs: [petId, start.toIso8601String(), end.toIso8601String()],
          orderBy: 'time_stamp ASC',
        );
        return maps.map(RespiratorySessionModel.fromMap).toList();
      },
    );
  }

  // Get today's sessions
  Future<List<RespiratorySessionModel>> getSessionsForToday(int petId) {
    return _wrap(
      'Failed to load today\'s sessions for pet $petId',
      () {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final end = start.add(const Duration(days: 1));
        return getSessionsBetween(petId: petId, start: start, end: end);
      },
    );
  }

  // Check if pet has any sessions
  Future<bool> hasSessions(int petId) {
    return _wrap<bool>(
      'Failed to check session existence for pet $petId',
      () async {
        final rows = await db.rawQuery(
          'SELECT EXISTS(SELECT 1 FROM $_table WHERE pet_id = ? LIMIT 1) AS exists_flag',
          [petId],
        );
        final existsValue = rows.first['exists_flag'];
        if (existsValue is int) return existsValue == 1;
        if (existsValue is bool) return existsValue;
        return false;
      },
    );
  }

  // Update session
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

  // Delete session
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

  // Count how many sessions for this pet exceeded the given BPM threshold
  Future<int> countAbnormalSessions(int petId) {
    return _wrap<int>(
      'Failed to count abnormal sessions for pet $petId',
      () async {
        final rows = await db.rawQuery(
          'SELECT COUNT(*) AS cnt '
          'FROM $_table '
          'WHERE pet_id = ? AND is_breathing_rate_normal = 0',
          [petId],
        );
        final cnt = rows.first['cnt'];
        if (cnt is int) return cnt;
        if (cnt is num) return cnt.toInt();
        return 0;
      },
    );
  }

  // Get summary stats between two dates
  Future<RespiratoryStatsSummary> getSessionStatsBetween({
    required int petId,
    required DateTime start,
    required DateTime end,
  }) {
    return _wrap(
      'Failed to load respiratory stats summary for pet $petId',
      () async {
        final rows = await db.rawQuery('''
          SELECT AVG(respiratory_rate) AS avgBpm,
                 MIN(respiratory_rate) AS minBpm,
                 MAX(respiratory_rate) AS maxBpm
          FROM $_table
          WHERE pet_id = ? AND time_stamp >= ? AND time_stamp < ?
        ''', [petId, start.toIso8601String(), end.toIso8601String()]);

        final row = rows.first;
        return RespiratoryStatsSummary(
          avgBpm: (row['avgBpm'] as num?)?.toDouble() ?? 0.0,
          minBpm: (row['minBpm'] as num?)?.toInt() ?? 0,
          maxBpm: (row['maxBpm'] as num?)?.toInt() ?? 0,
        );
      },
    );
  }

  // Fetch overall aggregates, including at-rest vs sleeping averages
  Future<OverallRespiratoryStatsSummary> getOverallStatsForPet(int petId) {
    return _wrap(
      'Failed to load overall stats for pet $petId',
      () async {
        final row = (await db.rawQuery('''
          SELECT
            AVG(respiratory_rate) AS averageBpm,
            MIN(respiratory_rate) AS minBpm,
            MAX(respiratory_rate) AS maxBpm,
            AVG(CASE WHEN pet_state = 'at_rest' THEN respiratory_rate END) AS averageAtRestBpm,
            AVG(CASE WHEN pet_state = 'sleeping' THEN respiratory_rate END) AS averageSleepingBpm
          FROM $_table
          WHERE pet_id = ?
        ''', [petId])).first;

        return OverallRespiratoryStatsSummary.fromMap(row);
      },
    );
  }

  // Get weekly daily averages
  Future<List<DailyStat>> getDailyAveragesForCurrentWeek(int petId, int highThreshold) {
    return _getDailyStats(
      petId: petId,
      start: DateTime.now().subtract(const Duration(days: 6)),
      end: DateTime.now().add(const Duration(days: 1)),
    );
  }

  // Get monthly daily averages
  Future<List<DailyStat>> getDailyAveragesForCurrentMonth(int petId, int highThreshold) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month, now.day + 1);
    return _getDailyStats(petId: petId, start: start, end: end);
  }

  // Rolling weekly summaries in descending order
  Future<List<WeeklyStats>> getWeeklyStatsForPet(int petId) {
    return _wrap<List<WeeklyStats>>(
      'Failed to load weekly stats for pet $petId',
      () async {
        final rows = await db.rawQuery('''
          SELECT
            strftime('%Y-%m-%d', date(time_stamp, 'weekday 0', '-6 days')) AS weekStart,
            strftime('%Y-%m-%d', date(time_stamp, 'weekday 0')) AS weekEnd,
            AVG(respiratory_rate) AS averageBpm,
            MIN(respiratory_rate) AS minBpm,
            MAX(respiratory_rate) AS maxBpm,
            COUNT(*) AS sessionCount,
            CASE
              WHEN SUM(CASE WHEN pet_state = 'sleeping' THEN 1 ELSE 0 END) >
                   SUM(CASE WHEN pet_state = 'at_rest' THEN 1 ELSE 0 END)
              THEN 'sleeping'
              ELSE 'at_rest'
            END AS status
          FROM $_table
          WHERE pet_id = ?
          GROUP BY weekStart
          ORDER BY weekEnd DESC
        ''', [petId]);

        final weeks = rows.map((r) {
          return WeeklyStats(
            weekStart: DateTime.parse(r['weekStart'] as String),
            weekEnd: DateTime.parse(r['weekEnd'] as String),
            averageBpm: (r['averageBpm'] as num).toDouble(),
            minBpm: (r['minBpm'] as num).toInt(),
            maxBpm: (r['maxBpm'] as num).toInt(),
            sessionCount: (r['sessionCount'] as num).toInt(),
            status: r['status'] as String,
            trend: null,
          );
        }).toList();

        for (var i = 0; i + 1 < weeks.length; i++) {
          final current = weeks[i];
          final next = weeks[i + 1];
          weeks[i] = current.copyWith(trend: current.averageBpm - next.averageBpm);
        }

        return weeks;
      },
    );
  }

  // Shared logic for daily stats
  Future<List<DailyStat>> _getDailyStats({
    required int petId,
    required DateTime start,
    required DateTime end,
  }) async {
    return _wrap(
      'Failed to load daily stats for pet $petId',
      () async {
        final rows = await db.rawQuery('''
          SELECT substr(time_stamp, 1, 10) AS dayStr,
                 COUNT(*) AS count,
                 AVG(respiratory_rate) AS avgBpm,
                 MIN(respiratory_rate) AS minBpm,
                 MAX(respiratory_rate) AS maxBpm
          FROM $_table
          WHERE pet_id = ? AND time_stamp >= ? AND time_stamp < ?
          GROUP BY dayStr
          ORDER BY dayStr
        ''', [petId, start.toIso8601String(), end.toIso8601String()]);

        final mapByDay = {for (var r in rows) r['dayStr'] as String: r};
        final stats = <DailyStat>[];
        final days = end.difference(start).inDays;

        for (var i = 0; i < days; i++) {
          final date = start.add(Duration(days: i));
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

  // Generic DB wrapper for error handling
  Future<T> _wrap<T>(String description, Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      throw DataAccessException(description, e);
    }
  }
}
