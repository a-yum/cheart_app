class PetProfileModel {
  int? id;
  final String petName;
  final int? birthMonth;
  final int? birthYear;
  final String? petBreed;
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
    
    int computedAgeinYears = now.year - birthYear!;
    if (now.month < birthMonth!) {
      computedAgeinYears--;
    }
  return computedAgeinYears;
}

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pet_name': petName,
      'birth_month': birthMonth,
      'birth_year': birthYear,
      'pet_breed': petBreed,
      'vet_email': vetEmail,
      'pet_image_url': petImageUrl,
    };
  }

    // toDo: existing factory v.s. class constructor
  //   factory PetProfileModel.fromMap(Map<String, dynamic> map) {
  //     final pet = PetProfileFactory.create(
  //       petName: map['pet_name'] as String,
  //       petBreed: map['pet_breed'] as String,
  //       birthMonth: map['birth_month'] as int?,
  //       birthYear: map['birth_year'] as int?,
  //       vetEmail: map['vet_email'] as String?,
  //     );
  //     // Set additional fields that the factory doesn't handle.
  //     pet.id = map['id'] as int?;
  //     pet.petImageUrl = map['pet_image_url'] as String?;
  //     return pet;
  // }

  factory PetProfileModel.fromMap(Map<String, dynamic> map) {
    return PetProfileModel(
      id: map['id'] as int?,
      petName: map['pet_name'] as String,
      birthMonth: map['birth_month'] as int?,
      birthYear: map['birth_year'] as int?,
      petBreed: map['pet_breed'] as String?,
      vetEmail: map['vet_email'] as String?,
      petImageUrl: map['pet_image_url'] as String?,
    );
  }
  
  // Returns a copy of this model with the given fields replaced.
  PetProfileModel copyWith({
    int? id,
    String? petName,
    int? birthMonth,
    int? birthYear,
    String? petBreed,
    String? vetEmail,
    String? petImageUrl,
  }) {
    return PetProfileModel(
      id: id ?? this.id,
      petName: petName ?? this.petName,
      birthMonth: birthMonth ?? this.birthMonth,
      birthYear: birthYear ?? this.birthYear,
      petBreed: petBreed ?? this.petBreed,
      vetEmail: vetEmail ?? this.vetEmail,
      petImageUrl: petImageUrl ?? this.petImageUrl,
    );
  }

  
}