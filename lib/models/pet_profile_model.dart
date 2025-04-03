class PetProfileModel {
  int? id;
  final String petName;
  final int? birthMonth;
  final int? birthYear;
  final String petBreed;
  String? vetEmail;
  String? petImageUrl;

  PetProfileModel({
    this.id,
    required this.petName,
    this.birthMonth,
    this.birthYear,
    required this.petBreed,
    this.vetEmail,
    this.petImageUrl,
  });

  int get petAgeInYears {
    if (birthMonth == null || birthYear == null) return 0;
    final now = DateTime.now();
    
    int computedAge = now.year - birthYear!;
    if (now.month < birthMonth!) {
      computedAge--;
    }
  return computedAge;
}

}