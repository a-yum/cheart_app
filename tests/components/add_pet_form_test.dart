import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/components/add_pet_form.dart';
import 'package:cheart/dao/pet_profile_dao.dart';
import 'package:cheart/providers/pet_profile_provider.dart';

class MockPetProfileDAO extends Mock implements PetProfileDAO {}

class MockPetProfileProvider extends Mock implements PetProfileProvider {}

void main() {
  testWidgets('AddPetForm valid submission triggers onSave with correct values',
      (WidgetTester tester) async {
    PetProfileModel? savedPet;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AddPetForm(
          onSave: (pet) {
            savedPet = pet;
          },
        ),
      ),
    ));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Pet Name*'), 'Buddy');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Breed*'), 'Golden Retriever');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Vet Email'), 'vet@example.com');

    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(savedPet, isNotNull);
    expect(savedPet!.petName, equals('Buddy'));
    expect(savedPet?.petBreed, equals('Golden Retriever'));
    expect(savedPet?.vetEmail, equals('vet@example.com'));
    expect(savedPet?.birthMonth, isNull);
    expect(savedPet?.birthYear, isNull);
    expect(savedPet?.petImageUrl, equals(''));
  });
  
  // ==================== Validation Error Test ====================
  testWidgets('AddPetForm shows validation error when required fields are missing',
      (WidgetTester tester) async {
    bool onSaveCalled = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AddPetForm(
          onSave: (_) {
            onSaveCalled = true;
          },
        ),
      ),
    ));

    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.tap(saveButton);
    await tester.pump();

    expect(onSaveCalled, isFalse);
    expect(find.text("Please enter your pet's name"), findsOneWidget);
    expect(find.text("Please enter your pet's breed"), findsOneWidget);
  });

  // ==================== Month-Year Selector Test ===================
  testWidgets('AddPetForm updates birth date after selecting month and year',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AddPetForm(
          onSave: (_) {},
        ),
      ),
    ));

    // Tap to open the birth date picker dialog
    await tester.tap(find.text('Select Date'));
    await tester.pumpAndSettle(); // Wait for dialog to appear

    // Select a specific month (e.g. March)
    final marchOption = find.text('March').last;
    expect(marchOption, findsOneWidget);
    await tester.tap(marchOption);
    await tester.pump();

    // Select a year (e.g. current year)
    final yearOption = find.text(DateTime.now().year.toString()).last;
    expect(yearOption, findsOneWidget);
    await tester.tap(yearOption);
    await tester.pump();

    // Confirm the dialog selection
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    // Check that the date has been updated in the UI
    expect(find.text('March ${DateTime.now().year}'), findsOneWidget);
  });

}
