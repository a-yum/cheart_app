import 'package:flutter/material.dart';
import '../models/dog_profile.dart';
import 'dog_profile_card.dart';

class DogProfilesList extends StatelessWidget {
  final List<DogProfile> dogProfiles;

  const DogProfilesList({
    Key? key,
    required this.dogProfiles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: dogProfiles
          .map((dog) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DogProfileCard(dog: dog),
              ))
          .toList(),
    );
  }
}
