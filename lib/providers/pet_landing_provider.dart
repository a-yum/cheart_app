import 'package:flutter/foundation.dart';
import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/respiratory_session_model.dart';

class PetLandingProvider extends ChangeNotifier {
  final RespiratorySessionDAO _sessionDao;
  int petId; // <-- removed 'final' so we can update this value

  // ─── State fields ───
  RespiratorySessionModel? latestSession;
  double? todayAvg;
  double? yesterdayAvg;
  int currentStreak = 0;

  PetLandingProvider({
    required RespiratorySessionDAO sessionDao,
    required this.petId, // no longer final
  }) : _sessionDao = sessionDao;

  /// Public method: load all three stats in parallel and notify listeners.
  Future<void> loadAll() async {
    await Future.wait([
      _loadLatestSession(),
      _loadTodayAverage(),
      _loadCurrentStreak(),
    ]);
    notifyListeners();
  }

  // ─── 1. Load the single most recent session ───
  Future<void> _loadLatestSession() async {
    try {
      latestSession = await _sessionDao.getLatestSession(petId);
    } catch (e) {
      latestSession = null;
    }
  }

  // ─── 2. Compute “today’s avg” and “yesterday’s avg” ───
  Future<void> _loadTodayAverage() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final tomorrowStart = todayStart.add(const Duration(days: 1));
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      // a) Sessions for today: [todayStart, tomorrowStart)
      final todaySessions = await _sessionDao.getSessionsBetween(
        petId: petId,
        start: todayStart,
        end: tomorrowStart,
      );

      // b) Sessions for yesterday: [yesterdayStart, todayStart)
      final yesterdaySessions = await _sessionDao.getSessionsBetween(
        petId: petId,
        start: yesterdayStart,
        end: todayStart,
      );

      if (todaySessions.isNotEmpty) {
        // Each record’s .respiratoryRate is breaths in 30s → ×2 for breaths/min
        final sumToday = todaySessions
            .map((s) => s.respiratoryRate.toDouble())
            .reduce((a, b) => a + b);
        todayAvg = (sumToday / todaySessions.length) * 2;
      } else {
        todayAvg = null;
      }

      if (yesterdaySessions.isNotEmpty) {
        final sumYest = yesterdaySessions
            .map((s) => s.respiratoryRate.toDouble())
            .reduce((a, b) => a + b);
        yesterdayAvg = (sumYest / yesterdaySessions.length) * 2;
      } else {
        yesterdayAvg = null;
      }
    } catch (e) {
      todayAvg = null;
      yesterdayAvg = null;
    }
  }

  // ─── 3. Compute “current consecutive‐days streak” ───
  Future<void> _loadCurrentStreak() async {
    try {
      // Fetch a descending list of distinct dates (midnight) with ≥1 session
      final sessionDates = await _sessionDao.getDistinctSessionDates(petId);

      if (sessionDates.isEmpty) {
        currentStreak = 0;
        return;
      }

      // Build a set of “yyyy-MM-dd” strings for O(1) lookups
      final dateStrings = sessionDates.map((dt) {
        final y = dt.year.toString().padLeft(4, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final d = dt.day.toString().padLeft(2, '0');
        return '$y-$m-$d';
      }).toSet();

      final now = DateTime.now();
      var count = 0;
      var dayIterator = DateTime(now.year, now.month, now.day); // today @ midnight

      while (true) {
        final y = dayIterator.year.toString().padLeft(4, '0');
        final m = dayIterator.month.toString().padLeft(2, '0');
        final d = dayIterator.day.toString().padLeft(2, '0');
        final key = '$y-$m-$d';

        if (dateStrings.contains(key)) {
          count += 1;
          dayIterator = dayIterator.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      currentStreak = count;
    } catch (e) {
      currentStreak = 0;
    }
  }
}
