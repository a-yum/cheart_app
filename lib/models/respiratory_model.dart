class RespiratoryModel {
  final int id;
  final DateTime timeStamp;
  final double respiratoryRate;
  final String state; // pet is at rest or sleep at time of monitoring
  final String? notes;
  final bool isNormal; // above or below normal threshold

  RespiratoryModel({
    required this.id,
    required this.timeStamp,
    required this.respiratoryRate,
    required this.state,
    this.notes,
    required this.isNormal,
  });
}