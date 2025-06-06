import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:cheart/providers/pet_profile_provider.dart';
import 'package:cheart/providers/pet_landing_provider.dart';
import 'package:cheart/components/common/stat_card.dart';
import 'package:cheart/themes/cheart_theme.dart';
import 'package:cheart/components/common/bottom_navbar.dart';
import 'package:cheart/components/pet_profile/pet_profile_avatar.dart';
import 'package:cheart/screens/graph_screen.dart';
import 'package:cheart/screens/respiratory_rate_screen.dart';
import 'package:cheart/screens/graph_screen_constants.dart';

class PetLandingScreen extends StatelessWidget {
  const PetLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petProfileProv = Provider.of<PetProfileProvider>(context);
    final selectedPet = petProfileProv.selectedPetProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet'),
        backgroundColor: CHeartTheme.primaryColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: CHeartTheme.screenPadding,
          child: selectedPet == null
              ? const Center(
                  child: Text(
                    'Add a pet',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        PetProfileAvatar(
                          petName: selectedPet.petName,
                          imagePath: selectedPet.petProfileImagePath,
                          size: 80.0,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedPet.petName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${selectedPet.petAgeInYears} years old',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedPet.petBreed ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Data section title
                    const Text(
                      'Pet Statistics',
                      style: CHeartTheme.sectionTitle,
                    ),
                    const SizedBox(height: 16),

                    // ─── StatCards ───
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardSize = constraints.maxWidth / 3;
                        final padding = GraphScreenConstants.getResponsivePadding(cardSize);
                        return SizedBox(
                          height: cardSize,
                          child: Consumer<PetLandingProvider>(
                            builder: (context, landingProv, _) {
                              // “Most Recent” card
                              String title1 = 'Most Recent';
                              String value1, dateTime1;
                              if (landingProv.latestSession == null) {
                                value1 = 'No sessions yet';
                                dateTime1 = '';
                              } else {
                                final s = landingProv.latestSession!;
                                value1 = '${s.respiratoryRate} bpm';
                                final ts = s.timeStamp;
                                final month = ts.month.toString().padLeft(2, '0');
                                final day = ts.day.toString().padLeft(2, '0');
                                final timeLabel = _formatTime(ts);
                                dateTime1 = '$month/$day @ $timeLabel';
                              }

                              // “Today’s Avg” card
                              String todayValue, todayUnit;
                              Color? todayUnitColor;
                              if (landingProv.todayAvg == null) {
                                todayValue = 'No data today';
                                todayUnit = '';
                                todayUnitColor = null;
                              } else {
                                final avg = landingProv.todayAvg!.round();
                                final yAvg = landingProv.yesterdayAvg;
                                if (yAvg == null) {
                                  todayValue = '$avg bpm';
                                  todayUnit = 'vs Yest: —';
                                  todayUnitColor = null;
                                } else {
                                  final delta = avg - yAvg.round();
                                  todayValue = '$avg bpm';
                                  if (delta >= 0) {
                                    todayUnit = '▲${delta.abs()} vs Yest';
                                    todayUnitColor = Colors.red;
                                  } else {
                                    todayUnit = '▼${delta.abs()} vs Yest';
                                    todayUnitColor = Colors.green;
                                  }
                                }
                              }

                              // “Current Streak” card
                              final streak = landingProv.currentStreak;
                              String streakValue, streakUnit;
                              if (streak <= 0) {
                                streakValue = '0';
                                streakUnit = 'Days';
                              } else {
                                streakValue = streak.toString();
                                streakUnit = (streak == 1 ? 'Day' : 'Days');
                              }

                              return Row(
                                children: [
                                  // Custom Card 1
                                  Expanded(
                                    child: Card(
                                      elevation: 2,
                                      child: Padding(
                                        padding: EdgeInsets.all(padding),
                                        child: Column(
                                          children: [
                                            // Top third: Title
                                            Expanded(
                                              flex: 1,
                                              child: Center(
                                                child: Text(
                                                  title1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.grey[600],
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),

                                            // Middle third: Value
                                            Expanded(
                                              flex: 1,
                                              child: Center(
                                                child: Text(
                                                  value1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),

                                            // Bottom third: Date/time
                                            Expanded(
                                              flex: 1,
                                              child: Center(
                                                child: Text(
                                                  dateTime1,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.grey[600],
                                                        fontSize: 9,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: GraphScreenConstants.cardSpacing),
                                  // Card 2: Today's Avg (with arrow indicator)
                                  Expanded(
                                    child: StatCard(
                                      title: 'Today’s Avg',
                                      value: todayValue,
                                      unit: todayUnit,
                                      unitColor: todayUnitColor,
                                    ),
                                  ),
                                  const SizedBox(width: GraphScreenConstants.cardSpacing),
                                  // Card 3: Current Streak
                                  Expanded(
                                    child: StatCard(
                                      title: 'Streak',
                                      value: streakValue,
                                      unit: streakUnit,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Monitor and View Breathing Rate cards
                    Container(
                      decoration: BoxDecoration(
                        color: CHeartTheme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RespiratoryRateScreen(),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: const [
                                  Text(
                                    'Monitor',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: Colors.white),
                          InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GraphScreen(),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: const [
                                  Text(
                                    'View Breathing Rate',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const BottomNavbar(currentIndex: 1),
    );
  }

  // ─── Helper formatters ───

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}
