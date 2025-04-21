import 'package:flutter_test/flutter_test.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/providers/respiratory_rate_provider.dart';
import 'package:cheart/utils/respiratory_constants.dart';


/// Fake DAO that only implements insertSession, recording its input.
class FakeSessionDao implements RespiratorySessionDAO {
  // We don't actually use a real Database here:
  @override
  Database get db => throw UnimplementedError();

  final List<RespiratorySessionModel> inserted = [];

  @override
  Future<int> insertSession(RespiratorySessionModel session) async {
    inserted.add(session);
    return 1;
  }

  // Unneeded?
  @override
  Future<List<RespiratorySessionModel>> getAllSessions() =>
      throw UnimplementedError();

  @override
  Future<RespiratorySessionModel?> getSessionById(int id) =>
      throw UnimplementedError();

  @override
  Future<int> updateSession(RespiratorySessionModel session) =>
      throw UnimplementedError();

  @override
  Future<int> deleteSession(int id) => throw UnimplementedError();
}

void main() {
  group('RespiratoryRateProvider', () {
    late RespiratoryRateProvider provider;
    late FakeSessionDao fakeDao;

    setUp(() {
      provider = RespiratoryRateProvider();
      fakeDao = FakeSessionDao();
      provider.setDao(fakeDao);
    });

    // ==================== Initial State ====================
    test('initial state values are correct', () {
      expect(provider.breathCount, 0);
      expect(provider.timeRemaining, 30);
      expect(provider.isTracking, isFalse);
      expect(provider.breathsPerMinute, 0);
    });

    // ==================== onSessionComplete Callback ====================
    test('startTracking immediately ends session and fires onSessionComplete', () {
      var called = false;
      provider.onSessionComplete = () => called = true;

      provider.startTracking();

      expect(called, isTrue);
      // After ending, tracking is false and BPM still 0
      expect(provider.isTracking, isFalse);
      expect(provider.breathsPerMinute, 0);
    });

    // ==================== Save Session Persists ====================
    test('saveSession writes correct session to DAO', () async {
      // simulate end of session
      provider.startTracking();
      final state = PetState.sleeping;

      await provider.saveSession(petId: 1, petState: state);

      // one insertion
      expect(fakeDao.inserted, hasLength(1));
      final saved = fakeDao.inserted.first;

      // payload matches provider state
      expect(saved.respiratoryRate, provider.breathsPerMinute.toDouble());
      expect(saved.petState, state);
      expect(saved.isBreathingRateNormal,
          provider.breathsPerMinute <= RespiratoryConstants.highBpmThreshold);
      expect(saved.sessionId, isNull);
      expect(saved.timeStamp, isNotNull);
    });
  });
}
