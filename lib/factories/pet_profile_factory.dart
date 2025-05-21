import 'package:cheart/models/pet_profile_model.dart';

class PetProfileFactory {
  static PetProfileModel create({
    required String petName,
    required String petBreed,
    int? birthMonth,
    int? birthYear,
    String? vetEmail,
  }) {
    return PetProfileModel(
      petName: petName,
      petBreed: petBreed,
      birthMonth: birthMonth,
      birthYear: birthYear,
      vetEmail: vetEmail != null && vetEmail.isEmpty ? null : vetEmail,
      petProfileImagePath: '', // ToDo: Update le image
    );
  }
}