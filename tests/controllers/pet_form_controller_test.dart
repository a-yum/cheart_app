import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cheart/controllers/pet_form_controller.dart';
import 'package:cheart/models/pet_profile_model.dart';

void main() {
  group('PetFormController', () {
    late PetFormController controller;
    final formKey = GlobalKey<FormState>();

    setUp(() {
      controller = PetFormController();
    });

    tearDown(() {
      controller.dispose();
    });

    // ==================== Test: Initialization with initialPet ====================
    test('initialize with initialPet pre-fills the fields', () {
      final pet = PetProfileModel(
        petName: 'Luna',
        petBreed: 'Husky',
        birthMonth: 3,
        birthYear: 2020,
        vetEmail: 'vet@example.com',
      );

      final initializedController = PetFormController(initialPet: pet);

      expect(initializedController.nameController.text, 'Luna');
      expect(initializedController.breedController.text, 'Husky');
      expect(initializedController.vetEmailController.text, 'vet@example.com');
      expect(initializedController.selectedMonth, 3);
      expect(initializedController.selectedYear, 2020);
    });

    // ==================== Test: validateAndCreate returns null on invalid form ====================
    testWidgets('validateAndCreate returns null if form is invalid', (tester) async {
      final widget = MaterialApp(
        home: Form(
          key: formKey,
          child: TextFormField(
            controller: controller.nameController,
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
        ),
      );

      await tester.pumpWidget(widget);
      final result = controller.validateAndCreate(formKey);
      expect(result, isNull);
    });

    // ==================== Test: validateAndCreate returns model on valid form ====================
    testWidgets('validateAndCreate returns a PetProfileModel if form is valid', (tester) async {
      controller.nameController.text = 'Buddy';
      controller.breedController.text = 'Golden Retriever';
      controller.selectedMonth = 5;
      controller.selectedYear = 2019;
      controller.vetEmailController.text = 'vet@example.com';

      final widget = MaterialApp(
        home: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.nameController,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: controller.breedController,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      );

      await tester.pumpWidget(widget);

      // Trigger form validation
      formKey.currentState!.validate();

      final result = controller.validateAndCreate(formKey);
      expect(result, isNotNull);
      expect(result!.petName, 'Buddy');
      expect(result.petBreed, 'Golden Retriever');
      expect(result.birthMonth, 5);
      expect(result.birthYear, 2019);
      expect(result.vetEmail, 'vet@example.com');
    });
  });
}
