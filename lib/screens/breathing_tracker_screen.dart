import 'package:flutter/material.dart';
import '../controllers/breathing_tracker_controller.dart';

class BreathingTrackerScreen extends StatefulWidget {
  const BreathingTrackerScreen({super.key});

  @override
  State<BreathingTrackerScreen> createState() => _BreathingTrackerScreenState();
}

class _BreathingTrackerScreenState extends State<BreathingTrackerScreen> {
  final _breathingTrackerController = BreathingTrackerController();

  @override
  void initState() {
    super.initState();
    _breathingTrackerController.addListener(_handleTimerExpired);
  }

  @override
  void dispose() {
    _breathingTrackerController.removeListener(_handleTimerExpired);
    _breathingTrackerController.dispose();
    super.dispose();
  }

  void _handleTimerExpired() {
    if (_breathingTrackerController.countdown == 0) {
      _showSessionSummaryModal();
    }
  }

  void _resetTimerAndBreathCount() {
    _breathingTrackerController.resetBreathCount();
  }

  void _saveSession() {
    _breathingTrackerController.saveSession();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session saved!')),
    );
  }

  void _showSessionSummaryModal() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.50,
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: const Text(
                    'Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '${_breathingTrackerController.breathCount * 2} breaths for insertDogName.',
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 16.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // "Close" button
                      Flexible(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _resetTimerAndBreathCount();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 400
                                        ? 14
                                        : 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // "Save" button
                      Flexible(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _saveSession();
                              Navigator.of(context).pop();
                              _resetTimerAndBreathCount();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width > 400
                                        ? 14
                                        : 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      _resetTimerAndBreathCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxHeight = constraints.maxHeight;
        final double minDimension = maxWidth < maxHeight ? maxWidth : maxHeight;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Breath Tracker'),
            centerTitle: true,
          ),
          body: ListenableBuilder(
            listenable: _breathingTrackerController,
            builder: (context, _) {
              return Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(vertical: maxHeight * 0.02),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: maxWidth * 0.025),
                      child: Text(
                        'Tap the heart for each full breath cycle (one inhale + one exhale = full breath)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: minDimension * 0.035,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(height: maxHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          'Time: ${_breathingTrackerController.countdown} sec',
                          style: TextStyle(
                            fontSize: minDimension * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Breaths: ${_breathingTrackerController.breathCount}',
                          style: TextStyle(
                            fontSize: minDimension * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: minDimension * 0.6,
                                height: minDimension * 0.6,
                                child: ElevatedButton(
                                  onPressed: _breathingTrackerController
                                      .incrementBreathCount,
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: EdgeInsets.zero,
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: minDimension * 0.3,
                                  ),
                                ),
                              ),
                              if (!_breathingTrackerController.hasStarted)
                                Positioned(
                                  bottom: minDimension * 0.05,
                                  child: Text(
                                    'Tap to Start',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 39, 156, 84),
                                      fontSize: minDimension * 0.05,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: minDimension * 0.05),
                          SizedBox(
                            width: minDimension * 0.4,
                            height: minDimension * 0.12,
                            child: ElevatedButton(
                              onPressed:
                                  _breathingTrackerController.resetBreathCount,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: EdgeInsets.symmetric(
                                  vertical: minDimension * 0.025,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Stop/Reset',
                                style:
                                    TextStyle(fontSize: minDimension * 0.035),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.small(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => Center(
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dialogBackgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: const Text(
                              'Quick Start',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            // Update text format/layout
                            child: SingleChildScrollView(
                              padding: EdgeInsets.all(16.0),
                              child: const Text(
                                'Before Starting\n\n'
                                'Please make sure your dog is resting and/or lightly sleeping.\n'
                                'Your dog should be at rest to ensure consistency of readings. Alertness, deep/REM sleep, and/or other states may affect the accuracy of each session.\n\n'
                                'Counting Your Dog’s Breathing\n\n'
                                'For each breath, tap the heart button.\n'
                                'Each breath includes one inhale and one exhale.\n'
                                'On inhale, your dog’s rib cage will expand, and when exhaling, it will contract.\n\n'
                                'Calculating Breaths per Minute\n\n'
                                'CHeart calculates your dog\'s respiratory rate by multiplying the number of breaths by 2 because the number of breaths you counted was for 30 seconds.\n',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(
                                      color: Colors.grey, width: 0.5)),
                            ),
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close',
                                  style: TextStyle(fontSize: 14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            child: const Icon(Icons.help_outline),
          ),
        );
      },
    );
  }
}
