class OverallRespiratoryStatsSummary {
  final double averageBpm;
  final int minBpm;
  final int maxBpm;
  final double averageAtRestBpm;
  final double averageSleepingBpm;

  OverallRespiratoryStatsSummary({
    required this.averageBpm,
    required this.minBpm,
    required this.maxBpm,
    required this.averageAtRestBpm,
    required this.averageSleepingBpm,
  });

  factory OverallRespiratoryStatsSummary.fromMap(Map<String, dynamic> row) {
    double _toDouble(Object? v) => (v as num?)?.toDouble() ?? 0.0;
    int    _toInt   (Object? v) => (v as num?)?.toInt()    ?? 0;

    return OverallRespiratoryStatsSummary(
      averageBpm:         _toDouble(row['averageBpm']),
      minBpm:             _toInt   (row['minBpm']),
      maxBpm:             _toInt   (row['maxBpm']),
      averageAtRestBpm:   _toDouble(row['averageAtRestBpm']),
      averageSleepingBpm: _toDouble(row['averageSleepingBpm']),
    );
  }
}