class HourlyPoint {
  final DateTime time;
  final double bpm;

  HourlyPoint({
    required this.time,
    required this.bpm,
  });
}

// Aggregated statistics for a single day, used in weekly and monthly views.
class DailyStat {
  final DateTime date;
  final double avgBpm;
  final int count;
  final int minBpm;
  final int maxBpm;
  final double? highPct; // Percentage of sessions on that day where bpm ≥ the high‐threshold.

  DailyStat({
    required this.date,
    required this.avgBpm,
    required this.count,
    required this.minBpm,
    required this.maxBpm,
    this.highPct,
  });
}
