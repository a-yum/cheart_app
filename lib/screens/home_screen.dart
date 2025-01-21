import 'package:flutter/material.dart';
import '../widgets/add_dog_form.dart';
import '../widgets/dog_profiles_list.dart';
import '../widgets/navbar.dart';
import '../models/dog_profile.dart';
import '../screens/breathing_tracker_screen.dart'; // Import BreathingTrackerScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<DogProfile> _dogProfiles = [];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _addNewDog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddDogForm(
        onSubmit: (DogProfile newDog) {
          setState(() {
            _dogProfiles.add(newDog);
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Dogs'),
        centerTitle: true,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
      ),
      body: _dogProfiles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Minimize column size
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to CHeart!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Canine Heart tracking app that helps you track your dog's breathing rate.",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Tap the "+" button below to add your doggo.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: DogProfilesList(
                dogProfiles: _dogProfiles,
                onProfileSelected: (DogProfile) {},
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewDog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Navbar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
