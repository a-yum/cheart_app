import 'package:flutter/foundation.dart';

@immutable
class PetOverviewData {
  final int sessionCountToday;
  final double? mostRecentBpm;
  final DateTime? mostRecentTimestamp;

  const PetOverviewData({
    required this.sessionCountToday,
    required this.mostRecentBpm,
    required this.mostRecentTimestamp,
  });

  PetOverviewData copyWith({
    int? sessionCountToday,
    double? mostRecentBpm,
    DateTime? mostRecentTimestamp,
  }) {
    return PetOverviewData(
      sessionCountToday: sessionCountToday ?? this.sessionCountToday,
      mostRecentBpm: mostRecentBpm ?? this.mostRecentBpm,
      mostRecentTimestamp: mostRecentTimestamp ?? this.mostRecentTimestamp,
    );
  }
}
