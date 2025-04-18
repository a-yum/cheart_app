import 'package:sqflite/sqflite.dart';

import 'package:cheart/models/respiratory_session_model.dart';

class RespiratorySessionDAO {
  static const String _table = 'respiratory_sessions';

  final Database db;
  RespiratorySessionDAO(this.db);

  Future<int> insertSession(RespiratorySessionModel session) {
    return db.insert(
      _table,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<RespiratorySessionModel>> getAllSessions() async {
    final maps = await db.query(
      _table,
      orderBy: 'time_stamp DESC',
    );
    return maps.map(RespiratorySessionModel.fromMap).toList();
  }

  Future<RespiratorySessionModel?> getSessionById(int id) async {
    final maps = await db.query(
      _table,
      where: 'session_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return RespiratorySessionModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateSession(RespiratorySessionModel session) {
    return db.update(
      _table,
      session.toMap(),
      where: 'session_id = ?',
      whereArgs: [session.sessionId],
    );
  }

  Future<int> deleteSession(int id) {
    return db.delete(
      _table,
      where: 'session_id = ?',
      whereArgs: [id],
    );
  }
}
