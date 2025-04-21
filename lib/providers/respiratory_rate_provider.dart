import 'dart:async';

import 'package:cheart/dao/respiratory_session_dao.dart';
import 'package:cheart/models/respiratory_session_model.dart';
import 'package:cheart/utils/respiratory_constants.dart';
import 'package:flutter/material.dart';

class RespiratoryRateProvider extends ChangeNotifier {
  late RespiratorySessionDAO _dao;

  int _breathCount = 0;
  int _timeRemaining = 30;
  bool _isTracking = false;

  Timer? _timer;

  VoidCallback? onSessionComplete;
  VoidCallback? onHighBreathingRate;

  int? _finalBreathsPerMinute;
  DateTime? _sessionTimestamp;

  int get breathCount => _breathCount;
  int get timeRemaining => _timeRemaining;
  bool get isTracking => _isTracking;
  int get breathsPerMinute => _breathCount * 2;

  void setDao(RespiratorySessionDAO dao) {
    _dao = dao;
  }

  void startTracking() {
    _breathCount = 0;
    _timeRemaining = 30;
    _isTracking = true;

    _endCurrentession();
    notifyListeners();
  }

  void incrementBreathCount() {
    if (_isTracking) {
      _breathCount++;
      notifyListeners();
    }
  }

  void resetCurrentSession() {
    _timer?.cancel();
    _breathCount = 0;
    _timeRemaining = 30;
    _isTracking = false;
    notifyListeners();
  }

  void _endCurrentession() {
    _timer?.cancel();
    _isTracking = false;

    _finalBreathsPerMinute = breathsPerMinute;
    _sessionTimestamp = DateTime.now();

    notifyListeners();
    _checkForHighBreathingRate();
    onSessionComplete?.call();
  }

  void _checkForHighBreathingRate() {
    if (breathsPerMinute >= 40 && onHighBreathingRate != null) {
      onHighBreathingRate!();
    }
  }

  Future<bool> saveSession({
    required int petId,
    required PetState petState,
    String? notes,
  }) async {
    if (_sessionTimestamp == null || _finalBreathsPerMinute == null) {
      return false;
    }

    final session = RespiratorySessionModel(
      sessionId: null,
      petId: petId,
      timeStamp: _sessionTimestamp!,
      respiratoryRate: _finalBreathsPerMinute!.toDouble(),
      petState: petState,
      notes: notes,
      isBreathingRateNormal: _finalBreathsPerMinute! <= RespiratoryConstants.highBpmThreshold,
    );

    try {
      await _dao.insertSession(session);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
