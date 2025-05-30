class WeeklyStats {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double averageBpm;
  final int minBpm;
  final int maxBpm;
  final int sessionCount;
  final String status;       // "at_rest" or "sleeping"
  final double? trend;       // Δ vs prior week, can be null for first

  WeeklyStats({
    required this.weekStart,
    required this.weekEnd,
    required this.averageBpm,
    required this.minBpm,
    required this.maxBpm,
    required this.sessionCount,
    required this.status,
    this.trend,
  });

   WeeklyStats copyWith({
    DateTime? weekStart,
    DateTime? weekEnd,
    double? averageBpm,
    int? minBpm,
    int? maxBpm,
    int? sessionCount,
    String? status,
    double? trend,
  }) {
    return WeeklyStats(
      weekStart:    weekStart    ?? this.weekStart,
      weekEnd:      weekEnd      ?? this.weekEnd,
      averageBpm:   averageBpm   ?? this.averageBpm,
      minBpm:       minBpm       ?? this.minBpm,
      maxBpm:       maxBpm       ?? this.maxBpm,
      sessionCount: sessionCount ?? this.sessionCount,
      status:       status       ?? this.status,
      trend:        trend        ?? this.trend,
    );
  }
}
