import 'package:flutter/material.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/factories/pet_profile_factory.dart';

class PetFormController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController breedController = TextEditingController();
  final TextEditingController vetEmailController = TextEditingController();

  int? selectedMonth;
  int? selectedYear;

  // Initializes the form controller with optional initial pet data.
  PetFormController({PetProfileModel? initialPet}) {
    _populateFields(initialPet);
  }

  // Dispose of all text controllers to avoid memory leaks.
  void dispose() {
    nameController.dispose();
    breedController.dispose();
    vetEmailController.dispose();
  }

  // Validates form and returns a new [PetProfileModel] if valid.
  // Returns null if validation fails.
  PetProfileModel? validateAndCreate(GlobalKey<FormState> formKey) {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return null;

    return _buildPetProfile();
  }

  // Populates controllers and fields if [initialPet] is provided.
  void _populateFields(PetProfileModel? initialPet) {
    if (initialPet == null) return;

    nameController.text = initialPet.petName;
    breedController.text = initialPet.petBreed ?? '';
    vetEmailController.text = initialPet.vetEmail ?? '';
    selectedMonth = initialPet.birthMonth;
    selectedYear = initialPet.birthYear;
  }

  // Creates a [PetProfileModel] using current controller values.
  PetProfileModel _buildPetProfile() {
    return PetProfileFactory.create(
      petName: nameController.text.trim(),
      petBreed: breedController.text.trim(),
      birthMonth: selectedMonth,
      birthYear: selectedYear,
      vetEmail: vetEmailController.text.trim().isEmpty
          ? null
          : vetEmailController.text.trim(),
    );
  }
}
