import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cheart/components/common/info_modal.dart';
import 'package:cheart/themes/cheart_theme.dart';

// === Navigator Observer to detect dialog pops ===
class _TestNavigatorObserver extends NavigatorObserver {
  bool didPopRoute = false;

  @override
  void didPop(Route route, Route? previousRoute) {
    didPopRoute = true;
    super.didPop(route, previousRoute);
  }
}

// === Helper to build a minimal app that can show the InfoModal ===
Widget _buildTestApp({required NavigatorObserver observer}) {
  return MaterialApp(
    theme: CHeartTheme.theme,
    navigatorObservers: [observer],
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const InfoModal(),
              );
            },
            child: const Text('Open Info'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  // ==================== Content Display Tests ====================
  testWidgets('InfoModal displays title, sections, and close button',
      (WidgetTester tester) async {
    final observer = _TestNavigatorObserver();
    await tester.pumpWidget(_buildTestApp(observer: observer));

    // Open the dialog
    await tester.tap(find.text('Open Info'));
    await tester.pumpAndSettle();

    // Title
    expect(find.text('Getting Started'), findsOneWidget);

    // Section headers
    expect(find.text('Pet should be at rest or sleeping'), findsOneWidget);
    expect(find.text('How the tracker works'), findsOneWidget);
    expect(find.text('One tap = One breath'), findsOneWidget);
    expect(find.text('Abnormal breathing'), findsOneWidget);

    // Close button
    expect(find.widgetWithText(ElevatedButton, 'Close'), findsOneWidget);
  });

  // ==================== Close Button Behavior Tests ====================
  testWidgets('Close button dismisses the InfoModal',
      (WidgetTester tester) async {
    final observer = _TestNavigatorObserver();
    await tester.pumpWidget(_buildTestApp(observer: observer));

    // Open the dialog
    await tester.tap(find.text('Open Info'));
    await tester.pumpAndSettle();

    // Tap the Close button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Close'));
    await tester.pumpAndSettle();

    // Verify the dialog was popped
    expect(observer.didPopRoute, isTrue);
  });
}
