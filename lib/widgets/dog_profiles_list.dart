import 'package:cheart/widgets/dog_profile_card.dart';
import 'package:flutter/material.dart';
import '../models/dog_profile.dart';

class DogProfilesList extends StatelessWidget {
  final List<DogProfile> dogProfiles;
  final Function(DogProfile) onProfileSelected;

  const DogProfilesList({
    Key? key,
    required this.dogProfiles,
    required this.onProfileSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dogProfiles.length,
      itemBuilder: (context, index) {
        final dogProfile = dogProfiles[index];
        return DogProfileCard(
          dog: dogProfile,
        );
      },
    );
  }
}
