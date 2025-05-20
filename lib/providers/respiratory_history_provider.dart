import 'package:flutter/foundation.dart';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/exceptions/data_access_exception.dart';
import 'package:cheart/models/graph_models.dart';
import 'package:cheart/screens/graph_screen_constants.dart';

class RespiratoryHistoryProvider extends ChangeNotifier {
  // DAO for database access and high-BPM threshold
  final RespiratorySessionDAO _dao;
  final int _highThreshold;

  // current pet ID and selected time filter
  int petId;
  TimeFilter selectedFilter = TimeFilter.hourly;

  // loading and error states
  bool isLoading = false;
  String? errorMessage;
  bool hasSessions = false;

  // data for the chart
  List<HourlyPoint> hourlyPoints = [];
  List<DailyStat> dailyStats = [];

  // data for the stat cards
  double? mostRecentBpm;
  double overallAvgBpm = 0.0;
  int? minBpm;
  int? maxBpm;

  RespiratoryHistoryProvider({
    required this.petId,
    required RespiratorySessionDAO dao,
    required int highThreshold,
  })  : _dao = dao,
        _highThreshold = highThreshold;

  // called when the selected pet changes or after adding a new session
  Future<void> updatePet(int newPetId) async {
    if (newPetId == petId) return;
    petId = newPetId;
    await _loadAllData();
  }

  // called when the time filter changes; only reloads the chart data
  Future<void> setFilter(TimeFilter filter) async {
    selectedFilter = filter;
    await _loadChartData();
  }

  // load both chart data and stats (on pet-change or session-add)
  Future<void> _loadAllData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // check if any sessions exist for this pet
      hasSessions = await _dao.hasSessions(petId);
      if (!hasSessions) {
        // clear previous data if none
        hourlyPoints = [];
        dailyStats = [];
        mostRecentBpm = null;
        overallAvgBpm = 0.0;
        minBpm = null;
        maxBpm = null;
        return;
      }

      // load chart and stats independently
      await _loadChartData();
      await _loadStats();
    } on DataAccessException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      errorMessage = 'Unexpected error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // load only the chart data for the current filter
  Future<void> _loadChartData() async {
    switch (selectedFilter) {
      case TimeFilter.hourly:
        final sessions = await _dao.getSessionsForToday(petId);
        hourlyPoints = sessions
            .map((s) => HourlyPoint(time: s.timeStamp, bpm: s.respiratoryRate))
            .toList();
        break;
      case TimeFilter.weekly:
        dailyStats = await _dao.getDailyAveragesForCurrentWeek(
          petId,
          _highThreshold,
        );
        break;
      case TimeFilter.monthly:
        dailyStats = await _dao.getDailyAveragesForCurrentMonth(
          petId,
          _highThreshold,
        );
        break;
    }
    notifyListeners();
  }

  // load only the stats for cards (most recent, all-time avg, min/max)
  Future<void> _loadStats() async {
    if (!hasSessions) return;

    // full time range: from epoch to now
    final start = DateTime.fromMillisecondsSinceEpoch(0);
    final end = DateTime.now();

    // fetch aggregated summary across all sessions
    final summary = await _dao.getSessionStatsBetween(
      petId: petId,
      start: start,
      end: end,
    );
    overallAvgBpm = summary.avgBpm;
    minBpm = summary.minBpm;
    maxBpm = summary.maxBpm;

    // fetch the single most recent session using the new DAO method
    final latest = await _dao.getLatestSession(petId);
    mostRecentBpm = latest?.respiratoryRate;

    notifyListeners();
  }

  // call this after adding a new session to refresh all data
  Future<void> onSessionAdded() async {
    await updatePet(petId);
  }
}
