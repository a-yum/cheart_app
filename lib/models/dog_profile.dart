class DogProfile {
  final String id;
  final String name;
  final String breed;
  final int age;
  final String? imagePlaceHolder;
  final String? vetEmail;
  final int? avgBreathingRate;

  DogProfile(
      {required this.id,
      required this.name,
      required this.breed,
      required this.age,
      this.imagePlaceHolder,
      this.vetEmail,
      this.avgBreathingRate});

  get avgHeartRate => null;
}
