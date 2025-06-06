import 'package:flutter_test/flutter_test.dart';

import 'package:fake_async/fake_async.dart';

import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/providers/respiratory_session_provider.dart';
import 'package:cheart/utils/respiratory_constants.dart';

class FakeSessionDao {
  final List<RespiratorySessionModel> inserted = [];

  Future<int> insertSession(RespiratorySessionModel session) async {
    inserted.add(session);
    return 1;
  }
}

void main() {
  group('RespiratoryRateProvider', () {
    late RespiratoryRateProvider provider;
    late FakeSessionDao fakeDao;

    setUp(() {
      provider = RespiratoryRateProvider();
      fakeDao = FakeSessionDao();
      // Bypass type system by using `dynamic` if needed
      provider.setDao(fakeDao as dynamic);
    });

    // ==================== Initial State ====================
    test('initial state values are correct', () {
      expect(provider.breathCount, 0);
      expect(provider.timeRemaining, 30);
      expect(provider.isTracking, isFalse);
      expect(provider.breathsPerMinute, 0);
    });

    // ==================== Timer + Session Complete ====================
    test('timer countdown ends session and triggers onSessionComplete', () {
      FakeAsync().run((fakeAsync) {
        bool completed = false;
        provider.onSessionComplete = () => completed = true;

        provider.startTracking();
        expect(provider.isTracking, isTrue);

        fakeAsync.elapse(const Duration(seconds: 30));

        expect(completed, isTrue);
        expect(provider.isTracking, isFalse);
        expect(provider.timeRemaining, 0);
      });
    });

    // ==================== Save Session Persists ====================
    test('saveSession writes correct session to DAO', () async {
      FakeAsync().run((fakeAsync) async {
        provider.startTracking();
        provider.incrementBreathCount(); // simulate 1 breath
        fakeAsync.elapse(const Duration(seconds: 30)); // session ends

        final success = await provider.saveSession(
          petId: 1,
          petState: PetState.sleeping,
          notes: 'test note',
        );

        expect(success, isTrue);
        expect(fakeDao.inserted.length, 1);

        final session = fakeDao.inserted.first;
        expect(session.respiratoryRate, 2); // 1 breath * 2
        expect(session.petState, PetState.sleeping);
        expect(session.notes, 'test note');
        expect(session.sessionId, isNull);
        expect(session.timeStamp, isNotNull);
        expect(session.isBreathingRateNormal, isTrue);
      });
    });
  });
}
