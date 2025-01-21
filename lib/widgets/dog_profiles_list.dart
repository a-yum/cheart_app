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
        return ListTile(
          title: Text(dogProfile.name),
          subtitle: Text('Age: ${dogProfile.age}'),
          onTap: () => onProfileSelected(dogProfile), // Trigger navigation
        );
      },
    );
  }
}
