import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';

import 'package:cheart/components/post_session_modal.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/providers/respiratory_rate_provider.dart';
import 'package:cheart/utils/respiratory_constants.dart';

class TestRespiratoryProvider extends RespiratoryRateProvider {
  PetState? savedState;
  int? savedPetId;
  bool returnSuccess = true;
  bool shouldThrowError = false;

  @override
  Future<bool> saveSession({
    required int petId,
    required PetState petState,
    String? notes,
  }) async {
    if (shouldThrowError) {
      throw Exception('Test error');
    }
    savedPetId = petId;
    savedState = petState;
    return returnSuccess;
  }
}

void main() {
  const petName = 'Rover';
  const petId = 1;
  const lowBpm = RespiratoryConstants.highBpmThreshold - 1;
  const highBpm = RespiratoryConstants.highBpmThreshold + 5;

  Widget _wrapWithProvider(int bpm, TestRespiratoryProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<RespiratoryRateProvider>.value(
        value: provider,
        child: Scaffold(
          body: PostSessionModal(
            petName: petName,
            petId: petId,
            breathsPerMinute: bpm,
          ),
        ),
      ),
    );
  }

  // ==================== Banner Visibility Tests ====================
  group('PostSessionModal banner visibility', () {
    testWidgets('shows warning when BPM is high', (tester) async {
      final prov = TestRespiratoryProvider();
      await tester.pumpWidget(_wrapWithProvider(highBpm, prov));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.textContaining('Breathing Rate is $highBpm BPM!'),
          findsOneWidget);
    });

    testWidgets('does not show warning when BPM is low', (tester) async {
      final prov = TestRespiratoryProvider();
      await tester.pumpWidget(_wrapWithProvider(lowBpm, prov));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
      expect(find.textContaining('Breathing Rate is'), findsNothing);
      expect(find.text('Breathing Rate: $lowBpm BPM'), findsOneWidget);
    });
  });

  // ==================== Save Button Behavior Tests ====================
  group('PostSessionModal save behavior', () {
    testWidgets('Save button disabled until status selected', (tester) async {
      final prov = TestRespiratoryProvider();
      await tester.pumpWidget(_wrapWithProvider(lowBpm, prov));
      await tester.pumpAndSettle();

      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNull);

      await tester.tap(find.widgetWithText(RadioListTile<PetState>, 'Sleeping'));
      await tester.pumpAndSettle();
      expect(tester.widget<ElevatedButton>(saveButton).onPressed, isNotNull);
    });

    testWidgets('Successful save shows success message and closes modal',
        (tester) async {
      final prov = TestRespiratoryProvider()..returnSuccess = true;
      await tester.pumpWidget(_wrapWithProvider(lowBpm, prov));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(RadioListTile<PetState>, 'At Rest'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(prov.savedState, equals(PetState.resting));
      expect(prov.savedPetId, equals(petId));
      expect(find.text('Session saved successfully'), findsOneWidget);
    });

    testWidgets('Failed save shows error message and keeps modal open',
        (tester) async {
      final prov = TestRespiratoryProvider()..returnSuccess = false;
      await tester.pumpWidget(_wrapWithProvider(lowBpm, prov));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(RadioListTile<PetState>, 'At Rest'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to save session'), findsOneWidget);
      expect(find.byType(PostSessionModal), findsOneWidget);
    });

    testWidgets('Save with exception shows error message', (tester) async {
      final prov = TestRespiratoryProvider()..shouldThrowError = true;

      await tester.pumpWidget(_wrapWithProvider(lowBpm, prov));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(RadioListTile<PetState>, 'At Rest'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Error saving session: Exception: Test error'),
          findsOneWidget);
      expect(find.byType(PostSessionModal), findsOneWidget);
    });
  });
}
