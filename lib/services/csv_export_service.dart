import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/models/overall_respiratory_stats_summary.dart';
import 'package:cheart/models/weekly_stats.dart';

class CsvExportService {
  final RespiratorySessionDAO _sessionDao;
  CsvExportService(this._sessionDao);

  // Returns a File pointing at a `.csv` in the temp dir.
  Future<File> exportToCsv(PetProfileModel pet) async {
    final petId = pet.id;
    if (petId == null) {
      throw StateError('Pet must be saved before exporting.');
    }

    // 1. Fetch data
    final summary       = await _sessionDao.getOverallStatsForPet(petId);
    final weeks         = await _sessionDao.getWeeklyStatsForPet(petId);
    final abnormalCount = await _sessionDao.countAbnormalSessions(petId);

    // 2. Build CSV rows
    final rows = <List<dynamic>>[];

    // 2a) Metadata/header section
    rows.add(['CHeart Export for', pet.petName]);
    rows.add(['Exported at', DateTime.now().toIso8601String()]);
    rows.add([]);

    // 2b) Summary section
    rows.add(['Summary']);
    rows.add([
      'AverageBpm',
      'MinBpm',
      'MaxBpm',
      'AverageAtRestBpm',
      'AverageSleepingBpm',
      'AbnormalSessionCount',
    ]);
    rows.add([
      summary.averageBpm.toStringAsFixed(1),
      summary.minBpm,
      summary.maxBpm,
      summary.averageAtRestBpm.toStringAsFixed(1),
      summary.averageSleepingBpm.toStringAsFixed(1),
      abnormalCount,
    ]);
    rows.add([]); // blank line

    // 2c) Weekly table
    rows.add(['WeeklyAverages']);
    rows.add([
      'WeekStart',
      'WeekEnd',
      'AverageBpm',
      'MinBpm',
      'MaxBpm',
      'SessionCount',
      'Status',
      'Trend'
    ]);
    for (final w in weeks) {
      rows.add([
        w.weekStart.toIso8601String().split('T').first,
        w.weekEnd.toIso8601String().split('T').first,
        w.averageBpm.toStringAsFixed(1),
        w.minBpm,
        w.maxBpm,
        w.sessionCount,
        w.status,
        w.trend?.toStringAsFixed(1) ?? '',
      ]);
    }

    // 3. Convert & write
    final csv      = const ListToCsvConverter().convert(rows);
    final dir      = await getTemporaryDirectory();
    final filename = 'respiratory_${petId}_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file     = File('${dir.path}/$filename');
    await file.writeAsString(csv);
    return file;
  }
}
