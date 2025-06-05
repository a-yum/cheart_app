import 'package:cheart/themes/cheart_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cheart/components/pet_profile/pet_profile_avatar.dart';
import 'package:cheart/models/pet_profile_model.dart';

class PetOverviewCard extends StatelessWidget {
  final PetProfileModel pet;
  final int sessionCountToday;
  final double? mostRecentBpm;
  final DateTime? mostRecentTimestamp;

  const PetOverviewCard({
    super.key,
    required this.pet,
    required this.sessionCountToday,
    required this.mostRecentBpm,
    required this.mostRecentTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Format the most recent BPM (to one decimal) or show placeholder
    final bpmText = (mostRecentBpm != null)
        ? mostRecentBpm!.toStringAsFixed(1)
        : '—';

    // Format the timestamp if available
    final timeText = (mostRecentTimestamp != null)
        ? DateFormat('h:mm a, MMM d').format(mostRecentTimestamp!)
        : '—';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CHeartTheme.cardBackgroundColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column: Avatar + Name
          Column(
            children: [
              PetProfileAvatar(
                petName: pet.petName,
                imagePath: pet.petProfileImagePath,
                size: 60.0, // adjust as needed
              ),
              const SizedBox(height: 8),
              Text(
                pet.petName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Right column: session stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sessions Today: $sessionCountToday',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Most Recent: $bpmText bpm',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'At: $timeText',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
