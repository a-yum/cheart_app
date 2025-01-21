import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/breathing_rate_controller.dart';
import '../widgets/navbar.dart';
import '../models/dog_profile_model.dart';

class BreathingTrackerScreen extends StatelessWidget {
  final DogProfileModel? dogProfileModel;
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const BreathingTrackerScreen({
    Key? key,
    required this.dogProfileModel,
    required this.selectedIndex,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BreathingRateController(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('${dogProfileModel?.name} - Breathing Tracker'),
        ),
        body: BreathingRateBody(),
        bottomNavigationBar: Navbar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
        ),
      ),
    );
  }
}

class BreathingRateBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<BreathingRateController>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Tap the heart button to track breaths for 30 seconds.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Time Remaining: ${controller.secondsRemaining}s',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red, size: 48),
                onPressed: controller.isTimerRunning
                    ? controller.incrementHeartCount
                    : null,
              ),
              const SizedBox(width: 16),
              if (controller.isTimerRunning)
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 48),
                  onPressed: controller.resetTimer,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!controller.isTimerRunning && controller.breathCount > 0)
            Text(
              'Breaths Per Minute: ${controller.calculateBreathsPerMinute()}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: controller.isTimerRunning
                ? null
                : () {
                    final result = controller.finalizeSession();
                    Navigator.pop(context, result); // Return result to parent
                  },
            child: const Text('Finish Tracking'),
          ),
        ],
      ),
    );
  }
}
