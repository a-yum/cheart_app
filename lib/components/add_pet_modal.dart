import 'package:flutter/material.dart';
import 'package:cheart/models/pet_profile_model.dart';
import 'package:cheart/components/add_pet_form.dart';

class AddPetModal extends StatelessWidget {
  final Function(PetProfileModel) onSave;

  const AddPetModal({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: AddPetForm(onSave: onSave),
    );
  }
}