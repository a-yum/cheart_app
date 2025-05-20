import 'dart:async';

import 'package:flutter/material.dart';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/utils/respiratory_constants.dart';

class RespiratoryRateProvider extends ChangeNotifier {
  RespiratorySessionDAO? _dao;

  // === Session State ===
  int _breathCount = 0;                    // Number of breaths in current session
  int _timeRemaining = 30;                 // Countdown timer in seconds
  bool _isTracking = false;                // Whether tracking is in progress
  Timer? _timer;                           // Internal timer
  int? _finalBreathsPerMinute;             // Final calculated BPM
  DateTime? _sessionTimestamp;             // Timestamp of session completion

  // === Callbacks ===
  VoidCallback? onSessionComplete;         // Invoked when session ends
  VoidCallback? onHighBreathingRate;       // Invoked if rate exceeds threshold

  int get breathCount => _breathCount;
  int get timeRemaining => _timeRemaining;
  bool get isTracking => _isTracking;
  int get breathsPerMinute => _breathCount * 2; // 30-second count * 2 = BPM

  // Sets the DAO to be used for saving session data
  void setDao(RespiratorySessionDAO dao) {
    _dao = dao;
  }

  void startTracking() {
    if (_isTracking) return;

    _resetSessionValues();
    _isTracking = true;
    _startTimer();
    notifyListeners();
  }

  void incrementBreathCount() {
    if (!_isTracking) return;

    _breathCount++;
    notifyListeners();
  }

  void resetCurrentSession() {
    _timer?.cancel();
    _resetSessionValues();
    notifyListeners();
  }

  void _resetSessionValues() {
    _breathCount = 0;
    _timeRemaining = 30;
    _isTracking = false;
    _finalBreathsPerMinute = null;
    _sessionTimestamp = null;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining <= 0) {
        _endCurrentSession();
      } else {
        _timeRemaining--;
        notifyListeners();
      }
    });
  }

  // Ends the current session, stops timer, evaluates final state
  void _endCurrentSession() {
    _timer?.cancel();
    _isTracking = false;

    _finalBreathsPerMinute = breathsPerMinute;
    _sessionTimestamp = DateTime.now();

    notifyListeners();
    _checkForHighBreathingRate();
    onSessionComplete?.call();
  }

  void _checkForHighBreathingRate() {
    if (breathsPerMinute >= RespiratoryConstants.highBpmThreshold) {
      onHighBreathingRate?.call();
    }
  }

  Future<bool> saveSession({
    required int petId,
    required PetState petState,
    String? notes,
  }) async {
    if (_dao == null) {
      throw StateError('DAO not initialized');
    }

    if (_sessionTimestamp == null || _finalBreathsPerMinute == null) {
      return false;
    }

    try {
      final session = RespiratorySessionModel(
        sessionId: null,
        petId: petId,
        timeStamp: _sessionTimestamp!,
        respiratoryRate: _finalBreathsPerMinute!.toDouble(),
        petState: petState,
        notes: notes,
        isBreathingRateNormal:
            _finalBreathsPerMinute! <= RespiratoryConstants.highBpmThreshold,
      );
      await _dao!.insertSession(session);
      return true;
    } catch (e) {
      print('Error saving respiratory session: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;

    onSessionComplete = null;
    onHighBreathingRate = null;

    resetCurrentSession();
    super.dispose();
  }
}
