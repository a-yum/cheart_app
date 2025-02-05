import 'package:cheart/widgets/dog_profile_card.dart';
import 'package:flutter/material.dart';
import '../models/dog_profile_model.dart';

class DogProfilesList extends StatelessWidget {
  final List<DogProfileModel> dogProfiles;
  final Function(DogProfileModel) onProfileSelected;

  const DogProfilesList({
    super.key,
    required this.dogProfiles,
    required this.onProfileSelected,
  });

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
