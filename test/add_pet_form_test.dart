import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/components/add_pet_form.dart';

void main() {
  testWidgets('AddPetForm valid submission triggers onSave with correct values',
      (WidgetTester tester) async {
    PetProfileModel? savedPet;

    // Create the widget under test with a callback that sets savedPet.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AddPetForm(
          onSave: (pet) {
            savedPet = pet;
          },
        ),
      ),
    ));

    // Enter valid text into the required fields.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Pet Name*'), 'Buddy');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Breed*'), 'Golden Retriever');

    // For optional vet email, enter a valid email.
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Vet Email'), 'vet@example.com');

    // Ensure the form is valid by tapping the Save button.
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    expect(saveButton, findsOneWidget);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify that onSave was called and the model has the correct values.
    expect(savedPet, isNotNull);
    expect(savedPet!.petName, equals('Buddy'));
    expect(savedPet!.petBreed, equals('Golden Retriever'));
    expect(savedPet!.vetEmail, equals('vet@example.com'));
    // Optional fields not provided should remain null (or default)
    expect(savedPet!.birthMonth, isNull);
    expect(savedPet!.birthYear, isNull);
    // The petImageUrl should be set to default empty string.
    expect(savedPet!.petImageUrl, equals(''));
  });

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

    // Leave required fields empty and tap save.
    final saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.tap(saveButton);
    await tester.pump(); // trigger validation

    // Since required fields are empty, validation should fail and onSave should not be called.
    expect(onSaveCalled, isFalse);
    expect(find.text("Please enter your pet's name"), findsOneWidget);
    expect(find.text("Please enter your pet's breed"), findsOneWidget);
  });
}
