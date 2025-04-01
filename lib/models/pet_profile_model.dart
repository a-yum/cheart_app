class PetProfileModel {
  final int id;
  final String petName;
  final int? birthMonth;
  final int? birthYear;
  final String petBreed;
  String? vetEmail;

  PetProfileModel({
    required this.id,
    required this.petName,
    this.birthMonth,
    this.birthYear,
    required this.petBreed,
    this.vetEmail,
  });

}