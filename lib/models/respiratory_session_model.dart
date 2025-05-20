// Pet's state during a respiratory session.
enum PetState {
  resting,
  sleeping,
}

class RespiratorySessionModel {
  int? sessionId;
  final DateTime timeStamp;
  final int petId;
  final double respiratoryRate;
  final PetState petState; // Pet is either resting or sleeping during the session
  final String? notes; // toDo: needed?
  final bool isBreathingRateNormal; // toDo:threshold? (currently < 40 BPM)

  RespiratorySessionModel({
    this.sessionId,
    required this.timeStamp,
    required this.petId,
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
      'pet_id': petId,
      'time_stamp': timeStamp.toIso8601String(),
      'respiratory_rate': respiratoryRate,
      'pet_state': petState.name,
      'is_breathing_rate_normal': isBreathingRateNormal ? 1 : 0,
    };
  }

  factory RespiratorySessionModel.fromMap(Map<String, dynamic> map) {
    return RespiratorySessionModel(
      sessionId: map['session_id'] as int?,
      petId: map['pet_id'] as int,
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
