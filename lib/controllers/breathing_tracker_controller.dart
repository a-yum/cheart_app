import 'dart:async';
import 'package:flutter/material.dart';

class BreathingTrackerController extends ChangeNotifier {
  int breathCount = 0;
  int countdown = 1; // seconds
  Timer? timer;
  bool isCounting = false;
  bool hasStarted = false;

  void startCountdown() {
    isCounting = true;
    hasStarted = true;
    notifyListeners();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
        notifyListeners();
      } else {
        stopCountdown();
      }
    });
  }

  void incrementBreathCount() {
    if (!hasStarted) {
      startCountdown();
    }
    breathCount++;
    notifyListeners();
  }

  void stopCountdown() {
    timer?.cancel();
    isCounting = false;
    countdown = 1; // change for testing
    notifyListeners();
  }

  void resetBreathCount() {
    // resets timer(countDown) to 30sec
    stopCountdown();
    breathCount = 0;
    hasStarted = false;
    notifyListeners();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void saveSession() {}
}
