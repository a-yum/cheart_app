import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/models/overall_respiratory_stats_summary.dart';
import 'package:cheart/models/weekly_stats.dart';

class XmlExportService {
  final RespiratorySessionDAO _sessionDao;
  XmlExportService(this._sessionDao);

  // Returns a File pointing at a `.xml` in the temp dir.
  Future<File> exportToXml(PetProfileModel pet) async {
    final petId = _validatePetId(pet);

    // 1. Fetch pre‐calculated summaries
    final stats = await _sessionDao.getOverallStatsForPet(petId);
    final weeks = await _sessionDao.getWeeklyStatsForPet(petId);

    // 2. Build XML document string
    final xmlString = _buildXmlString(pet, stats, weeks);

    // 3. Write to temp file
    return _writeXmlFile(petId, xmlString);
  }

  int _validatePetId(PetProfileModel pet) {
    final id = pet.id;
    if (id == null) {
      throw StateError( //toDo: update
        'Cannot export respiratory data: this pet profile has not been saved yet.',
      );
    }
    return id;
  }

  String _buildXmlString(
    PetProfileModel pet,
    OverallRespiratoryStatsSummary stats,
    List<WeeklyStats> weeks,
  ) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('RespiratoryData', nest: () {
      // Overall summary
      builder.element('Summary', nest: () {
        builder.element('AverageBpm', nest: stats.averageBpm.toStringAsFixed(1));
        builder.element('MinBpm', nest: stats.minBpm.toString());
        builder.element('MaxBpm', nest: stats.maxBpm.toString());
        builder.element('AverageAtRestBpm', nest: stats.averageAtRestBpm.toStringAsFixed(1));
        builder.element('AverageSleepingBpm', nest: stats.averageSleepingBpm.toStringAsFixed(1));
      });

      // Weekly averages (most recent first)
      builder.element('WeeklyAverages', nest: () {
        for (final w in weeks) {
          final attrs = <String, String>{};
          if (w.trend != null) {
            attrs['trend'] = w.trend!.toStringAsFixed(1);
          }
          builder.element('WeeklyAverage', attributes: attrs, nest: () {
            builder.element('WeekStart', nest: w.weekStart.toIso8601String().split('T').first);
            builder.element('WeekEnd', nest: w.weekEnd.toIso8601String().split('T').first);
            builder.element('AverageBpm', nest: w.averageBpm.toStringAsFixed(1));
            builder.element('MinBpm', nest: w.minBpm.toString());
            builder.element('MaxBpm', nest: w.maxBpm.toString());
            builder.element('SessionCount', nest: w.sessionCount.toString());
            builder.element('Status', nest: w.status);
          });
        }
      });
    });

    return builder.buildDocument().toXmlString(pretty: true);
  }

  Future<File> _writeXmlFile(int petId, String xmlString) async {
    final dir = await getTemporaryDirectory();
    final filename = _generateFilename(petId);
    final file = File('${dir.path}/$filename');
    await file.writeAsString(xmlString);
    return file;
  }

  String _generateFilename(int petId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'respiratory_${petId}_$timestamp.xml';
  }
}
