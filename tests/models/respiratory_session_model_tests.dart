import 'package:flutter_test/flutter_test.dart';

import 'package:cheart/models/respiratory_session_model.dart';

void main() {
  group('RespiratorySessionModel', () {
    // ==================== toMap & fromMap Round-Trip ====================
    test('toMap and fromMap preserve all fields correctly', () {
      final now = DateTime.now();
      final original = RespiratorySessionModel(
        sessionId: 42,
        timeStamp: now,
        respiratoryRate: 18.5,
        petState: PetState.sleeping,
        notes: null,
        isBreathingRateNormal: true,
      );

      final map = original.toMap();
      final reconstructed = RespiratorySessionModel.fromMap(map);

      expect(reconstructed.sessionId, equals(42));
      expect(reconstructed.timeStamp.toIso8601String(), equals(now.toIso8601String()));
      expect(reconstructed.respiratoryRate, equals(18.5));
      expect(reconstructed.petState, equals(PetState.sleeping));
      expect(reconstructed.notes, isNull);
      expect(reconstructed.isBreathingRateNormal, isTrue);
    });

    // ==================== toString Output ====================
    test('toString returns a descriptive string', () {
      final now = DateTime.parse('2025-04-17T12:00:00.000Z');
      final model = RespiratorySessionModel(
        sessionId: 7,
        timeStamp: now,
        respiratoryRate: 22.0,
        petState: PetState.resting,
        notes: 'No issues',
        isBreathingRateNormal: false,
      );
      final str = model.toString();

      expect(str, contains('RespiratorySessionModel'));
      expect(str, contains('id: 7'));
      expect(str, contains('timeStamp: $now'));
      expect(str, contains('respiratoryRate: 22.0'));
      expect(str, contains('petState: PetState.resting'));
      expect(str, contains('notes: No issues'));
      expect(str, contains('isBreathingRateNormal: false'));
    });

    // ==================== Null sessionId Handling ====================
    test('handles null sessionId correctly in toMap/fromMap', () {
      final now = DateTime.now();
      final model = RespiratorySessionModel(
        sessionId: null,
        timeStamp: now,
        respiratoryRate: 30.0,
        petState: PetState.resting,
        notes: 'Test',
        isBreathingRateNormal: true,
      );

      final map = model.toMap();
      // The map should include a null for session_id
      expect(map['session_id'], isNull);

      final reconstructed = RespiratorySessionModel.fromMap(map);
      expect(reconstructed.sessionId, isNull);
      expect(reconstructed.timeStamp.toIso8601String(), equals(now.toIso8601String()));
      expect(reconstructed.notes, equals('Test'));
    });
  });
}
