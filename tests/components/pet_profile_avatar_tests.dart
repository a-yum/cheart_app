import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cheart/components/pet_profile_avatar.dart';

void main() {
  group('PetProfileAvatar Widget Tests', () {
    testWidgets('displays single initial when imagePath is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetProfileAvatar(
              petName: 'Luna',
              imagePath: null,
              size: 100.0,
            ),
          ),
        ),
      );

      // Should show 'L'
      expect(find.text('L'), findsOneWidget);
      // Should not find an Image widget
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('displays two initials when name has two words', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetProfileAvatar(
              petName: 'Teddy Bear',
              imagePath: null,
              size: 80.0,
            ),
          ),
        ),
      );

      // Should show 'TB'
      expect(find.text('TB'), findsOneWidget);
    });

    testWidgets('falls back to initials when image fails to load', (WidgetTester tester) async {
      // Provide a path that does not exist
      const fakePath = '/invalid/path.jpg';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetProfileAvatar(
              petName: 'Buddy',
              imagePath: fakePath,
              size: 60.0,
            ),
          ),
        ),
      );

      // Initial pump builds the widget
      await tester.pumpAndSettle();

      // Should fallback to initials 'B'
      expect(find.text('B'), findsOneWidget);
      // There should be an Image widget attempted, but errorBuilder will replace it
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('provides correct semantics label with imagePath', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetProfileAvatar(
              petName: 'Max',
              imagePath: '/some/path.jpg',
              size: 50.0,
            ),
          ),
        ),
      );

      final finder = find.byType(Semantics);
      expect(finder, findsOneWidget);
      final semantics = tester.getSemantics(finder);
      expect(semantics.label, 'Profile image for Max');
    });

    testWidgets('provides correct semantics label without imagePath', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PetProfileAvatar(
              petName: 'Oscar',
              imagePath: null,
              size: 50.0,
            ),
          ),
        ),
      );

      final finder = find.byType(Semantics);
      expect(finder, findsOneWidget);
      final semantics = tester.getSemantics(finder);
      expect(semantics.label, 'No profile image, initials OS');
    });
  });
}
