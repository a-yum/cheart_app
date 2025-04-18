enum PetState {
  resting,
  sleeping,
}

class RespiratorySessionModel {
  int? sessionId;
  final DateTime timeStamp;
  final double respiratoryRate;
  final PetState petState; // pet is at rest or sleep at time of monitoring
  final String? notes;
  final bool isBreathingRateNormal; // current threshold is 40 bpm

  RespiratorySessionModel({
    this.sessionId,
    required this.timeStamp,
    required this.respiratoryRate,
    required this.petState,
    this.notes,
    required this.isBreathingRateNormal,
  });

  @override
  String toString() {
    return 'RespiratorySessionModel(id: $sessionId, timeStamp: $timeStamp, '
        'respiratoryRate: $respiratoryRate, petState: $petState, '
        'notes: $notes, isBreathingRateNormal: $isBreathingRateNormal)';
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'time_stamp': timeStamp.toIso8601String(),
      'respiratory_rate': respiratoryRate,
      'pet_state': petState.name,
      'is_breathing_rate_normal': isBreathingRateNormal ? 1 : 0,
    };
  }

  factory RespiratorySessionModel.fromMap(Map<String, dynamic> map) {
    return RespiratorySessionModel(
      sessionId: map['session_id'] as int?,
      timeStamp: DateTime.parse(map['time_stamp'] as String),
      respiratoryRate: (map['respiratory_rate'] as num).toDouble(),
      petState: PetState.values.firstWhere(
        (e) => e.name == map['pet_state'],
        orElse: () => PetState.resting,
      ),
      isBreathingRateNormal: map['is_breathing_rate_normal'] == 1,
    );
  }
}
