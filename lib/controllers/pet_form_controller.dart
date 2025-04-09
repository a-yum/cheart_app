import 'package:flutter/material.dart';

import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/factories/pet_profile_factory.dart';

class PetFormController {
  final nameController = TextEditingController();
  final breedController = TextEditingController();
  final vetEmailController = TextEditingController();

  int? selectedMonth;
  int? selectedYear;

  PetFormController({PetProfileModel? initialPet}) {
    if (initialPet != null) {
      nameController.text = initialPet.petName;
      breedController.text = initialPet.petBreed;
      vetEmailController.text = initialPet.vetEmail ?? '';
      selectedMonth = initialPet.birthMonth;
      selectedYear = initialPet.birthYear;
    }
  }

  void dispose() {
    nameController.dispose();
    breedController.dispose();
    vetEmailController.dispose();
  }

  PetProfileModel? validateAndCreate(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) return null;

    return PetProfileFactory.create(
      petName: nameController.text,
      petBreed: breedController.text,
      birthMonth: selectedMonth,
      birthYear: selectedYear,
      vetEmail: vetEmailController.text.isEmpty ? null : vetEmailController.text,
    );
  }
}
