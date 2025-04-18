import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';

import 'package:cheart/components/post_session_modal.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/providers/respiratory_rate_provider.dart';
import 'package:cheart/utils/respiratory_constants.dart';

class TestRespiratoryProvider extends RespiratoryRateProvider {
  PetState? savedState;
  @override
  Future<void> saveSession(PetState petState) async {
    savedState = petState;
  }
}

void main() {
  const petName = 'Rover';
  const lowBpm = RespiratoryConstants.highBpmThreshold - 1;
  const highBpm = RespiratoryConstants.highBpmThreshold + 5;

  Widget _wrapWithProvider(int bpm, TestRespiratoryProvider provider) {
    return MaterialApp(
      home: ChangeNotifierProvider<RespiratoryRateProvider>.value(
        value: provider,
        child: Scaffold(
          body: PostSessionModal(
            petName: petName,
            breathsPerMinute: bpm,
            onSave: (_) {},
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

      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(prov.savedState, equals(PetState.sleeping));
    });

    testWidgets('Selecting "At Rest" and saving calls provider accordingly',
        (tester) async {
      final prov = TestRespiratoryProvider();
      await tester.pumpWidget(_wrapWithProvider(highBpm, prov));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(RadioListTile<PetState>, 'At Rest'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pumpAndSettle();

      expect(prov.savedState, equals(PetState.resting));
    });
  });
}
