import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheart/components/month_year_picker_dialog.dart';

void main() {
  group('MonthYearPickerDialog', () {
    testWidgets('returns initial values when OK tapped without changes',
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
                    initialMonth: 5,
                    initialYear: 1995,
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

      // Verify initial selections are shown
      expect(find.text('May'), findsOneWidget);
      expect(find.text('1995'), findsOneWidget);

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Should return the initial values
      expect(result, isNotNull);
      expect(result!.$1, 5);
      expect(result!.$2, 1995);
    });

    testWidgets('allows selecting a different month and year',
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

      // Change month from January to December
      await tester.tap(find.text('January'));        // open month dropdown
      await tester.pumpAndSettle();
      await tester.tap(find.text('December').last);  // select December
      await tester.pumpAndSettle();

      // Change year from 2000 to 1990
      await tester.tap(find.text('2000'));           // open year dropdown
      await tester.pumpAndSettle();
      await tester.tap(find.text('1990').last);      // select 1990
      await tester.pumpAndSettle();

      // Confirm selections
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Should return the new selections
      expect(result, isNotNull);
      expect(result!.$1, 12);   // December
      expect(result!.$2, 1990);
    });

    testWidgets('returns null when Cancel is tapped',
        (WidgetTester tester) async {
      (int?, int?)? result = const (5, 2005);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showDialog<(int?, int?)>(
                  context: context,
                  builder: (_) => const MonthYearPickerDialog(
                    initialMonth: 7,
                    initialYear: 2010,
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

      // Should return null on cancel
      expect(result, isNull);
    });
  });
}
