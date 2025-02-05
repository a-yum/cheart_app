import 'package:cheart/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/add_dog_form.dart';
import '../widgets/dog_profiles_list.dart';
import '../widgets/navbar.dart';
import '../models/dog_profile_model.dart';
import 'breathing_tracker_screen.dart';
import 'breathing_chartgraph_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final List<DogProfileModel> _dogProfiles = [];

  final List<Widget> _screens = <Widget>[
    Container(),
    BreathingChartGraphScreen(),
    BreathingTrackerScreen(),
    SettingsScreen()
  ];

  // Move?
  void _addNewDog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddDogForm(
        onSubmit: (DogProfileModel newDog) {
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
      body: currentIndex == 0
          ? (_dogProfiles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome to CHeart!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Canine Heart tracking app that helps you track your dog's respiratory rate.",
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
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: DogProfilesList(
                      dogProfiles: _dogProfiles,
                      onProfileSelected: (DogProfile) {},
                    ),
                  ),
                ))
          : _screens[currentIndex],
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton(
              onPressed: _addNewDog,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: Navbar(
        onDestinationSelected: (int index) {
          setState(() {
            currentIndex = index;
          });
        },
        currentIndex: currentIndex,
      ),
    );
  }
}
