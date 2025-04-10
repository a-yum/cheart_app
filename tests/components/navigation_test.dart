import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheart/main.dart';
import 'package:cheart/components/bottom_navbar.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Navigation test - Bottom Navigation Bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => PetProfileProvider(),
        child: const MyApp(),
      ),
    );
    // Verify we start at home screen
    expect(find.text('CHeart'), findsOneWidget);
    expect(find.byType(BottomNavbar), findsOneWidget);

    // Test pet landing screen navigation
    await tester.tap(find.byIcon(Icons.pets));
    await tester.pumpAndSettle();
    expect(find.text('Pet'), findsOneWidget);

    // Test respiratory rate screen navigation
    await tester.tap(find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(find.text('Respiratory Rate'), findsOneWidget);

    // Test settings screen navigation
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    // Test back to home screen
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    expect(find.text('CHeart'), findsOneWidget);
  });
}