import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheart/components/dialogs/month_year_picker_dialog.dart';

void main() {
  group('MonthYearPickerDialog', () {
    testWidgets('tapping OK without changes returns initial values',
        (WidgetTester tester) async {
      (int?, int?)? result;

      // Build a button that opens the dialog
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showDialog<(int?, int?)>(
                  context: context,
                  builder: (_) => const MonthYearPickerDialog(
                    initialMonth: 4,
                    initialYear: 2022,
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify the returned record matches the initial values
      expect(result, isNotNull);
      expect(result!.$1, 4);
      expect(result!.$2, 2022);
    });

    testWidgets('selecting a different month updates the result',
        (WidgetTester tester) async {
      (int?, int?)? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showDialog<(int?, int?)>(
                  context: context,
                  builder: (_) => const MonthYearPickerDialog(
                    initialMonth: 1,
                    initialYear: 2000,
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Open the month dropdown (shows 'January')
      await tester.tap(find.text('January'));
      await tester.pumpAndSettle();

      // Select 'March'
      await tester.tap(find.text('March').last);
      await tester.pumpAndSettle();

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify month changed, year remains initial
      expect(result, isNotNull);
      expect(result!.$1, 3);
      expect(result!.$2, 2000);
    });

    testWidgets('tapping Cancel returns null', (WidgetTester tester) async {
      (int?, int?)? result = const (5, 1999);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showDialog<(int?, int?)>(
                  context: context,
                  builder: (_) => const MonthYearPickerDialog(
                    initialMonth: 6,
                    initialYear: 2021,
                  ),
                );
              },
              child: const Text('Open'),
            );
          }),
        ),
      );

      // Open the dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Expect result to be null (dialog returns null on cancel)
      expect(result, isNull);
    });
  });
}
